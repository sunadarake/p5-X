use strict;
use warnings;
use Test::More tests => 8;

BEGIN {
    use_ok('X::Shell') || print "Bail out!\n";
}

# which テスト（perl自体は確実に存在するはず）
my $perl_path = which('perl');
ok(defined $perl_path && -f $perl_path, 'which finds perl command');

# 存在しないコマンド
my $nonexistent = which('nonexistent_command_xyz123');
is($nonexistent, undef, 'which returns undef for nonexistent command');

# sh テスト（スカラコンテキスト）
my $output = sh('perl', '-e', 'print "hello"');
is($output, 'hello', 'sh executes command and returns output in scalar context');

# sh テスト（リストコンテキスト）
my ($out, $code) = sh('perl', '-e', 'print "test"; exit 0');
is($out, 'test', 'sh returns output in list context');
is($code, 0, 'sh returns exit code 0 for successful command');

# sh テスト（終了コード非ゼロ）
my ($err_out, $err_code) = sh('perl', '-e', 'exit 42');
is($err_code, 42, 'sh returns correct non-zero exit code');

# エクスポートテスト
can_ok('X::Shell', 'which', 'sh');
