
package X::File;

use strict;
use warnings;
use utf8;

BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Native;
        Win32::Unicode::Native->import();
    } else {
        require utf8::all;
        utf8::all->import();
    }
}

use File::Find;
use File::Path qw(make_path remove_tree);
use File::Copy qw(copy move);
use File::Spec;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(ff ffa ffr fg fp md rm cp mv);

# ディレクトリのファイルを再帰的に取得（絶対パス）
sub ff {
    my ($root_dir) = @_;
    return [] unless -d $root_dir;

    my $abs_root = abs_path($root_dir);
    my @files;

    find(sub {
        push @files, $File::Find::name if -f;
    }, $abs_root);

    return \@files;
}

# ff と同じ
sub ffa {
    return ff(@_);
}

# root_dir を基準とした相対パスの配列を返す
sub ffr {
    my ($root_dir) = @_;
    return [] unless -d $root_dir;

    my $abs_root = abs_path($root_dir);
    my @files;

    find(sub {
        if (-f) {
            my $rel_path = File::Spec->abs2rel($File::Find::name, $abs_root);
            push @files, $rel_path;
        }
    }, $abs_root);

    return \@files;
}

# ファイルの中身を返す
sub fg {
    my ($filepath) = @_;
    return undef unless -f $filepath;

    open my $fh, '<', $filepath or die "Cannot open $filepath: $!";
    my $content = do { local $/; <$fh> };
    close $fh;

    return $content;
}

# ファイルに$contentを保存する
sub fp {
    my ($filepath, $content) = @_;

    # ディレクトリが存在しない場合は作成
    my $dir = dirname($filepath);
    make_path($dir) unless -d $dir;

    open my $fh, '>', $filepath or die "Cannot write to $filepath: $!";
    print $fh $content;
    close $fh;

    return 1;
}

# ディレクトリを再帰的に作成
sub md {
    my ($dir) = @_;
    make_path($dir) unless -d $dir;
    return 1;
}

# ファイルまたはディレクトリを削除（ディレクトリは再帰的）
sub rm {
    my ($path) = @_;

    if (-d $path) {
        remove_tree($path);
    } elsif (-f $path) {
        unlink $path or die "Cannot remove $path: $!";
    }

    return 1;
}

# ファイルをコピー（$destのディレクトリがない場合は作成）
sub cp {
    my ($src, $dest) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = dirname($dest);
    make_path($dest_dir) unless -d $dest_dir;

    copy($src, $dest) or die "Cannot copy $src to $dest: $!";
    return 1;
}

# ファイルを移動（$destのディレクトリがない場合は作成）
sub mv {
    my ($src, $dest) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = dirname($dest);
    make_path($dest_dir) unless -d $dest_dir;

    move($src, $dest) or die "Cannot move $src to $dest: $!";
    return 1;
}

1;
