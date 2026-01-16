#!/usr/bin/env perl
# install-deps.pl
use strict;
use warnings;
use 5.010;
use Getopt::Long;

# オプション解析
my $local = 0;
my $help  = 0;

GetOptions(
    'l|local' => \$local,
    'h|help'  => \$help,
) or die "Error in command line arguments\n";

if ($help) {
    print <<"HELP";
Usage: $0 [options]

Options:
    -l, --local    Install to local/ directory
    -h, --help     Show this help

Examples:
    $0           # Install globally
    $0 --local   # Install to local/ directory
    $0 -l        # Install to local/ directory (short form)
HELP
    exit 0;
}

# インストール先の表示
if ($local) {
    say "Installing to local/ directory...";
}
else {
    say "Installing globally...";
}

# cpanmのオプション
my @cpanm_opts = ('-n');
push @cpanm_opts, '-l', 'local' if $local;

# Windows以外
if ( $^O ne 'MSWin32' ) {
    say "Installing GitHub modules for Unix...";
    system( 'cpanm', @cpanm_opts,
        'git://github.com/sunadarake/File-Find-utf8.git' );
    system( 'cpanm', @cpanm_opts, 'git://github.com/sunadarake/Cwd-utf8.git' );
}
else {
    # Windows
    say "Installing GitHub modules for Windows...";
    system( 'cpanm', @cpanm_opts,
        'git://github.com/sunadarake/p5-win-unicode.git' );
}

# 通常の依存関係
say "";
say "Installing dependencies from cpanfile...";
my @installdeps_opts = ( '--installdeps', '.' );
unshift @installdeps_opts, '-l', 'local' if $local;
system( 'cpanm', @installdeps_opts );

say "";
say "Installation completed!";
