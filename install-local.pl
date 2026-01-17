#!/usr/bin/env perl
# install-local.pl
use strict;
use warnings;
use 5.010;

say "Installing to local/ directory...";

# cpanmのオプション
my @cpanm_opts = ('-n', '-l', 'local');

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
system( 'cpanm', '-l', 'local', '--installdeps', '.' );

say "";
say "Installation completed!";
