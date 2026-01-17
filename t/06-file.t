use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw/remove_tree/;
use File::Spec;
use Encode qw(encode decode);

BEGIN {
    use_ok('X::File') || print "Bail out!\n";
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

# テスト用の一時ディレクトリを作成
my $tempdir = xdecode( tempdir( CLEANUP => 1 ) );

# ファイル一覧取得 (ff, ffa, ffr)
test 'ファイル一覧取得' => sub {
    # テスト用ファイルを作成
    fp( File::Spec->catfile( $tempdir, 'test1.txt' ), 'content1' );
    fp( File::Spec->catfile( $tempdir, 'test2.txt' ), 'content2' );
    fp( File::Spec->catfile( $tempdir, 'subdir', 'test3.txt' ), 'content3' );

    # ff: スカラーコンテキストで配列リファレンスを返す
    my $files_ref = ff($tempdir);
    is( ref($files_ref),     'ARRAY', 'ff returns array ref in scalar context' );
    is( scalar(@$files_ref), 3,       'ff found 3 files' );

    # ff: リストコンテキストで配列を返す
    my @files = ff($tempdir);
    is( scalar(@files), 3, 'ff returns array in list context' );

    # ffa: ff と同じ動作
    my $files_a_ref = ffa($tempdir);
    is( ref($files_a_ref), 'ARRAY', 'ffa returns array ref in scalar context' );

    # ffr: スカラーコンテキストで配列リファレンスを返す
    my $rel_files_ref = ffr($tempdir);
    is( ref($rel_files_ref), 'ARRAY', 'ffr returns array ref in scalar context' );

    # ffr: リストコンテキストで配列を返す
    my @rel_files = ffr($tempdir);
    is( scalar(@rel_files), 3, 'ffr returns array in list context' );
};

# ファイル操作 (fg, fp, rm)
test 'ファイル操作' => sub {
    # fg: ファイル読み込み
    my $content = fg( File::Spec->catfile( $tempdir, 'test1.txt' ) );
    is( $content, 'content1', 'fg reads file content' );

    # rm: ファイル削除のテスト
    my $test_file = File::Spec->catfile( $tempdir, 'test1.txt' );
    ok( -f xencode($test_file), 'file exists before rm' );
    rm($test_file);
    ok( !-f xencode($test_file), 'file removed after rm' );
};

# 日本語パス
test '日本語パス' => sub {
    my $jp_dir  = File::Spec->catdir( $tempdir, 'テストディレクトリ' );
    my $jp_file = File::Spec->catfile( $jp_dir, '日本語ファイル.txt' );

    # fp: 日本語ファイル名の作成
    fp( $jp_file, '日本語コンテンツ' );
    ok( -f xencode($jp_file), 'fp creates Japanese filename' );

    # fg: 日本語ファイルの読み込み
    my $jp_content = fg($jp_file);
    is( $jp_content, '日本語コンテンツ', 'fg reads Japanese file content' );

    # ff: 日本語ディレクトリ内のファイル検索
    my @jp_files = ff($jp_dir);
    ok( scalar(@jp_files) >= 1, 'ff finds files in Japanese directory' );

    # rm: 日本語ファイル名の削除
    rm($jp_file);
    ok( !-f xencode($jp_file), 'rm removes Japanese filename' );
};

done_testing;
