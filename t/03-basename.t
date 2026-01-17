use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use utf8;
use Encode qw(decode encode);

BEGIN {
    use_ok('X::Basename') || print "Bail out!\n";
}

# Windows用エンコード/デコードヘルパー
sub xencode { return $^O eq 'MSWin32' ? encode( 'cp932', $_[0] ) : $_[0]; }
sub xdecode { return $^O eq 'MSWin32' ? decode( 'cp932', $_[0] ) : $_[0]; }
# パス区切り文字を返すヘルパー
sub path_sep { return $^O eq 'MSWin32' ? '\\' : '/'; }

# subtest のシンプルなラッパー
sub test {
    my ( $name, $code ) = @_;
    my $encoded_name =
      $^O eq 'MSWin32' ? encode( 'cp932', $name ) : encode( 'utf8', $name );
    subtest $encoded_name => $code;
}

my $tempdir = xdecode( tempdir( CLEANUP => 1 ) );

# bn (basename)
test 'bn (basename)' => sub {
    is( bn('/foo/bar/baz.txt'), 'baz.txt', 'bn returns basename' );
    is( bn('/foo/bar/'),        'bar',     'bn handles directory path' );
};

# dn (dirname)
test 'dn (dirname)' => sub {
    is( dn('/foo/bar/baz.txt'), '/foo/bar', 'dn returns dirname' );
};

# pwd (カレントディレクトリ)
test 'pwd (カレントディレクトリ)' => sub {
    my $cwd = pwd();
    ok( defined $cwd && length($cwd) > 0, 'pwd returns current directory' );
};

# rp / abs (絶対パス)
test 'rp / abs (絶対パス)' => sub {
    my $tempdir_file = $tempdir . path_sep() . 'test.txt';

    open my $fh, '>', xencode($tempdir_file) or die "Cannot open $tempdir_file: $!";
    close $fh;

    my $test_file_utf8 = $tempdir_file;

    my $abs_path = rp($test_file_utf8);
    ok( defined $abs_path && File::Spec->file_name_is_absolute($abs_path),
        'rp returns absolute path' );

    my $abs_path2 = abs($test_file_utf8);
    is( $abs_path2, $abs_path, 'abs is alias of rp' );
};

# rel (相対パス)
test 'rel (相対パス)' => sub {
    my $tempdir_file = $tempdir . path_sep() . 'test.txt';

    chdir xencode($tempdir) or die $!;

    my $rel_path = rel($tempdir_file);
    is( $rel_path, 'test.txt', 'rel returns relative path from current dir' );

    my $rel_path2 = rel( $tempdir_file, $tempdir );
    is( $rel_path2, 'test.txt', 'rel returns relative path with explicit root' );
};

# 日本語パス
test '日本語パス' => sub {
    my $jp_dir_utf8 = File::Spec->catdir( $tempdir, 'テスト' );
    mkdir xencode($jp_dir_utf8)
      or die "Cannot mkdir " . xencode($jp_dir_utf8) . ": $!";

    my $jp_file_utf8 = File::Spec->catfile( $jp_dir_utf8, '日本語.txt' );
    open my $fh2, '>', xencode($jp_file_utf8)
      or die "Cannot open" . xencode($jp_file_utf8) . " : $!";
    close $fh2;

    is( bn($jp_file_utf8), '日本語.txt', 'bn handles Japanese filename' );
    is( bn($jp_dir_utf8),  'テスト',     'bn handles Japanese directory' );

    my $jp_abs = rp($jp_file_utf8);
    ok( defined $jp_abs && File::Spec->file_name_is_absolute($jp_abs),
        'rp handles Japanese path' );
};

# 関数のエクスポート
test '関数のエクスポート' => sub {
    can_ok( 'X::Basename', 'bn', 'dn', 'rp', 'abs', 'rel', 'pwd' );
};

done_testing;
