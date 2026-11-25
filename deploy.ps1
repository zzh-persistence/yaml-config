# 独立仓库 + Pages 方案：一键推送并开启 Pages（PowerShell 版）
# 用法：在本目录打开 PowerShell，运行：.\deploy.ps1
# 若提示执行策略限制，先运行：Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$ErrorActionPreference = "Stop"
$OWNER = "zzh-persistence"
$REPO  = "yaml-config"
$DIR   = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-Location $DIR

Write-Host "[1/5] 检查 GitHub CLI 是否安装" -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "未找到 gh CLI。请先安装：" -ForegroundColor Red
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor Red
    Write-Host "安装后重新打开 PowerShell 再运行本脚本。" -ForegroundColor Red
    exit 1
}

Write-Host "[2/5] 检查 GitHub 登录状态" -ForegroundColor Cyan
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "未登录 GitHub，即将打开浏览器授权窗口。" -ForegroundColor Yellow
    gh auth login
    if ($LASTEXITCODE -ne 0) { Write-Host "登录失败，终止。" -ForegroundColor Red; exit 1 }
}

Write-Host "[3/5] 创建公开仓库" -ForegroundColor Cyan
$repoExists = gh repo view "$OWNER/$REPO" 2>&1 | Out-Null; if ($LASTEXITCODE -eq 0) { $repoExists = $true } else { $repoExists = $false }
if (-not $repoExists) {
    gh repo create $REPO --public --description "Migrated subscription config mirror"
    if ($LASTEXITCODE -ne 0) { Write-Host "仓库创建失败，终止。" -ForegroundColor Red; exit 1 }
}

Write-Host "[4/5] 推送 main 分支" -ForegroundColor Cyan
$remote = git remote get-url origin 2>$null
if (-not $remote) {
    git remote add origin "https://github.com/$OWNER/$REPO.git"
} else {
    git remote set-url origin "https://github.com/$OWNER/$REPO.git"
}
git push -u origin main
if ($LASTEXITCODE -ne 0) { Write-Host "推送失败，请检查网络或凭据。" -ForegroundColor Red; exit 1 }

Write-Host "[5/5] 开启 GitHub Pages" -ForegroundColor Cyan
$pagesBody = @{ source = @{ branch = "main"; path = "/" } } | ConvertTo-Json -Compress
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Pages 可能已开启，或需手动设置：Settings > Pages > Deploy from a branch > main/(root)" -ForegroundColor Yellow }

Write-Host "`n完成。等待 1-2 分钟后访问：" -ForegroundColor Green
Write-Host "  订阅配置: https://$OWNER.github.io/$REPO/0/0.json"
Write-Host "  spider:   https://$OWNER.github.io/$REPO/spider/fan.txt"
