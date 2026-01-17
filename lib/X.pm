
package X;

use strict;
use warnings;
use utf8;
use Import::Into;

our $VERSION = '0.07';

# プラットフォーム別のUnicode処理
# Linux/Macの場合: utf8::all
# Windowsの場合: Win32::Unicode::Native
BEGIN {
    if ( $^O eq 'MSWin32' ) {
        #require Win32::Unicode::Native;
        #Win32::Unicode::Native->import();
    }
    else {
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
our @ISA = qw(Exporter);
our @EXPORT;

# 各サブモジュールの関数をエクスポートリストに追加
push @EXPORT, @X::File::EXPORT;
push @EXPORT, @X::Json::EXPORT;
push @EXPORT, @X::Basename::EXPORT;
push @EXPORT, @X::Http::EXPORT;
push @EXPORT, @X::Shell::EXPORT;

# 呼び出し側に utf8::all または Win32::Unicode::Native を適用
sub import {
    my $class  = shift;
    my $caller = caller;

    'utf8'->import::into($caller);

    # プラットフォーム別に適切なモジュールを呼び出し側に適用
    if ( $^O eq 'MSWin32' ) {
        require Win32::Unicode::Native;
        Win32::Unicode::Native->import::into($caller);
    }
    else {
        require utf8::all;
        utf8::all->import::into($caller);
    }

    # Exporter の機能でシンボルをエクスポート
    @_ = ( $class, @_ );
    goto &Exporter::import;
}

1;
