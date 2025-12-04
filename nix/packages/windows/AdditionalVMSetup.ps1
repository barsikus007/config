# https://schneegans.de/windows/unattend-generator/
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


Invoke-WebRequest `
    -Uri https://looking-glass.io/artifact/bleeding/idd `
    -OutFile "C:\Windows\Temp\looking-glass-idd.zip"
Expand-Archive -Path "C:\Windows\Temp\looking-glass-idd.zip" `
    -Destination "C:\Windows\Temp\looking-glass-idd" -Force
Invoke-Expression "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe /S"


Invoke-Expression "C:\Windows\Setup\Scripts\MAS_AIO.cmd /Z-Windows"


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
