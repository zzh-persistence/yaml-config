# One-click deploy: create repo, push, enable Pages
# Usage: open PowerShell in this folder, run: .\deploy.ps1
# If blocked, run first: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$OWNER = "zzh-persistence"
$REPO  = "yaml-config"
$DIR   = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-Location $DIR

Write-Host "[1/5] Check GitHub CLI" -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "gh CLI not found. Install with:" -ForegroundColor Red
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor Red
    exit 1
}

Write-Host "[2/5] Check GitHub login" -ForegroundColor Cyan
gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in. Opening browser for auth..." -ForegroundColor Yellow
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Login failed. Abort." -ForegroundColor Red
        exit 1
    }
}

Write-Host "[3/5] Create public repo (ignore if exists)" -ForegroundColor Cyan
gh repo create $REPO --public --description "Migrated subscription config mirror" 2>$null | Out-Null

Write-Host "[4/5] Push main branch" -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin "https://github.com/$OWNER/$REPO.git"
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed. Check credentials or network." -ForegroundColor Red
    exit 1
}

Write-Host "[5/5] Enable GitHub Pages" -ForegroundColor Cyan
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pages may already be on, or set manually: Settings > Pages > main/(root)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Wait 1-2 min, then visit:" -ForegroundColor Green
Write-Host "  Config: https://$OWNER.github.io/$REPO/0/0.json"
Write-Host "  Spider: https://$OWNER.github.io/$REPO/spider/fan.txt"
