use strict;
use warnings;
use Test::More tests => 4;

BEGIN {
    use_ok('X') || print "Bail out!\n";
}

diag("Testing X $X::VERSION, Perl $], $^X");

ok(defined $X::VERSION, 'VERSION is defined');
can_ok('X', 'VERSION');

# STDOUT が UTF-8 レイヤーを持っているか確認（utf8::all の効果）
#my $layers = join ' ', PerlIO::get_layers(STDOUT);
#like($layers, qr/utf-?8/i, 'STDOUT has UTF-8 layer (utf8::all effect)');
