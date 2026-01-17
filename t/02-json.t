use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use Encode qw(encode decode);

BEGIN {
    use_ok('X::Json') || print "Bail out!\n";
}

# Windows用エンコード/デコードヘルパー
sub xencode { return $^O eq 'MSWin32' ? encode( 'cp932', $_[0] ) : $_[0]; }
sub xdecode { return $^O eq 'MSWin32' ? decode( 'cp932', $_[0] ) : $_[0]; }

# subtest のシンプルなラッパー
sub test {
    my ( $name, $code ) = @_;
    my $encoded_name =
      $^O eq 'MSWin32' ? encode( 'cp932', $name ) : encode( 'utf8', $name );
    subtest $encoded_name => $code;
}

# テスト用の一時ディレクトリ
my $tmpdir = xdecode( tempdir( CLEANUP => 1 ) );

# 関数のエクスポート
test '関数のエクスポート' => sub {
    can_ok('X::Json', 'jg', 'jp');
};

# ハッシュデータのJSON操作
test 'ハッシュデータのJSON操作' => sub {
    my $test_file = File::Spec->catfile( $tmpdir, 'test.json' );
    my $hash_data = { name => "テスト", value => 123, items => ["a", "b", "c"] };

    # jpで書き込み
    ok( jp( $test_file, $hash_data ), 'jp writes hash data' );
    ok( -f xencode($test_file), 'JSON file created' );

    # jgで読み込み
    my $loaded_data = jg($test_file);
    is_deeply( $loaded_data, $hash_data, 'jg reads hash data correctly' );
};

# 日本語の処理
test '日本語の処理' => sub {
    my $test_file = File::Spec->catfile( $tmpdir, 'japanese.json' );
    my $hash_data = { name => "テスト", value => 123 };

    jp( $test_file, $hash_data );
    my $loaded_data = jg($test_file);

    is( $loaded_data->{name}, "テスト", 'Japanese text handled correctly' );
};

# 配列データのJSON操作
test '配列データのJSON操作' => sub {
    my $array_data = ["項目1", "項目2", { key => "値" }];
    my $array_file = File::Spec->catfile( $tmpdir, 'array.json' );

    jp( $array_file, $array_data );
    my $loaded_array = jg($array_file);

    is_deeply( $loaded_array, $array_data, 'Array data handled correctly' );
};

done_testing;
