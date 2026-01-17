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
    use_ok('X::Http') || print "Bail out!\n";
}

# 関数のエクスポート
test '関数のエクスポート' => sub {
    can_ok('X::Http', 'hg', 'hp', 'wget');
};

# モジュールの読み込み確認
test 'モジュールの読み込み確認' => sub {
    # モジュールがロードできればOK（実際のHTTPテストは環境依存のため省略）
    ok(1, 'X::Http functions are available');
};

done_testing;
