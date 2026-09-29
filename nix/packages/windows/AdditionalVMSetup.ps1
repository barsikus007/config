# https://schneegans.de/windows/unattend-generator/
#region DisableDriverUpdates
# block windows update from overwriting third-party / custom graphics drivers before network starts
$wuPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (!(Test-Path $wuPolicyPath)) { New-Item -Path $wuPolicyPath -Force | Out-Null }
Set-ItemProperty -Path $wuPolicyPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0 -Type DWord -Force
#endregion DisableDriverUpdates

#region VirtIoGuestTools
& {
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\virtio-win-guest-tools.exe";
        if( Test-Path -LiteralPath $exe ) {
            Start-Process -FilePath $exe -ArgumentList '/passive', '/norestart' -Wait;
            return;
        }
    }
    'VirtIO Guest Tools (virtio-win-guest-tools.exe) not found on any drive.';
} *>&1 | Out-String -Width 1KB -Stream >> 'C:\Windows\Setup\Scripts\VirtIoGuestTools.log';
#endregion VirtIoGuestTools

#region SSH
# https://git.stupid.fish/teidesu/nixfiles/src/branch/master/lib/windows/customizers/network.nix
Expand-Archive -Path "C:\Windows\Temp\OpenSSH-Win64.zip" `
    -Destination "C:\Program Files\" -Force
Push-Location "C:\Program Files\OpenSSH-Win64"

PowerShell.exe -ExecutionPolicy Bypass -File install-sshd.ps1
# .\ssh-keygen.exe -A
# & .\FixHostFilePermissions.ps1 -Confirm:$false
# & .\FixUserFilePermissions.ps1 -Confirm:$false

Pop-Location

# $newPath = 'C:\Program Files\OpenSSH-Win64;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
# [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server (sshd)" -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow
Set-Service sshd -StartupType Automatic
# Set-Service ssh-agent -StartupType Automatic
# sc.exe failure sshd reset= 86400 actions= restart/500

Start-Service sshd
# Start-Service ssh-agent
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
#endregion SSH

#region WindowsUpdate
& {
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $updatesDir = "${letter}:\updates";
        if( Test-Path -LiteralPath $updatesDir ) {
            $packages = Get-ChildItem -LiteralPath $updatesDir -Filter "*.msu" | Sort-Object Name;
            if( $packages ) {
                $tempExtract = "C:\Windows\Temp\UpdateExtract";
                foreach( $pkg in $packages ) {
                    Write-Host "Extracting $($pkg.Name)..." -ForegroundColor Green
                    if( Test-Path -LiteralPath $tempExtract ) { Remove-Item -LiteralPath $tempExtract -Recurse -Force }
                    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
                    Start-Process -FilePath "expand.exe" -ArgumentList "-F:*", "`"$($pkg.FullName)`"", "`"$tempExtract`"" -Wait

                    # SSU must be installed before the main update
                    Get-ChildItem -Path $tempExtract -Filter "SSU-*.cab" | ForEach-Object {
                        Write-Host "Installing SSU $($_.Name)..." -ForegroundColor Green
                        $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Add-Package", "/PackagePath:$($_.FullName)", "/Quiet", "/NoRestart" -Wait -PassThru
                        Write-Host "DISM $($_.Name) exited with code $($proc.ExitCode)" -ForegroundColor Gray
                    }

                    # Main cumulative update CAB
                    Get-ChildItem -Path $tempExtract -Filter "*.cab" | Where-Object { $_.Name -notlike "SSU-*" -and $_.Name -notlike "WSUSSCAN*" } | ForEach-Object {
                        Write-Host "Installing package $($_.Name)..." -ForegroundColor Green
                        $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Add-Package", "/PackagePath:$($_.FullName)", "/Quiet", "/NoRestart" -Wait -PassThru
                        Write-Host "DISM $($_.Name) exited with code $($proc.ExitCode)" -ForegroundColor Gray
                    }
                    Remove-Item -LiteralPath $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
                }
                return;
            }
        }
    }
    'No Windows updates found on any drive.';
} *>&1 | Out-String -Width 1KB -Stream >> 'C:\Windows\Setup\Scripts\WindowsUpdate.log';
#endregion WindowsUpdate

#region winfsp
Invoke-WebRequest `
    -Uri https://github.com/winfsp/winfsp/releases/download/v2.1/winfsp-2.1.25156.msi `
    -OutFile "C:\Windows\Temp\winfsp.msi"
Invoke-Expression "C:\Windows\Temp\winfsp.msi /passive"
#endregion winfsp

#region NvidiaDriver
& {
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $setupExe = "${letter}:\drivers\nvidia\setup.exe";
        if( Test-Path -LiteralPath $setupExe ) {
            $logDir = "C:\Windows\Logs\Nvidia";
            if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

            Write-Host "Installing clean Nvidia Display Driver from $setupExe..." -ForegroundColor Green;
            Push-Location (Split-Path -Parent $setupExe);
            $proc = Start-Process -FilePath $setupExe -ArgumentList "-s", "-n", "Display.Driver", "-log:$logDir", "-loglevel:6" -Wait -PassThru;
            Pop-Location;
            Write-Host "Nvidia setup.exe exited with code $($proc.ExitCode)" -ForegroundColor Gray;
            return;
        }
    }
    'Nvidia setup.exe not found on any drive.';
} *>&1 | Out-String -Width 1KB -Stream >> 'C:\Windows\Setup\Scripts\NvidiaDriver.log';
#endregion NvidiaDriver

#region Looking Glass
Expand-Archive -Path "C:\Windows\Temp\looking-glass-idd.zip" `
    -Destination "C:\Windows\Temp\looking-glass-idd" -Force

# 1. get the certificate object from the EXE signature
$cert = (Get-AuthenticodeSignature -FilePath "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe").SignerCertificate
# 2. check if we found a signature
if ($cert) {
    # 3. export to a temp file (Import-Certificate works best with files)
    $tempCertPath = "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-driver.cer"
    Export-Certificate -Cert $cert -FilePath $tempCertPath -Type CERT -Force

    # 4. import into TrustedPublisher (LocalMachine scope requires Admin)
    Import-Certificate -FilePath $tempCertPath -CertStoreLocation Cert:\LocalMachine\TrustedPublisher

    # optional: clean up
    Remove-Item $tempCertPath
    Write-Host "Certificate successfully imported to TrustedPublisher." -ForegroundColor Green
} else {
    Write-Error "No signature found on looking-glass-idd-setup.exe. Check the file path."
}

# create the path if it doesn't exist
$regPath = "HKLM:\SOFTWARE\LookingGlass\IDD"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
# set the Multi-String value;
# the comma separates the lines in the MultiString
$modes = "2560x1440@144*", "1920x1080@120.003", "1920x1080@60"
New-ItemProperty -Path $regPath -Name "Modes" -PropertyType MultiString -Value $modes -Force

# refresh rate for dynamic client resolutions (win:setGuestRes)
New-ItemProperty -Path $regPath -Name "DefaultRefresh" -PropertyType DWord -Value 144 -Force

Invoke-Expression "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe /S"
#endregion Looking Glass

Invoke-Expression "C:\Windows\Setup\Scripts\MAS_AIO.cmd /Z-Windows"

#region CustomTweaks
& {
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $tweaksScript = "${letter}:\scripts\01-tweaks.ps1";
        if( Test-Path -LiteralPath $tweaksScript ) {
            Write-Host "Running $tweaksScript..." -ForegroundColor Green;
            & $tweaksScript;
            return;
        }
    }
    'No custom setup scripts found on any drive.';
} *>&1 | Out-String -Width 1KB -Stream >> 'C:\Windows\Setup\Scripts\CustomTweaks.log';
#endregion CustomTweaks
