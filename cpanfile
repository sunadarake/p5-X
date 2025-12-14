requires 'perl', '5.010';
requires 'HTTP::Tiny';
requires 'URI';

# Linux/Mac用のUnicode処理
on '!MSWin32' => sub {
    requires 'utf8::all';
};

# Windows用のUnicode処理
# git@github.com:sunadarake/p5-win-unicode.git からインストール
on 'MSWin32' => sub {
    requires 'Win32::Unicode::Native',
        git => 'git@github.com:sunadarake/p5-win-unicode.git';
};
