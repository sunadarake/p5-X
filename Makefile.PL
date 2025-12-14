use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker;

# プラットフォーム別の依存関係を設定
my %prereq_pm = (
    'strict'     => 0,
    'warnings'   => 0,
    'HTTP::Tiny' => 0,
    'URI'        => 0,
);

# Linux/Mac用のUnicode処理
if ($^O ne 'MSWin32') {
    $prereq_pm{'utf8::all'} = 0;
}
# Windows用のUnicode処理
# Win32::Unicode::Nativeは git@github.com:sunadarake/p5-win-unicode.git から手動インストール
elsif ($^O eq 'MSWin32') {
    $prereq_pm{'Win32::Unicode::Native'} = 0;
}

WriteMakefile(
    NAME             => 'X',
    VERSION_FROM     => 'lib/X.pm',
    ABSTRACT         => 'Perl module X',
    AUTHOR           => 'Your Name <you@example.com>',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.008001',
    PREREQ_PM        => \%prereq_pm,
    TEST_REQUIRES => {
        'Test::More' => '0.98',
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/yourusername/p5-X.git',
                web  => 'https://github.com/yourusername/p5-X',
            },
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'X-*' },
);
