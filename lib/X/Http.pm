
package X::Http;

use strict;
use warnings;
use utf8;
use HTTP::Tiny;
use URI;
use File::Basename qw(dirname basename);
use File::Path qw(make_path);

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(hg hp wget);

# HTTP GETリクエスト
sub hg {
    my ($url, $param, $headers) = @_;
    $param ||= {};
    $headers ||= {};

    # パラメータをクエリ文字列に変換
    if (%$param) {
        my $uri = URI->new($url);
        $uri->query_form($param);
        $url = $uri->as_string;
    }

    my $http = HTTP::Tiny->new;
    my $response = $http->get($url, { headers => $headers });

    die "HTTP GET failed: $response->{status} $response->{reason}\n"
        unless $response->{success};

    return $response->{content};
}

# HTTP PUTリクエスト
sub hp {
    my ($url, $body, $headers) = @_;
    $body ||= {};
    $headers ||= {};

    my $http = HTTP::Tiny->new;
    my $response = $http->put($url, {
        headers => $headers,
        content => ref($body) eq 'HASH' ? _encode_form($body) : $body,
    });

    die "HTTP PUT failed: $response->{status} $response->{reason}\n"
        unless $response->{success};

    return $response->{content};
}

# ファイルをダウンロード
sub wget {
    my ($url, $path) = @_;
    $path ||= '';

    # pathが空の場合、URLからファイル名を取得
    if ($path eq '') {
        my $uri = URI->new($url);
        my @segments = $uri->path_segments;
        $path = $segments[-1] || 'index.html';
    }

    # ディレクトリが指定された場合、URLからファイル名を取得
    if (-d $path) {
        my $uri = URI->new($url);
        my @segments = $uri->path_segments;
        my $filename = $segments[-1] || 'index.html';
        $path = "$path/$filename";
    }

    # ディレクトリが存在しない場合は作成
    my $dir = dirname($path);
    make_path($dir) unless -d $dir;

    # ファイルをダウンロード
    my $http = HTTP::Tiny->new;
    my $response = $http->mirror($url, $path);

    die "Download failed: $response->{status} $response->{reason}\n"
        unless $response->{success};

    return $path;
}

# フォームデータをエンコード
sub _encode_form {
    my ($data) = @_;
    my @parts;
    for my $key (keys %$data) {
        push @parts, _uri_encode($key) . '=' . _uri_encode($data->{$key});
    }
    return join('&', @parts);
}

# URIエンコード
sub _uri_encode {
    my ($str) = @_;
    $str =~ s/([^A-Za-z0-9\-._~])/sprintf("%%%02X", ord($1))/eg;
    return $str;
}

1;
