
package X::Shell;

use strict;
use warnings;
use utf8;
use File::Spec;

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(which sh);

# コマンドのフルパスを返す（見つからない場合はundef）
sub which {
    my ($cmd) = @_;
    return undef unless defined $cmd;

    # PATH環境変数を取得
    my $path_sep = $^O eq 'MSWin32' ? ';' : ':';
    my @paths = split /$path_sep/, $ENV{PATH} || '';

    # Windows用の実行可能拡張子
    my @exts = ('');
    if ($^O eq 'MSWin32') {
        push @exts, qw(.exe .bat .cmd .com);
    }

    # 各PATHディレクトリで検索
    for my $dir (@paths) {
        next unless -d $dir;

        for my $ext (@exts) {
            my $full_path = File::Spec->catfile($dir, $cmd . $ext);
            return $full_path if -f $full_path && -x $full_path;
        }
    }

    return undef;
}

# コマンドを実行して結果を返す
# スカラコンテキスト: 出力のみ
# リストコンテキスト: (出力, 終了コード)
sub sh {
    my @args = @_;
    return '' unless @args;

    # コマンドを構築
    my $cmd = join ' ', map { _quote_arg($_) } @args;

    # コマンドを実行して出力を取得
    my $output = `$cmd 2>&1`;
    my $exit_code = $? >> 8;

    # コンテキストに応じて返す
    return wantarray ? ($output, $exit_code) : $output;
}

# 引数をクォートする（スペースや特殊文字を含む場合）
sub _quote_arg {
    my ($arg) = @_;
    return '""' unless defined $arg;

    # スペースや特殊文字が含まれている場合はクォート
    if ($arg =~ /[\s\$\@\%\&\|\<\>\(\)\[\]\{\}\;\'\"\`\\\*\?]/) {
        if ($^O eq 'MSWin32') {
            # Windowsの場合
            $arg =~ s/"/\\"/g;
            return qq{"$arg"};
        } else {
            # Unix系の場合
            $arg =~ s/'/'\\''/g;
            return qq{'$arg'};
        }
    }

    return $arg;
}

1;
