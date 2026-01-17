package X::File;

use strict;
use warnings;
use utf8;

use File::Spec;
use Encode;    # <-- 追加

our $VERSION = '0.01';

use Exporter 'import';
our @EXPORT = qw(ff ffa ffr fg fp md rm cp mv);


BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Dir;
        require Win32::Unicode::File;
        require File::Basename;
        Win32::Unicode::Dir->import(qw(findW mkpathW rmtreeW getcwdW file_type));
        Win32::Unicode::File->import(qw(unlinkW copyW moveW));
    }
    else {
        require File::Find::utf8;
        require File::Path;
        require File::Copy;
        require Cwd::utf8;
        require File::Basename;
        File::Path->import(qw(make_path remove_tree));
        File::Copy->import(qw(copy move));
        Cwd::utf8->import(qw(abs_path));
    }
}

# 絶対パスを取得
sub _abs_path {
    my ($path) = @_;
    if ($^O eq 'MSWin32') {

        # --- 修正ポイント 1: rel2abs ---
        my $cwd        = getcwdW();
        my $path_bytes = Encode::encode( 'cp932', $path );
        my $cwd_bytes  = Encode::encode( 'cp932', $cwd );

        my $abs_bytes = File::Spec->rel2abs( $path_bytes, $cwd_bytes );

        return Encode::decode( 'cp932', $abs_bytes );
    }
    else {
        return abs_path($path);
    }
}

# ディレクトリのファイルを再帰的に取得（絶対パス）
sub ff {
    my ($root_dir) = @_;

    if ($^O eq 'MSWin32') {
        return wantarray ? () : [] unless file_type('d', $root_dir);
        my $abs_root = _abs_path($root_dir);
        my @files;
        findW(
            sub {
                my $name = $Win32::Unicode::Dir::name;
                push @files, $name if file_type('f', $name);
            },
            $abs_root
        );
        return wantarray ? @files : \@files;
    }
    else {
        return wantarray ? () : [] unless -d $root_dir;
        my $abs_root = _abs_path($root_dir);
        my @files;
        File::Find::find(
            sub {
                push @files, $File::Find::name if -f;
            },
            $abs_root
        );
        return wantarray ? @files : \@files;
    }
}

# ff と同じ
sub ffa {
    return ff(@_);
}

# root_dir を基準とした相対パスの配列を返す
sub ffr {
    my ($root_dir) = @_;

    if ($^O eq 'MSWin32') {
        return wantarray ? () : [] unless file_type('d', $root_dir);
        my $abs_root = _abs_path($root_dir);
        my @files;
        findW(
            sub {
                my $name = $Win32::Unicode::Dir::name;
                if ( file_type('f', $name) ) {
                    my $name_bytes = Encode::encode( 'cp932', $name );
                    my $root_bytes = Encode::encode( 'cp932', $abs_root );
                    my $rel_bytes =
                      File::Spec->abs2rel( $name_bytes, $root_bytes );
                    my $rel_path = Encode::decode( 'cp932', $rel_bytes );
                    push @files, $rel_path;
                }
            },
            $abs_root
        );
        return wantarray ? @files : \@files;
    }
    else {
        return wantarray ? () : [] unless -d $root_dir;
        my $abs_root = _abs_path($root_dir);
        my @files;
        File::Find::find(
            sub {
                if (-f) {
                    my $rel_path =
                      File::Spec->abs2rel( $File::Find::name, $abs_root );
                    push @files, $rel_path;
                }
            },
            $abs_root
        );
        return wantarray ? @files : \@files;
    }
}

# ファイルの中身を返す
sub fg {
    my ($filepath) = @_;

    # ファイル存在チェック (Windows日本語パス対応)
    if ($^O eq 'MSWin32') {
        return undef unless file_type('f', $filepath);
        my $fh = Win32::Unicode::File->new( '<:utf-8', $filepath )
          or die "Cannot open $filepath: $!";
        my $content = $fh->slurp;
        $fh->close;
        return $content;
    }
    else {
        return undef unless -f $filepath;
        open my $fh, '<', $filepath or die "Cannot open $filepath: $!";
        my $content = do { local $/; <$fh> };
        close $fh;
        return $content;
    }
}

# ファイルに$contentを保存する
sub fp {
    my ( $filepath, $content ) = @_;

    # ディレクトリが存在しない場合は作成
    my $dir = _dirname($filepath);
    my $dir_exists = ($^O eq 'MSWin32') ? file_type('d', $dir) : -d $dir;
    md($dir) unless $dir_exists;

    if ($^O eq 'MSWin32') {
        my $fh = Win32::Unicode::File->new( '>:utf-8', $filepath )
          or die "Cannot write to $filepath: $!";
        $fh->print($content);
        $fh->close;
    }
    else {
        open my $fh, '>', $filepath or die "Cannot write to $filepath: $!";
        print $fh $content;
        close $fh;
    }

    return 1;
}

# ディレクトリを再帰的に作成
sub md {
    my ($dir) = @_;

    if ($^O eq 'MSWin32') {
        return 1 if file_type('d', $dir);
        mkpathW($dir);
    }
    else {
        return 1 if -d $dir;
        make_path($dir);
    }
    return 1;
}

# ファイルまたはディレクトリを削除（ディレクトリは再帰的）
sub rm {
    my ($path) = @_;

    if ($^O eq 'MSWin32') {
        if ( file_type('d', $path) ) {
            rmtreeW($path);
        }
        elsif ( file_type('f', $path) ) {
            unlinkW($path) or die "Cannot remove $path: $!";
        }
    }
    else {
        if ( -d $path ) {
            remove_tree($path);
        }
        elsif ( -f $path ) {
            unlink $path or die "Cannot remove $path: $!";
        }
    }

    return 1;
}

# ファイルをコピー（$destのディレクトリがない場合は作成）
sub cp {
    my ( $src, $dest ) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = _dirname($dest);
    my $dir_exists = ($^O eq 'MSWin32') ? file_type('d', $dest_dir) : -d $dest_dir;
    md($dest_dir) unless $dir_exists;

    if ($^O eq 'MSWin32') {
        copyW( $src, $dest ) or die "Cannot copy $src to $dest: $!";
    }
    else {
        copy( $src, $dest ) or die "Cannot copy $src to $dest: $!";
    }
    return 1;
}

# ファイルを移動（$destのディレクトリがない場合は作成）
sub mv {
    my ( $src, $dest ) = @_;

    # destのディレクトリが存在しない場合は作成
    my $dest_dir = _dirname($dest);
    my $dir_exists = ($^O eq 'MSWin32') ? file_type('d', $dest_dir) : -d $dest_dir;
    md($dest_dir) unless $dir_exists;

    if ($^O eq 'MSWin32') {
        moveW( $src, $dest ) or die "Cannot move $src to $dest: $!";
    }
    else {
        move( $src, $dest ) or die "Cannot move $src to $dest: $!";
    }
    return 1;
}

# ヘルパー: ディレクトリ名を取得
sub _dirname {
    my ($path) = @_;
    return File::Basename::dirname($path);
}

1;
