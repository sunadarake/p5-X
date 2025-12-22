use strict;
use warnings;
use utf8;
use Test::More tests => 10;
use File::Temp qw(tempdir);
use File::Spec;

BEGIN {
    use_ok('X::File') || print "Bail out!\n";
}

# テスト用の一時ディレクトリを作成
my $tempdir = tempdir(CLEANUP => 1);

# テスト用ファイルを作成
fp(File::Spec->catfile($tempdir, 'test1.txt'), 'content1');
fp(File::Spec->catfile($tempdir, 'test2.txt'), 'content2');
fp(File::Spec->catfile($tempdir, 'subdir', 'test3.txt'), 'content3');

# ff: スカラーコンテキストで配列リファレンスを返す
my $files_ref = ff($tempdir);
is(ref($files_ref), 'ARRAY', 'ff returns array ref in scalar context');
is(scalar(@$files_ref), 3, 'ff found 3 files');

# ff: リストコンテキストで配列を返す
my @files = ff($tempdir);
is(scalar(@files), 3, 'ff returns array in list context');

# ffa: ff と同じ動作
my $files_a_ref = ffa($tempdir);
is(ref($files_a_ref), 'ARRAY', 'ffa returns array ref in scalar context');

# ffr: スカラーコンテキストで配列リファレンスを返す
my $rel_files_ref = ffr($tempdir);
is(ref($rel_files_ref), 'ARRAY', 'ffr returns array ref in scalar context');

# ffr: リストコンテキストで配列を返す
my @rel_files = ffr($tempdir);
is(scalar(@rel_files), 3, 'ffr returns array in list context');

# fg: ファイル読み込み
my $content = fg(File::Spec->catfile($tempdir, 'test1.txt'));
is($content, 'content1', 'fg reads file content');

# rm: ファイル削除のテスト
my $test_file = File::Spec->catfile($tempdir, 'test1.txt');
ok(-f $test_file, 'file exists before rm');
rm($test_file);
ok(!-f $test_file, 'file removed after rm');
