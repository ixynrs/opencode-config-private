# Check portable opencode config on Windows.
# Run: pwsh -File scripts/check-windows.ps1
$script:Fail = 0

function Check-Cmd($Name, $Cmd) {
  if (Get-Command $Cmd -ErrorAction SilentlyContinue) { Write-Host "OK: $Name" }
  else { Write-Host "FAIL: $Name"; $script:Fail++ }
}

$ConfigDir = Join-Path $HOME '.config\opencode'

Write-Host 'Check base tools'
Check-Cmd 'git' 'git'
Check-Cmd 'node' 'node'
Check-Cmd 'npm' 'npm'
Check-Cmd 'uvx' 'uvx'
Check-Cmd 'npx' 'npx'

Write-Host 'Check config files'
foreach ($f in @('opencode.jsonc', 'cli.json', 'AGENTS.md')) {
  if (Test-Path (Join-Path $ConfigDir $f)) { Write-Host "OK: $f" }
  else { Write-Host "FAIL: $f"; $script:Fail++ }
}

$jsonc = Join-Path $ConfigDir 'opencode.jsonc'
if (Test-Path $jsonc) {
  if (Select-String -Path $jsonc -Pattern 'C:/' -Quiet) {
    Write-Host 'FAIL: Windows path C:/ found in opencode.jsonc'; $script:Fail++
  }
  else { Write-Host 'OK: no Windows path in opencode.jsonc' }
}

if (Test-Path (Join-Path $ConfigDir 'service.json')) {
  Write-Host 'OK: service.json exists (local secret, never commit)'
}
else { Write-Host 'FAIL: service.json absent - copy from vault, see README'; $script:Fail++ }

Write-Host 'Check opencode binary'
Check-Cmd 'opencode' 'opencode'

Write-Host "Result: fail count $script:Fail"
if ($script:Fail -gt 0) { exit 1 }
