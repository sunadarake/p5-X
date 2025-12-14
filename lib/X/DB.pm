
package DB {
    use utf8;
    use Carp qw(croak);
    use DBI;

    # コンストラクタ
    sub new ( $class, %args ) {
        my $db_path  = $args{db_path}  || croak "db_path is required";
        my $username = $args{username} || "";
        my $password = $args{password} || "";

        # DBディレクトリが存在しない場合は作成
        my $db_dir = $db_path;
        $db_dir =~ s|/[^/]+$||;
        if ( $db_dir && !-d $db_dir ) {
            mkdir $db_dir or die "DBディレクトリの作成に失敗: $db_dir ($!)";
        }

        # SQLite接続
        my $dbh = DBI->connect(
            "dbi:SQLite:dbname=$db_path",
            $username,
            $password,
            {
                RaiseError     => 1,
                PrintError     => 0,
                AutoCommit     => 1,
                sqlite_unicode => 1,
            }
        ) or die $DBI::errstr;

        my $self = {
            dbh => $dbh,
        };

        return bless $self, $class;
    }

    # DBハンドルを取得
    sub dbh ($self) {
        return $self->{dbh};
    }

    # SQL実行
    sub execute ( $self, $sql, $binds = [] ) {
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@$binds);
        return $sth;
    }

    # 全レコード取得
    sub find_all ( $self, $table, $option = {} ) {
        my $sql = "SELECT * FROM $table";
        
        if ( $option->{order_by} ) {
            $sql .= " ORDER BY $option->{order_by}";
        }
        
        my $sth = $self->dbh->prepare($sql);
        $sth->execute();
        
        my @rows;
        while ( my $row = $sth->fetchrow_hashref ) {
            push @rows, $row;
        }
        
        return \@rows;
    }

    # IDで1件取得
    sub find_by_id ( $self, $table, $id ) {
        my $sql = "SELECT * FROM $table WHERE id = ? LIMIT 1";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute($id);
        return $sth->fetchrow_hashref;
    }

    # 条件で1件取得
    sub find_by ( $self, $table, $condition ) {
        my ( $where, $binds ) = $self->_build_where($condition);
        my $sql = "SELECT * FROM $table WHERE $where LIMIT 1";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@$binds);
        return $sth->fetchrow_hashref;
    }

    # SQL直接実行で検索
    sub find_by_sql ( $self, $table, $sql, $binds = [], $option = {} ) {
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@$binds);
        
        my @rows;
        while ( my $row = $sth->fetchrow_hashref ) {
            push @rows, $row;
        }
        
        return \@rows;
    }

    # 条件で複数件取得
    sub where ( $self, $table, $cond, $option = {} ) {
        my ( $where, $binds ) = $self->_build_where($cond);
        my $sql = "SELECT * FROM $table";
        
        if ($where) {
            $sql .= " WHERE $where";
        }
        
        if ( $option->{order_by} ) {
            $sql .= " ORDER BY $option->{order_by}";
        }
        
        if ( $option->{limit} ) {
            $sql .= " LIMIT $option->{limit}";
        }
        
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@$binds);
        
        my @rows;
        while ( my $row = $sth->fetchrow_hashref ) {
            push @rows, $row;
        }
        
        return \@rows;
    }

    # レコード作成
    sub create ( $self, $table, $data ) {
        my @keys   = keys %$data;
        my @values = values %$data;
        
        my $cols        = join( ', ', @keys );
        my $placeholders = join( ', ', ('?') x @keys );
        
        my $sql = "INSERT INTO $table ($cols) VALUES ($placeholders)";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@values);
        
        my $id = $self->dbh->last_insert_id( undef, undef, $table, undef );
        return $self->find_by_id( $table, $id );
    }

    # レコード作成（エイリアス）
    sub insert ( $self, $table, $data ) {
        return $self->create( $table, $data );
    }

    # 検索して見つからなければ作成
    sub find_or_create ( $self, $table, $data, $cond ) {
        my $row = $self->find_by( $table, $cond );
        return $row if $row;
        return $self->create( $table, $data );
    }

    # レコード更新して再取得
    sub update_and_find ( $self, $table, $id, $data ) {
        $self->update( $table, $id, $data );
        return $self->find_by_id( $table, $id );
    }

    # レコード存在確認
    sub exists ( $self, $table, $cond ) {
        my $row = $self->find_by( $table, $cond );
        return $row ? 1 : 0;
    }

    # 更新または作成
    sub upsert ( $self, $table, $data, $search_condition ) {
        my $row = $self->find_by( $table, $search_condition );
        
        if ($row) {
            my $id = $row->{id};
            $self->update( $table, $id, $data );
            return $self->find_by_id( $table, $id );
        }
        else {
            my $merged_data = { %$search_condition, %$data };
            return $self->create( $table, $merged_data );
        }
    }

    # レコード更新
    sub update ( $self, $table, $id, $data ) {
        my @keys   = keys %$data;
        my @values = values %$data;
        
        my $set = join( ', ', map { "$_ = ?" } @keys );
        my $sql = "UPDATE $table SET $set WHERE id = ?";
        
        my $sth = $self->dbh->prepare($sql);
        $sth->execute( @values, $id );
        
        return $sth->rows;
    }

    # レコード削除
    sub delete ( $self, $table, $id ) {
        my $sql = "DELETE FROM $table WHERE id = ?";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute($id);
        return $sth->rows;
    }

    # 条件でレコード削除
    sub delete_by ( $self, $table, $condition ) {
        my ( $where, $binds ) = $self->_build_where($condition);
        my $sql = "DELETE FROM $table WHERE $where";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@$binds);
        return $sth->rows;
    }

    # 総レコード数
    sub total_count ( $self, $table ) {
        my $sql = "SELECT COUNT(*) FROM $table";
        my $sth = $self->dbh->prepare($sql);
        $sth->execute();
        my ($count) = $sth->fetchrow_array;
        return $count;
    }

    # トランザクション開始
    sub begin_trans ($self) {
        $self->dbh->begin_work;
    }

    # コミット
    sub commit ($self) {
        $self->dbh->commit;
    }

    # ロールバック
    sub rollback ($self) {
        $self->dbh->rollback;
    }

    # WHERE句を構築（内部メソッド）
    sub _build_where ( $self, $condition ) {
        my @keys   = keys %$condition;
        my @values = values %$condition;
        
        my $where = join( ' AND ', map { "$_ = ?" } @keys );
        
        return ( $where, \@values );
    }
}

1;
