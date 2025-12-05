# https://schneegans.de/windows/unattend-generator/
#region VirtIoGuestTools
& {
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\virtio-win-guest-tools.exe";
        if( Test-Path -LiteralPath $exe ) {
            Start-Process -FilePath $exe -ArgumentList '/passive', '/norestart' -Wait;
            return;
        }
    }
    'VirtIO Guest Tools image (virtio-win-*.iso) is not attached to this VM.';
} *>&1 | Out-String -Stream >> 'C:\Windows\Setup\Scripts\VirtIoGuestTools.log';
#endregion VirtIoGuestTools

#region Looking Glass
Invoke-WebRequest `
    -Uri https://looking-glass.io/artifact/bleeding/idd `
    -OutFile "C:\Windows\Temp\looking-glass-idd.zip"
Expand-Archive -Path "C:\Windows\Temp\looking-glass-idd.zip" `
    -Destination "C:\Windows\Temp\looking-glass-idd" -Force

# 1. Get the certificate object from the EXE signature
$cert = (Get-AuthenticodeSignature -FilePath "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe").SignerCertificate
# 2. Check if we found a signature
if ($cert) {
    # 3. Export to a temp file (Import-Certificate works best with files)
    $tempCertPath = "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-driver.cer"
    Export-Certificate -Cert $cert -FilePath $tempCertPath -Type CERT -Force

    # 4. Import into TrustedPublisher (LocalMachine scope requires Admin)
    Import-Certificate -FilePath $tempCertPath -CertStoreLocation Cert:\LocalMachine\TrustedPublisher

    # Optional: Clean up
    Remove-Item $tempCertPath
    Write-Host "Certificate successfully imported to TrustedPublisher." -ForegroundColor Green
} else {
    Write-Error "No signature found on looking-glass-idd-setup.exe. Check the file path."
}

# Create the path if it doesn't exist
$regPath = "HKLM:\SOFTWARE\LookingGlass\IDD"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
# Set the Multi-String value
# The comma separates the lines in the MultiString
$modes = "1920x1080@120", "2560x1440@144"
New-ItemProperty -Path $regPath -Name "Modes" -PropertyType MultiString -Value $modes -Force

Invoke-Expression "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe /S"

powershell -Command "DisplaySwitch.exe /internal"
#endregion Looking Glass

Invoke-Expression "C:\Windows\Setup\Scripts\MAS_AIO.cmd /Z-Windows"

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
