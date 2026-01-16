#!/bin/sh
# perlのテストをする

# 引数のデフォルト値
t="${1:-t/}"

# localディレクトリの存在確認
if [ ! -d "local" ]; then
    echo "Installing dependencies from cpanfile..."
    PERL_MM_USE_DEFAULT=1 cpanm --quiet --notest --installdeps -l local .
else
    echo "local directory exists. Skipping dependency installation."
fi

# テスト実行
echo ""
echo "Running tests..."
prove "$t"
