use strict;
use warnings;
use Test::More tests => 11;
use File::Temp qw(tempdir);
use File::Spec;

BEGIN {
    use_ok('X::Basename') || print "Bail out!\n";
}

# bn (basename) テスト
is(bn('/foo/bar/baz.txt'), 'baz.txt', 'bn returns basename');
is(bn('/foo/bar/'), 'bar', 'bn handles directory path');

# dn (dirname) テスト
is(dn('/foo/bar/baz.txt'), '/foo/bar', 'dn returns dirname');

# pwd テスト
my $cwd = pwd();
ok(defined $cwd && length($cwd) > 0, 'pwd returns current directory');

# rp / abs テスト
my $tempdir = tempdir(CLEANUP => 1);
my $test_file = File::Spec->catfile($tempdir, 'test.txt');
open my $fh, '>', $test_file or die $!;
close $fh;

my $abs_path = rp($test_file);
ok(defined $abs_path && File::Spec->file_name_is_absolute($abs_path), 'rp returns absolute path');

my $abs_path2 = abs($test_file);
is($abs_path2, $abs_path, 'abs is alias of rp');

# rel テスト
chdir $tempdir or die $!;
my $rel_path = rel($test_file);
is($rel_path, 'test.txt', 'rel returns relative path from current dir');

my $rel_path2 = rel($test_file, $tempdir);
is($rel_path2, 'test.txt', 'rel returns relative path with explicit root');

# エクスポートテスト
can_ok('X::Basename', 'bn', 'dn', 'rp', 'abs', 'rel', 'pwd');

ok(defined $X::Basename::VERSION, 'VERSION is defined');
