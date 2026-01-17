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
    use_ok('X::Shell') || print "Bail out!\n";
}

# which (コマンドの検索)
test 'which (コマンドの検索)' => sub {
    # perl自体は確実に存在するはず
    my $perl_path = which('perl');
    ok(defined $perl_path && -f $perl_path, 'which finds perl command');

    # 存在しないコマンド
    my $nonexistent = which('nonexistent_command_xyz123');
    is($nonexistent, undef, 'which returns undef for nonexistent command');
};

# sh (コマンドの実行)
test 'sh (コマンドの実行)' => sub {
    # スカラコンテキスト
    my $output = sh('perl', '-e', 'print "hello"');
    is($output, 'hello', 'sh executes command and returns output in scalar context');

    # リストコンテキスト（成功時）
    my ($out, $code) = sh('perl', '-e', 'print "test"; exit 0');
    is($out, 'test', 'sh returns output in list context');
    is($code, 0, 'sh returns exit code 0 for successful command');

    # 終了コード非ゼロ
    my ($err_out, $err_code) = sh('perl', '-e', 'exit 42');
    is($err_code, 42, 'sh returns correct non-zero exit code');
};

# 関数のエクスポート
test '関数のエクスポート' => sub {
    can_ok('X::Shell', 'which', 'sh');
};

done_testing;
