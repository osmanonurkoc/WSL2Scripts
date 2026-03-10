<#
    === TEST ENVIRONMENT CLEANUP SCRIPT ===
    1. Unregisters 'Mint' WSL distribution (Deletes linux data).
    2. Removes installation folder (C:\Program Files\WSLMint).
    3. Cleans Registry RunOnce key.
    4. Disables Windows WSL Features.
#>

# --- 1. ADMIN PRIVILEGES CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
    exit
}

Write-Host "=== STARTING CLEANUP ===" -ForegroundColor Cyan

# --- 2. UNREGISTER DISTRO ---
Write-Host "`n[1/4] Removing WSL Distribution..." -ForegroundColor Gray
if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    # Mint.exe usually registers as "Mint" or the folder name.
    # Trying generic names used by this port.
    try {
        wsl --unregister Mint 2>$null
        Write-Host "Distro 'Mint' unregistered." -ForegroundColor Green
    } catch {
        Write-Host "Distro not found or already removed." -ForegroundColor Yellow
    }
}

# --- 3. DELETE FILES ---
$InstallPath = "C:\Program Files\WSLMint"
Write-Host "`n[2/4] Removing Files ($InstallPath)..." -ForegroundColor Gray
if (Test-Path $InstallPath) {
    try {
        Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop
        Write-Host "Installation folder deleted." -ForegroundColor Green
    } catch {
        Write-Host "Error deleting folder: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Folder not found." -ForegroundColor Yellow
}

# --- 4. CLEAN REGISTRY ---
Write-Host "`n[3/4] Cleaning Registry (RunOnce)..." -ForegroundColor Gray
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$KeyName = "ResumeWSLMintSetup"

if (Get-ItemProperty -Path $RegPath -Name $KeyName -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $RegPath -Name $KeyName
    Write-Host "Registry key removed." -ForegroundColor Green
} else {
    Write-Host "Registry key not found." -ForegroundColor Yellow
}

# --- 5. DISABLE WINDOWS FEATURES ---
Write-Host "`n[4/4] Disabling Windows Features..." -ForegroundColor Cyan
Write-Host "This ensures a true 'fresh install' simulation." -ForegroundColor Gray

$features = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
$restartNeeded = $false

foreach ($feat in $features) {
    $status = Get-WindowsOptionalFeature -Online -FeatureName $feat
    if ($status.State -eq "Enabled") {
        Write-Host "Disabling: $feat..." -ForegroundColor Yellow
        Disable-WindowsOptionalFeature -Online -FeatureName $feat -NoRestart | Out-Null
        $restartNeeded = $true
    } else {
        Write-Host "$feat is already disabled." -ForegroundColor Green
    }
}

Write-Host "`n-----------------------------------------------------"
Write-Host "CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "-----------------------------------------------------"

if ($restartNeeded) {
    Write-Host "A System Restart is required to fully disable features." -ForegroundColor Red
    $choice = Read-Host "Restart now? (Y/N)"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Restart-Computer
    }
} else {
    Read-Host "Press Enter to exit..."
}
