#!/usr/bin/env perl
# test_runner.pl

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
my @cmd = ( $^X, '-S', 'prove', $t );
my $ret = system(@cmd);

exit( $ret >> 8 );
