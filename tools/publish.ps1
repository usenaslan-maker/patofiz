# Builds the site and sends the changes to GitHub (GitHub Pages then updates the site within a few minutes).
param([string]$Message = 'Update schemes')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
& "$PSScriptRoot\build.ps1"

$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) { $git = 'C:\Program Files\Git\cmd\git.exe' }
Push-Location $root
try {
  & $git add -A
  & $git diff --cached --quiet
  if ($LASTEXITCODE -eq 0) { 'Nothing new to publish'; return }
  & $git commit -q -m $Message
  if ($LASTEXITCODE -ne 0) { throw 'git commit failed' }
  & $git push -q origin main
  if ($LASTEXITCODE -ne 0) { throw 'git push failed' }
  'Published'
} finally { Pop-Location }
