
package X::Json;

use strict;
use warnings;
use utf8;

use JSON::PP;
use File::Basename qw(dirname);

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(jg jp);

# OS判定
my $IS_WIN;
BEGIN {
    $IS_WIN = ( $^O eq 'MSWin32' );
    if ($IS_WIN) {
        require Win32::Unicode::Dir;
        require Win32::Unicode::File;
        Win32::Unicode::Dir->import(qw(mkpathW));
    }
    else {
        require File::Path;
        File::Path->import(qw(make_path));
    }
}

# JSONファイルを取得してPerlの変数として返す
sub jg {
    my ($filepath) = @_;
    return undef unless -f $filepath;

    my $json_text;
    if ($IS_WIN) {
        my $fh = Win32::Unicode::File->new( '<', $filepath )
          or die "Cannot open $filepath: $!";
        $json_text = $fh->slurp;
        $fh->close;
    }
    else {
        open my $fh, '<', $filepath or die "Cannot open $filepath: $!";
        $json_text = do { local $/; <$fh> };
        close $fh;
    }

    my $json = JSON::PP->new->utf8(1);
    return $json->decode($json_text);
}

# JSONコンテンツをファイルに保存する
sub jp {
    my ( $filepath, $content ) = @_;

    # ディレクトリが存在しない場合は作成
    my $dir = dirname($filepath);
    if ( !-d $dir ) {
        if ($IS_WIN) {
            mkpathW($dir);
        }
        else {
            make_path($dir);
        }
    }

    my $json      = JSON::PP->new->utf8(1)->pretty(1)->canonical(1);
    my $json_text = $json->encode($content);

    if ($IS_WIN) {
        my $fh = Win32::Unicode::File->new( '>', $filepath )
          or die "Cannot write to $filepath: $!";
        $fh->print($json_text);
        $fh->close;
    }
    else {
        open my $fh, '>', $filepath or die "Cannot write to $filepath: $!";
        print $fh $json_text;
        close $fh;
    }

    return 1;
}

1;
