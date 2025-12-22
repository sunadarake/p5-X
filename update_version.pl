#!/usr/bin/env perl
# update_version.pl - モジュールのバージョンを自動でupdateするスクリプト
#　　0.01 0.02 のように minorバージョンをupdateする。 lib/X.pm と META.yml のバージョンを更新する
#    majorバージョンは手動でアップデートするようにした。  
use strict;
use warnings;
use X;

# ファイルパス
my $pm_file = 'lib/X.pm';
my $meta_file = 'META.yml';

# lib/X.pm を読み込み
my $pm_content = fg($pm_file);

# バージョン番号を抽出
$pm_content =~ /our \$VERSION = '([0-9.]+)';/ or die "Version not found in $pm_file";
my $old_version = $1;

# バージョンをインクリメント
my $new_version;
if ($old_version =~ /^(\d+)\.(\d+)$/) {
    my ($major, $minor) = ($1, $2);
    $minor++;
    $new_version = sprintf("%d.%02d", $major, $minor);
} else {
    die "Unsupported version format: $old_version";
}

print "Updating version: $old_version -> $new_version\n";

# lib/X.pm を更新
$pm_content =~ s/^our \$VERSION = '$old_version';/our \$VERSION = '$new_version';/m;
fp($pm_file, $pm_content);

# META.yml を更新
my $meta_content = fg($meta_file);
$meta_content =~ s/^version: '$old_version'/version: '$new_version'/m;
fp($meta_file, $meta_content);

print "Updated $pm_file and $meta_file\n";
