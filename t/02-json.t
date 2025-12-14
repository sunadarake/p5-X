use strict;
use warnings;
use utf8;
use Test::More tests => 7;
use File::Temp qw(tempdir);
use File::Spec;

BEGIN {
    use_ok('X::Json') || print "Bail out!\n";
}

can_ok('X::Json', 'jg', 'jp');

# テスト用の一時ディレクトリ
my $tmpdir = tempdir(CLEANUP => 1);
my $test_file = File::Spec->catfile($tmpdir, 'test.json');

# jp: JSONファイルの書き込みテスト（ハッシュ）
my $hash_data = { name => "テスト", value => 123, items => ["a", "b", "c"] };
ok(jp($test_file, $hash_data), 'jp writes hash data');
ok(-f $test_file, 'JSON file created');

# jg: JSONファイルの読み込みテスト
my $loaded_data = jg($test_file);
is_deeply($loaded_data, $hash_data, 'jg reads hash data correctly');

# UTF-8と日本語のテスト
is($loaded_data->{name}, "テスト", 'Japanese text handled correctly');

# jp: 配列データのテスト
my $array_data = ["項目1", "項目2", { key => "値" }];
my $array_file = File::Spec->catfile($tmpdir, 'array.json');
jp($array_file, $array_data);
my $loaded_array = jg($array_file);
is_deeply($loaded_array, $array_data, 'Array data handled correctly');
