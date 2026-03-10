<#
    === LINUX MINT WSL2 AUTOMATED INSTALLER ===
    1. Checks/Enables WSL2 Features.
    2. Sets up Auto-Resume if restart is needed.
    3. Updates WSL Kernel.
    4. Downloads latest Linux Mint WSL2 release & 7za.exe from GitHub (with Progress Bar).
    5. Extracts using downloaded 7za.exe.
    6. Cleans up downloaded temporary files.
    7. Registers the distro (Waits for completion).
    8. Launches the distro.
#>

# --- 1. ADMIN PRIVILEGES CHECK & AUTO-ELEVATION ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
    exit
}

# --- CONFIGURATION ---
$InstallPath = "C:\Program Files\WSLMint"
$ZipName = "LinuxmintWSL2.zip"
$SevenZip = "$PSScriptRoot\7za.exe"
$SevenZipUrl = "https://github.com/osmanonurkoc/WSL2Scripts/releases/download/0.1/7za.exe"
$RepoAPI = "https://api.github.com/repos/sileshn/LinuxmintWSL2/releases/latest"
$RestartRequired = $false

# --- 2. PREPARE ENVIRONMENT (WSL2) ---
Write-Host "`n[STEP 1/6] Checking WSL2 Environment..." -ForegroundColor Cyan

# A. Enable Features
$features = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
foreach ($feat in $features) {
    $status = Get-WindowsOptionalFeature -Online -FeatureName $feat
    if ($status.State -ne "Enabled") {
        Write-Host "Enabling feature: $feat..." -ForegroundColor Yellow
        Enable-WindowsOptionalFeature -Online -FeatureName $feat -NoRestart | Out-Null
        $RestartRequired = $true
    } else {
        Write-Host "OK: $feat is already enabled." -ForegroundColor Green
    }
}

# B. Check Restart Requirement & Auto-Resume
if ($RestartRequired) {
    Write-Host "`n[!] CRITICAL: Windows features have been enabled." -ForegroundColor Red
    Write-Host "A system restart is required to apply these changes." -ForegroundColor Red

    # --- AUTO-RESUME LOGIC (RUNONCE) ---
    $ResumeScriptPath = $PSCommandPath
    $RunOnceValue = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$ResumeScriptPath`""

    if (Test-Path $ResumeScriptPath) {
        Write-Host "Setting up auto-resume after restart..." -ForegroundColor Yellow
        try {
            $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
            Set-ItemProperty -Path $RegPath -Name "ResumeWSLMintSetup" -Value $RunOnceValue -ErrorAction Stop
            Write-Host "Auto-start configured for: $ResumeScriptPath" -ForegroundColor Green
        }
        catch {
            Write-Host "Warning: Could not configure Registry for auto-start." -ForegroundColor Magenta
        }
    } else {
        Write-Host "Warning: Installer script not found at: $ResumeScriptPath" -ForegroundColor Magenta
        Write-Host "You will need to run the installer manually after the restart." -ForegroundColor Magenta
    }
    # -------------------------------------

    Write-Host "`n[INFO] If you choose to restart, this setup will automatically resume after you log back in." -ForegroundColor Cyan
    Write-Host "[INFO] Please DO NOT try to run the script manually again after the restart." -ForegroundColor Cyan

    Write-Host "`nDo you want to restart the computer now? (Y/N)" -ForegroundColor Gray
    $choice = Read-Host "Choice"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Restart-Computer
    }
    exit
}

# C. Update Kernel & Set Version
try {
    Write-Host "Updating WSL Kernel..." -ForegroundColor Gray
    Start-Process "wsl.exe" -ArgumentList "--update", "--web-download" -Wait -NoNewWindow

    Write-Host "Setting default WSL version to 2..." -ForegroundColor Gray
    Start-Process "wsl.exe" -ArgumentList "--set-default-version", "2" -Wait -NoNewWindow
} catch {
    Write-Host "Warning: Could not auto-update WSL. Proceeding with current version." -ForegroundColor Yellow
}

# --- 3. DOWNLOAD FILES (MINT & 7ZA) ---
Write-Host "`n[STEP 2/6] Downloading Linux Mint and 7-Zip Extractor..." -ForegroundColor Cyan

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "Fetching Mint release info..." -ForegroundColor Gray

    $response = Invoke-RestMethod -Uri $RepoAPI
    $downloadUrl = $response.assets | Where-Object { $_.name -eq $ZipName } | Select-Object -ExpandProperty browser_download_url

    if (-not $downloadUrl) { throw "Release asset '$ZipName' not found!" }

    $tempZipPath = "$PSScriptRoot\$ZipName"

    try {
        if ((Get-Service BITS -ErrorAction SilentlyContinue).Status -ne 'Running') {
            Start-Service BITS -ErrorAction SilentlyContinue
        }

        Import-Module BitsTransfer -ErrorAction Stop

        Write-Host "Downloading 7za.exe via BITS..." -ForegroundColor Green
        Start-BitsTransfer -Source $SevenZipUrl -Destination $SevenZip -DisplayName "Downloading 7-Zip Extractor" -ErrorAction Stop

        Write-Host "Downloading Mint via BITS... ($downloadUrl)" -ForegroundColor Green
        Start-BitsTransfer -Source $downloadUrl -Destination $tempZipPath -DisplayName "Downloading Mint" -ErrorAction Stop
    }
    catch {
        Write-Host "BITS failed, falling back to standard web request..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $SevenZipUrl -OutFile $SevenZip -UseBasicParsing
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZipPath -UseBasicParsing
    }

    if (-not (Test-Path $tempZipPath) -or -not (Test-Path $SevenZip)) { throw "One or more downloads failed or files are missing." }
}
catch {
    Write-Host "CRITICAL ERROR during download: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# --- 4. EXTRACT FILES ---
Write-Host "`n[STEP 3/6] Extracting to $InstallPath..." -ForegroundColor Cyan

if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

if (-not (Test-Path $SevenZip)) {
    Write-Host "Error: 7za.exe was not downloaded properly!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

$proc = Start-Process -FilePath $SevenZip -ArgumentList "x `"$tempZipPath`" -o`"$InstallPath`" -y" -Wait -PassThru

if ($proc.ExitCode -ne 0) {
    Write-Host "Extraction Failed! ExitCode: $($proc.ExitCode)" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# --- 5. CLEANUP ---
Write-Host "`n[STEP 4/6] Cleaning up temporary files..." -ForegroundColor Cyan
try {
    if (Test-Path $tempZipPath) {
        Remove-Item -Path $tempZipPath -Force
        Write-Host "Deleted $ZipName" -ForegroundColor Gray
    }
    if (Test-Path $SevenZip) {
        Remove-Item -Path $SevenZip -Force
        Write-Host "Deleted 7za.exe" -ForegroundColor Gray
    }
} catch {
    Write-Host "Warning: Could not delete some temporary files. You may need to delete them manually." -ForegroundColor Yellow
}

# --- 6. REGISTER ---
Write-Host "`n[STEP 5/6] Registering Linux Mint..." -ForegroundColor Cyan
$MintExe = "$InstallPath\Mint.exe"

if (Test-Path $MintExe) {
    Write-Host "Launching Mint.exe to finalize installation..." -ForegroundColor Green
    Write-Host "A console window will appear. Please wait for the setup to complete." -ForegroundColor Yellow

    # Wait parametresi eklendi: Script bu noktada Mint.exe'nin işini bitirip kapanmasını bekleyecek
    Start-Process -FilePath $MintExe -Wait

    Write-Host "Registration completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Error: Mint.exe missing after extraction." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# --- 7. FIRST LAUNCH ---
Write-Host "`n[STEP 6/6] Launching Linux Mint..." -ForegroundColor Cyan
Write-Host "Installation workflow complete! Starting WSL..." -ForegroundColor Green
Start-Sleep -Seconds 2

# Linux Mint'i başlatır
wsl.exe ~
