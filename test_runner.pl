#!/usr/bin/env perl
# test_runner.pl
# テストを良い感じに自動化して実行するためのスクリプト。

=pod
    WARN: zedのターミナル上で実行してはいけない。特にWindows環境では、ファイル、ディレクトリ操作でエラーが発生する。
          代わりに、標準ターミナル上でpowershell または コマンドプロンプトで実行するようにすること。
=cut

use strict;
use warnings;
use 5.010;

# 引数のデフォルト値
my $t = shift @ARGV || 't/';

# localディレクトリの存在確認
unless ( -d 'local' ) {
    say "Installing dependencies from cpanfile...";
    $ENV{PERL_MM_USE_DEFAULT} = 1;
    system( 'cpanm', '--quiet', '--notest', '--installdeps', '-l', 'local',
        '.' );
}
else {
    say "local directory exists. Skipping dependency installation.";
}

# テスト実行
say "";
say "Running tests...";

# Windowsでも動作するようにproveを実行
my @cmd = ( $^X, '-S', 'prove', '-v', '-l', '-Ilocal/lib/perl5', $t );
my $ret = system(@cmd);

exit( $ret >> 8 );
