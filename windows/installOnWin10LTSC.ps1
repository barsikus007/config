Write-Host "initial system tweaks elevation (UAC, DevMode)..." -ForegroundColor Green
#? part of the 99Tweaks.ps1
Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', '
    reg.exe add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f;
    reg.exe add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f
'

Write-Host "hint: to apply tweaks, run command below" -ForegroundColor Gray
Write-Host "irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/99Tweaks.ps1 | iex" -ForegroundColor Gray
Write-Host
Write-Host "scoop installation..." -ForegroundColor Green
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
$env:SCOOP = "$env:USERPROFILE\scoop"
[Environment]::SetEnvironmentVariable("SCOOP", $env:SCOOP, "User")

function Update-SessionEnvironment {
    foreach ($level in 'Machine', 'User') {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
            if ($_.Key -ne 'Path') {
                Set-Item -Path "env:$($_.Key)" -Value $_.Value
            }
        }
    }
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}
Update-SessionEnvironment

Write-Host "scoop inital packages installation..." -ForegroundColor Green
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/00Bootstrap.ps1 | Invoke-Expression
Write-Host "system packages installation..." -ForegroundColor Green
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/01System.ps1 | Invoke-Expression

Write-Host "shell packages installation..." -ForegroundColor Green
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/10Shell.ps1 | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/11ShellHeavy.ps1 | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/12Dev.ps1 | Invoke-Expression

Write-Host "GUI packages installation..." -ForegroundColor Green
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/20SoftHighPriority.ps1 | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/21FileAssociations.ps1 | Invoke-Expression


Write-Host "importing context menus and file associations from scoop packages..." -ForegroundColor Green
Get-ChildItem -Path "$env:SCOOP\apps\*\current\install-context*.reg", "$env:SCOOP\apps\*\current\install-associations*.reg" | ForEach-Object {
    Write-Host "importing $($_.Name) for $($_.Directory.Parent.Name)" -ForegroundColor Cyan
    reg import $_.FullName
}


winget install --exact --id Microsoft.Edge --silent --force


pwsh.exe -Command 'cd && git clone --depth 1 https://github.com/barsikus007/config && cd ~\config\ && .\windows\install.ps1 && cd -'
