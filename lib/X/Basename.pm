package X::Basename;

use strict;
use warnings;
use utf8;

use File::Basename qw(basename dirname);
use File::Spec;
use Encode;    # エンコード/デコード用

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(bn dn rp abs rel pwd);

# OS判定
my $IS_WIN = ( $^O eq 'MSWin32' );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        require Win32::Unicode::Dir;
        Win32::Unicode::Dir->import(qw(getcwdW));
    }
    else {
        require Cwd::utf8;
        Cwd::utf8->import(qw(getcwd realpath));
    }
}

# basename
sub bn {
    my ($path) = @_;
    return basename($path);
}

# dirname
sub dn {
    my ($path) = @_;
    return dirname($path);
}

# realpath
sub rp {
    my ($path) = @_;
    if ($IS_WIN) {

        # --- 修正ポイント 1: rel2abs ---

        # 1. カレントディレクトリを取得 (UTF-8)
        my $cwd = getcwdW();

        # 2. rel2abs に渡すために、引数とベースを cp932 バイト列に変換
        #    ※ $path は既にUTF-8フラグ付きと仮定(呼び出し元でdecode済み)
        my $path_bytes = Encode::encode( 'cp932', $path );
        my $cwd_bytes  = Encode::encode( 'cp932', $cwd );

        # 3. File::Spec->rel2abs を実行（結果はcp932バイト列）
        my $abs_bytes = File::Spec->rel2abs( $path_bytes, $cwd_bytes );

        # 4. 結果を UTF-8 文字列に戻して返す
        return Encode::decode( 'cp932', $abs_bytes );
    }
    else {
        return realpath($path);
    }
}

## realpath
#sub rp {
#    my ($path) = @_;
#    if ($IS_WIN) {

#        # Win32::Unicode::getcwdW は UTF-8 文字列を返す
#        my $cwd = getcwdW();

#        # File::Spec->rel2abs は UTF-8 文字列をそのまま受け取れる
#        # エンコード処理は不要です
#        return File::Spec->rel2abs( $path, $cwd );
#    }
#    else {
#        return realpath($path);
#    }
#}

# realpath（rpのエイリアス）
sub abs {
    my ($path) = @_;
    return rp($path);
}

# 相対パスを返す（$rootを基準、未指定なら現在のディレクトリ基準）
sub rel {
    my ( $path, $root ) = @_;
    $root //= pwd();

    my $abs_path = rp($path) || $path;
    my $abs_root = rp($root) || $root;

    # --- 修正ポイント 2: abs2rel ---

    if ($IS_WIN) {

        # Windows: File::Spec は cp932 バイト列を期待する
        my $path_bytes = Encode::encode( 'cp932', $abs_path );
        my $root_bytes = Encode::encode( 'cp932', $abs_root );

        my $rel_bytes = File::Spec->abs2rel( $path_bytes, $root_bytes );

        return Encode::decode( 'cp932', $rel_bytes );
    }
    else {
        return File::Spec->abs2rel( $abs_path, $abs_root );
    }
}

## 相対パスを返す
#sub rel {
#    my ( $path, $root ) = @_;
#    $root //= pwd();

#    # rp, pwd はすべて UTF-8 文字列を返すようにする
#    my $abs_path = rp($path) || $path;
#    my $abs_root = rp($root) || $root;

#    # File::Spec->abs2rel も UTF-8 文字列をそのまま受け取れる
#    # エンコード処理を削除します
#    return File::Spec->abs2rel( $abs_path, $abs_root );
#}

# カレントディレクトリを取得
sub pwd {
    if ($IS_WIN) {
        return getcwdW();
    }
    else {
        return getcwd();
    }
}

1;
