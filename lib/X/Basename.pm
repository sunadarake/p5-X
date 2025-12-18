
package X::Basename;

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

use File::Basename qw(basename dirname);
use Cwd qw(getcwd realpath);
use File::Spec;

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(bn dn rp abs rel pwd);

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
    return realpath($path);
}

# realpath（rpのエイリアス）
sub abs {
    my ($path) = @_;
    return realpath($path);
}

# 相対パスを返す（$rootを基準、未指定なら現在のディレクトリ基準）
sub rel {
    my ($path, $root) = @_;
    $root //= getcwd();

    my $abs_path = realpath($path) || $path;
    my $abs_root = realpath($root) || $root;

    return File::Spec->abs2rel($abs_path, $abs_root);
}

# カレントディレクトリを取得
sub pwd {
    return getcwd();
}

1;
