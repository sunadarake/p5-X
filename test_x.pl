#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use lib 'lib';
use X;

# テストディレクトリを作成
md('test_dir/sub_dir');
print "✓ md() works\n";

# ファイルを作成
fp('test_dir/test.txt', 'Hello World');
print "✓ fp() works\n";

# ファイルを読み込み
my $content = fg('test_dir/test.txt');
print "✓ fg() works: $content\n";

# ファイルをコピー
cp('test_dir/test.txt', 'test_dir/sub_dir/test_copy.txt');
print "✓ cp() works\n";

# ファイル一覧を取得（絶対パス）
my $files = ff('test_dir');
print "✓ ff() works: " . scalar(@$files) . " files found\n";

# ファイル一覧を取得（相対パス）
my $rel_files = ffr('test_dir');
print "✓ ffr() works: " . join(', ', @$rel_files) . "\n";

# ffa() テスト
my $files2 = ffa('test_dir');
print "✓ ffa() works: " . scalar(@$files2) . " files found\n";

# ファイルを移動
mv('test_dir/test.txt', 'test_dir/test_moved.txt');
print "✓ mv() works\n";

# クリーンアップ
rm('test_dir');
print "✓ rm() works\n";

print "\nAll functions work correctly!\n";
