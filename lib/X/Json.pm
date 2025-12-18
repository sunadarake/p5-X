
package X::Json;

use strict;
use warnings;
use utf8;

BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Native;
        Win32::Unicode::Native->import();
    } else {
        require utf8::all;
        utf8::all->import();
    }
}

use JSON::PP;
use File::Basename qw(dirname);
use File::Path qw(make_path);

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(jg jp);

# JSONファイルを取得してPerlの変数として返す
sub jg {
    my ($filepath) = @_;
    return undef unless -f $filepath;

    open my $fh, '<', $filepath or die "Cannot open $filepath: $!";
    my $json_text = do { local $/; <$fh> };
    close $fh;

    my $json = JSON::PP->new->utf8(0);
    return $json->decode($json_text);
}

# JSONコンテンツをファイルに保存する
sub jp {
    my ($filepath, $content) = @_;

    # ディレクトリが存在しない場合は作成
    my $dir = dirname($filepath);
    make_path($dir) unless -d $dir;

    my $json = JSON::PP->new->utf8(0)->pretty(1)->canonical(1);
    my $json_text = $json->encode($content);

    open my $fh, '>', $filepath or die "Cannot write to $filepath: $!";
    print $fh $json_text;
    close $fh;

    return 1;
}

1;
