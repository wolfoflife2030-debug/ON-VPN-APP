# One-shot uploader: pushes the whole project (including hidden .github and .gitignore)
# to GitHub and starts the Android + Windows build by pushing a release tag.
$ErrorActionPreference = "Continue"
# The username in the URL forces Git to sign in as the repo owner, not another cached account.
$Repo = "https://wolfoflife2030-debug@github.com/wolfoflife2030-debug/OnVPN-app.git"
$Tag  = "v0.6.0"

Set-Location $PSScriptRoot

function Run([string]$what, [scriptblock]$cmd) {
    & $cmd
    if ($LASTEXITCODE -ne 0) { throw "FAILED: $what (exit code $LASTEXITCODE)" }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Opening the download page..." -ForegroundColor Yellow
    Start-Process "https://git-scm.com/download/win"
    Write-Host "Install Git (keep the defaults), then run this script again." -ForegroundColor Yellow
    exit 1
}

git config --global core.autocrlf false 2>$null | Out-Null
if (-not (Test-Path ".git")) { Run "git init" { git init -q } }
if (-not (git config user.name))  { git config user.name  "wolfoflife2030-debug" }
if (-not (git config user.email)) { git config user.email "wolfoflife2030-debug@users.noreply.github.com" }

Run "git add" { git add -A }
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { Run "git commit" { git commit -q -m "On Vpn $Tag" } }
Run "branch" { git branch -M main }

if ((git remote) -contains "origin") { git remote remove origin }
Run "remote" { git remote add origin $Repo }

Write-Host "Pushing code. In the sign-in window choose the account: wolfoflife2030-debug" -ForegroundColor Cyan
Run "push main" { git push -u origin main --force }

Write-Host "Starting the build by pushing tag $Tag ..." -ForegroundColor Cyan
Run "tag" { git tag -f $Tag }
Run "push tag" { git push origin $Tag --force }

Write-Host ""
Write-Host "DONE. Watch the build here:" -ForegroundColor Green
Write-Host "  https://github.com/wolfoflife2030-debug/OnVPN-app/actions"
Write-Host "In ~10 minutes the APK and EXE appear here:" -ForegroundColor Green
Write-Host "  https://github.com/wolfoflife2030-debug/OnVPN-app/releases"
