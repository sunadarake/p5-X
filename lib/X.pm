
package X;

use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

# プラットフォーム別のUnicode処理
# Linux/Macの場合: utf8::all
# Windowsの場合: Win32::Unicode::Native
BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Native;
        Win32::Unicode::Native->import();
    } else {
        require utf8::all;
        utf8::all->import();
    }
}

use X::File;
use X::Json;
use X::Basename;
use X::Http;
use X::Shell;

use Exporter;
our @EXPORT = (@X::File::EXPORT, @X::Json::EXPORT, @X::Basename::EXPORT, @X::Http::EXPORT, @X::Shell::EXPORT);

# 呼び出し側に utf8::all または Win32::Unicode::Native を適用
sub import {
    my $class = shift;
    my $caller = caller;

    # プラットフォーム別に適切なモジュールを呼び出し側に適用
    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Native;
        eval qq{
            package $caller;
            use Win32::Unicode::Native;
            1;
        } or die $@;
    } else {
        require utf8::all;
        eval qq{
            package $caller;
            use utf8::all;
            1;
        } or die $@;
    }

    # Exporter の機能でシンボルをエクスポート
    @_ = ($class, @_);
    goto &Exporter::import;
}

1;
