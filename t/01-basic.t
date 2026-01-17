use strict;
use warnings;
use utf8;
use Test::More;
use Encode qw(encode decode);

# Windows用エンコード/デコードヘルパー
sub xencode { return $^O eq 'MSWin32' ? encode( 'cp932', $_[0] ) : $_[0]; }
sub xdecode { return $^O eq 'MSWin32' ? decode( 'cp932', $_[0] ) : $_[0]; }

# subtest のシンプルなラッパー
sub test {
    my ( $name, $code ) = @_;
    my $encoded_name =
      $^O eq 'MSWin32' ? encode( 'cp932', $name ) : encode( 'utf8', $name );
    subtest $encoded_name => $code;
}

BEGIN {
    use_ok('X') || print "Bail out!\n";
}

diag("Testing X $X::VERSION, Perl $], $^X");

# モジュールの基本情報
test 'モジュールの基本情報' => sub {
    ok( defined $X::VERSION, 'VERSION is defined' );
    can_ok( 'X', 'VERSION' );
};

# OS別のUnicode処理
test 'OS別のUnicode処理' => sub {
    if ( $^O eq 'MSWin32' ) {

        # Windows の場合: Win32::Unicode::Native が読み込まれているか確認
        ok( $INC{'Win32/Unicode/Native.pm'},
            'Win32::Unicode::Native is loaded (Windows)' );
    }
    else {
        # Linux/Mac の場合: STDOUT が UTF-8 レイヤーを持っているか確認（utf8::all の効果）
        my $layers = join ' ', PerlIO::get_layers(STDOUT);
        like( $layers, qr/utf-?8/i,
            'STDOUT has UTF-8 layer (utf8::all effect)' );
    }
};

done_testing;
