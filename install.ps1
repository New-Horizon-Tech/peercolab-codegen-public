# Installer for peercolab (PeerColab Codegen) on Windows.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/New-Horizon-Tech/peercolab-codegen-public/main/install.ps1 | iex
#
# Environment overrides:
#   PEERCOLAB_INSTALL_DIR   Install directory (default: $env:LOCALAPPDATA\Programs\peercolab).
#   PEERCOLAB_VERSION       Release tag to install (default: latest).

$ErrorActionPreference = 'Stop'

$repo = 'New-Horizon-Tech/peercolab-codegen-public'
$version = if ($env:PEERCOLAB_VERSION) { $env:PEERCOLAB_VERSION } else { 'latest' }

# Detect OS architecture. PROCESSOR_ARCHITECTURE reflects the *current process* arch,
# so on 32-bit PowerShell hosted under WOW64 we consult PROCESSOR_ARCHITEW6432 instead.
$arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
if (-not $arch) {
    try { $arch = [string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture } catch {}
}
if (-not $arch) { $arch = '<unknown>' }

if ($arch -ne 'AMD64' -and $arch -ne 'X64') {
    Write-Error "Unsupported architecture: $arch (only win-x64 is available)."
    exit 1
}

$asset = 'peercolab-win-x64.exe'
if ($version -eq 'latest') {
    $url = "https://github.com/$repo/releases/latest/download/$asset"
} else {
    $url = "https://github.com/$repo/releases/download/$version/$asset"
}

$installDir = if ($env:PEERCOLAB_INSTALL_DIR) {
    $env:PEERCOLAB_INSTALL_DIR
} else {
    Join-Path $env:LOCALAPPDATA 'Programs\peercolab'
}
$target = Join-Path $installDir 'peercolab.exe'

Write-Host "Installing peercolab (win-x64) to $target"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# If peercolab is currently running, the overwrite will fail — point that out clearly.
$tmp = Join-Path $env:TEMP ("peercolab-" + [guid]::NewGuid().ToString('N') + '.exe')
try {
    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing

    Move-Item -Force -Path $tmp -Destination $target
} catch {
    if (Test-Path $tmp) { Remove-Item -Force $tmp -ErrorAction SilentlyContinue }
    throw
}

Write-Host "Installed: $target"

# Add to user PATH if not already present.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$paths = @()
if ($userPath) { $paths = $userPath -split ';' | Where-Object { $_ -ne '' } }
$alreadyOnPath = $paths | Where-Object { $_.TrimEnd('\') -ieq $installDir.TrimEnd('\') }

if (-not $alreadyOnPath) {
    $newPath = if ($userPath) { "$userPath;$installDir" } else { $installDir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host ""
    Write-Host "Added $installDir to your user PATH."
    Write-Host "Open a new terminal to pick up the change, then run: peercolab"
} else {
    Write-Host ""
    Write-Host "Run: peercolab"
}
