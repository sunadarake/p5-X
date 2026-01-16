package X::File;

use strict;
use warnings;
use utf8;

use File::Spec;
use Encode;    # <-- 追加

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(ff ffa ffr fg fp md rm cp mv);

# OS判定
my $IS_WIN;

BEGIN {
    $IS_WIN = ( $^O eq 'MSWin32' );
    if ($IS_WIN) {
        require Win32::Unicode::Dir;
        require Win32::Unicode::File;
        require File::Basename;
        Win32::Unicode::Dir->import(qw(findW mkpathW rmtreeW getcwdW));
        Win32::Unicode::File->import(qw(unlinkW copyW moveW));
    }
    else {
        require File::Find::utf8;
        require File::Path;
        require File::Copy;
        require Cwd::utf8;
        require File::Basename;
        File::Path->import(qw(make_path remove_tree));
        File::Copy->import(qw(copy move));
        Cwd::utf8->import(qw(abs_path));
    }
}

# 絶対パスを取得
sub _abs_path {
    my ($path) = @_;
    if ($IS_WIN) {

        # --- 修正ポイント 1: rel2abs ---
        my $cwd        = getcwdW();
        my $path_bytes = Encode::encode( 'cp932', $path );
        my $cwd_bytes  = Encode::encode( 'cp932', $cwd );

        my $abs_bytes = File::Spec->rel2abs( $path_bytes, $cwd_bytes );

        return Encode::decode( 'cp932', $abs_bytes );
    }
    else {
        return abs_path($path);
    }
}

# ディレクトリのファイルを再帰的に取得（絶対パス）
sub ff {
    my ($root_dir) = @_;
    return wantarray ? () : [] unless -d $root_dir;

    my $abs_root = _abs_path($root_dir);
    my @files;

    if ($IS_WIN) {
        findW(
            sub {
                my $name = $Win32::Unicode::Dir::name;
                push @files, $name if -f $name;
            },
            $abs_root
        );
    }
    else {
        File::Find::find(
            sub {
                push @files, $File::Find::name if -f;
            },
            $abs_root
        );
    }

    return wantarray ? @files : \@files;
}

# ff と同じ
sub ffa {
    return ff(@_);
}

# root_dir を基準とした相対パスの配列を返す
sub ffr {
    my ($root_dir) = @_;
    return wantarray ? () : [] unless -d $root_dir;

    my $abs_root = _abs_path($root_dir);
    my @files;

    if ($IS_WIN) {
        findW(
            sub {
                my $name = $Win32::Unicode::Dir::name;
                if ( -f $name ) {

                    # --- 修正ポイント 2: abs2rel ---
                    my $name_bytes = Encode::encode( 'cp932', $name );
                    my $root_bytes = Encode::encode( 'cp932', $abs_root );

                    my $rel_bytes =
                      File::Spec->abs2rel( $name_bytes, $root_bytes );

                    my $rel_path = Encode::decode( 'cp932', $rel_bytes );
                    push @files, $rel_path;
                }
            },
            $abs_root
        );
    }
    else {
        File::Find::find(
            sub {
                if (-f) {
                    my $rel_path =
                      File::Spec->abs2rel( $File::Find::name, $abs_root );
                    push @files, $rel_path;
                }
            },
            $abs_root
        );
    }

    return wantarray ? @files : \@files;
}

# ファイルの中身を返す
sub fg {
    my ($filepath) = @_;
    return undef unless -f $filepath;

    my $content;
    if ($IS_WIN) {
        my $fh = Win32::Unicode::File->new( '<', $filepath )
          or die "Cannot open $filepath: $!";
        $content = $fh->slurp;
        $fh->close;
    }
    else {
        open my $fh, '<', $filepath or die "Cannot open $filepath: $!";
        $content = do { local $/; <$fh> };
        close $fh;
    }
    return $content;
}

# ファイルに$contentを保存する
sub fp {
    my ( $filepath, $content ) = @_;

    # ディレクトリが存在しない場合は作成
    my $dir = _dirname($filepath);    # 内部ヘルパーを使用
    md($dir) unless -d $dir;

    if ($IS_WIN) {
        my $fh = Win32::Unicode::File->new( '>', $filepath )
          or die "Cannot write to $filepath: $!";
        $fh->print($content);
        $fh->close;
    }
    else {
        open my $fh, '>', $filepath or die "Cannot write to $filepath: $!";
        print $fh $content;
        close $fh;
    }

    return 1;
}

# ディレクトリを再帰的に作成
sub md {
    my ($dir) = @_;
    return 1 if -d $dir;

    if ($IS_WIN) {
        mkpathW($dir);
    }
    else {
        make_path($dir);
    }
    return 1;
}

# ファイルまたはディレクトリを削除（ディレクトリは再帰的）
sub rm {
    my ($path) = @_;

    if ( -d $path ) {
        if ($IS_WIN) {
            rmtreeW($path);
        }
        else {
            remove_tree($path);
        }
    }
    elsif ( -f $path ) {
        if ($IS_WIN) {
            unlinkW($path) or die "Cannot remove $path: $!";
        }
        else {
            unlink $path or die "Cannot remove $path: $!";
        }
    }

    return 1;
}

# ファイルをコピー（$destのディレクトリがない場合は作成）
sub cp {
    my ( $src, $dest ) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = _dirname($dest);    # 内部ヘルパーを使用
    md($dest_dir) unless -d $dest_dir;

    if ($IS_WIN) {
        copyW( $src, $dest ) or die "Cannot copy $src to $dest: $!";
    }
    else {
        copy( $src, $dest ) or die "Cannot copy $src to $dest: $!";
    }
    return 1;
}

# ファイルを移動（$destのディレクトリがない場合は作成）
sub mv {
    my ( $src, $dest ) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = _dirname($dest);    # 内部ヘルパーを使用
    md($dest_dir) unless -d $dest_dir;

    if ($IS_WIN) {
        moveW( $src, $dest ) or die "Cannot move $src to $dest: $!";
    }
    else {
        move( $src, $dest ) or die "Cannot move $src to $dest: $!";
    }
    return 1;
}

# ヘルパー: ディレクトリ名を取得
sub _dirname {
    my ($path) = @_;
    return File::Basename::dirname($path);
}

1;
