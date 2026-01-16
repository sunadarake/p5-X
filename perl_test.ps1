# perlのテストをする
param(
    [string]$t = "t/"
)

# localディレクトリの存在確認
if (-not (Test-Path "local"))
{
    Write-Host "Installing dependencies from cpanfile..."
    $env:PERL_MM_USE_DEFAULT = "1"
    cpanm --quiet --notest --installdeps -l local .
} else
{
    Write-Host "local directory exists. Skipping dependency installation."
}

# テスト実行
Write-Host "`nRunning tests..."
prove $t
