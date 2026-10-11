# Setup portable opencode config on Windows 11.
# Run in PowerShell 7: irm https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/scripts/install-windows.ps1 | iex
# Or from a clone: pwsh -File scripts/install-windows.ps1
# Re-run is safe. The script skips done steps.
$ErrorActionPreference = 'Stop'

$ConfigDir = Join-Path $HOME '.config\opencode'
$RepoUrl = 'https://github.com/ixynrs/opencode-config-private.git'
$NodeMajorWant = 22

function Refresh-Path {
  $machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [System.Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = "$machine;$user"
}

Write-Host '[1/8] Check PowerShell 7'
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host 'This setup needs PowerShell 7. Install it, then re-run in pwsh.'
  winget install --exact --id Microsoft.PowerShell --source winget --accept-source-agreements --accept-package-agreements
  exit 1
}

Write-Host '[2/8] Check winget'
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw 'winget is absent. Install App Installer from the Store, then re-run.'
}

Write-Host '[3/8] Check git'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  winget install --exact --id Git.Git --source winget --accept-source-agreements --accept-package-agreements
  Refresh-Path
}
git --version

Write-Host '[4/8] Check Node'
$NeedNode = $true
if (Get-Command node -ErrorAction SilentlyContinue) {
  $Major = (node -p "process.versions.node.split('.')[0]").Trim()
  if ($Major -eq "$NodeMajorWant") { $NeedNode = $false }
  else { Write-Host "Found Node major $Major, want $NodeMajorWant. Upgrade." }
}
if ($NeedNode) {
  winget install --exact --id OpenJS.NodeJS.LTS --source winget --accept-source-agreements --accept-package-agreements
  Refresh-Path
}
node -v
npm -v

Write-Host '[5/8] Check uv for uvx'
if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
  irm https://astral.sh/uv/install.ps1 | iex
  Refresh-Path
  $env:Path = "$HOME\.local\bin;$env:Path"
}
uvx --version

Write-Host '[6/8] Check config dir'
$Existed = Test-Path (Join-Path $ConfigDir '.git')
if (-not $Existed) {
  New-Item -ItemType Directory -Force (Split-Path $ConfigDir) | Out-Null
  if (Test-Path $ConfigDir) {
    $stamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
    Move-Item $ConfigDir (Join-Path $HOME "opencode-backup-$stamp")
  }
  git clone $RepoUrl $ConfigDir
}
Set-Location $ConfigDir
if ($Existed) {
  git pull --rebase
  if ($LASTEXITCODE -ne 0) { Write-Host 'Pull had conflicts. Fix by hand, then re-run.' }
}

Write-Host '[7/8] Install node deps'
if (Test-Path 'package-lock.json') { npm ci || npm install }
elseif (Test-Path 'package.json') { npm install }
else { Write-Host 'No package.json. Skip dep install.' }

Write-Host '[8/8] Install Playwright browser'
npx -y playwright install chromium

Write-Host 'Done. Run checks:'
Write-Host '  opencode --version'
Write-Host "  pwsh -File $ConfigDir\scripts\check-windows.ps1"
