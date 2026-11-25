# 独立仓库 + Pages 方案：一键推送并开启 Pages（PowerShell 版）
# 在项目目录右键"使用 PowerShell 打开"，或在 PowerShell 中 Set-Location 到本目录后运行：.\deploy.ps1

$ErrorActionPreference = "Stop"
$OWNER = "zzh-persistence"
$REPO  = "yaml-config"
$DIR   = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-Location $DIR
Write-Host "[1/5] 检查 GitHub CLI 是否安装" -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "未找到 gh CLI。请先安装：winget install GitHub.cli" -ForegroundColor Red
    Write-Host "安装后重新打开 PowerShell 再运行本脚本。" -ForegroundColor Red
    exit 1
}

Write-Host "[2/5] 检查 GitHub 登录状态" -ForegroundColor Cyan
$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "未登录 GitHub。即将打开浏览器授权窗口，请按提示完成登录。" -ForegroundColor Yellow
    gh auth login
    if ($LASTEXITCODE -ne 0) { Write-Host "登录失败，终止。" -ForegroundColor Red; exit 1 }
}

Write-Host "[3/5] 创建公开仓库并推送" -ForegroundColor Cyan
gh repo create $REPO --public --description "Migrated subscription config mirror" --source=. --remote=origin --push 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote add origin "https://github.com/$OWNER/$REPO.git" 2>$null
    git remote set-url origin "https://github.com/$OWNER/$REPO.git"
    git push -u origin HEAD:main
    if ($LASTEXITCODE -ne 0) { Write-Host "推送失败，请检查远程地址或网络。" -ForegroundColor Red; exit 1 }
}

Write-Host "[4/5] 开启 GitHub Pages" -ForegroundColor Cyan
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source={\"branch\":\"main\",\"path\":\"/\"}" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Pages 可能已开启或需手动设置，请检查 Settings > Pages" -ForegroundColor Yellow }

Write-Host "[5/5] 完成。请等待 1-2 分钟后验证以下地址：" -ForegroundColor Green
Write-Host "订阅配置: https://$OWNER.github.io/$REPO/0/0.json"
Write-Host "spider:   https://$OWNER.github.io/$REPO/spider/fan.txt"
