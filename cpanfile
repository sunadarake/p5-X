requires 'perl', '5.010';
requires 'HTTP::Tiny';
requires 'URI';
requires 'Import::Into';

# Windows以外
unless ($^O eq 'MSWin32') {
    requires 'utf8::all';
    requires 'File::Find::utf8',
        git => 'https://github.com/sunadarake/File-Find-utf8.git';
    requires 'Cwd::utf8',
        git => 'https://github.com/sunadarake/Cwd-utf8.git';
}

# Windows
if ($^O eq 'MSWin32') {
    requires 'Win32::Unicode',
        git => 'https://github.com/sunadarake/p5-win-unicode.git';
}
