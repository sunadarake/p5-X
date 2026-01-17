#!/usr/bin/env perl
# install-global.pl
use strict;
use warnings;
use 5.010;

say "Installing globally...";

# cpanmのオプション
my @cpanm_opts = ('-n');

# Windows以外
if ( $^O ne 'MSWin32' ) {
    say "Installing GitHub modules for Unix...";
    system( 'cpanm', @cpanm_opts,
        'https://github.com/sunadarake/File-Find-utf8.git' );
    system( 'cpanm', @cpanm_opts, 'https://github.com/sunadarake/Cwd-utf8.git' );
}
else {
    # Windows
    say "Installing GitHub modules for Windows...";
    system( 'cpanm', @cpanm_opts,
        'https://github.com/sunadarake/p5-win-unicode.git' );
}

# 通常の依存関係
say "";
say "Installing dependencies from cpanfile...";
system( 'cpanm', '--installdeps', '.' );

# make コマンドの選択
my $make = ( $^O eq 'MSWin32' ) ? 'gmake' : 'make';

# Makefile.PL の実行
say "";
say "Running Makefile.PL...";
system( 'perl', 'Makefile.PL' );

# make
say "";
say "Running $make...";
system( $make );

# make test
say "";
say "Running $make test...";
system( $make, 'test' );

# make install
say "";
say "Running $make install...";
system( $make, 'install' );

say "";
say "Installation completed!";
