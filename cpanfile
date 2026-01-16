requires 'perl', '5.010';
requires 'HTTP::Tiny';
requires 'URI';
requires 'Import::Into';
requires 'File::Find::utf8',
    git => 'git@github.com:sunadarake/File-Find-utf8.git';
requires 'Cwd::utf8',
    git => 'git@github.com:sunadarake/Cwd-utf8.git';

# Linux/Mac用のUnicode処理
on '!MSWin32' => sub {
    requires 'utf8::all';
};

# Windows用のUnicode処理
# git@github.com:sunadarake/p5-win-unicode.git からインストール
on 'MSWin32' => sub {
    requires 'Win32::Unicode',
        git => 'git@github.com:sunadarake/p5-win-unicode.git';
};
