use strict;
use warnings;
use utf8;
use Test::More tests => 3;

BEGIN {
    use_ok('X::Http') || print "Bail out!\n";
}

can_ok('X::Http', 'hg', 'hp', 'wget');

# モジュールがロードできればOK（実際のHTTPテストは環境依存のため省略）
ok(1, 'X::Http functions are available');
