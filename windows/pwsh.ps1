#Requires -RunAsAdministrator
Write-Host "Run as administrator:" -ForegroundColor Green
Write-Host "Set-ExecutionPolicy RemoteSigned -Force"
Write-Host ""

Write-Host "Install scoop:" -ForegroundColor Green
Write-Host "PowerShell.exe -ExecutionPolicy Bypass -File $PSScriptRoot\scoop\InstallScoop.ps1 $args"
Write-Host ""
scoop alias rm i | Out-Null
scoop alias rm up | Out-Null
scoop alias rm un | Out-Null
scoop alias rm purge | Out-Null
scoop alias rm upgrade | Out-Null
scoop alias add purge 'scoop uninstall -p $args'
scoop alias add upgrade 'scoop update *'
scoop alias add i 'scoop install $args'
scoop alias add up 'scoop update $args'
scoop alias add un 'scoop uninstall $args'

Write-Host "Updating config files..." -ForegroundColor Green
.\$PSScriptRoot\..\configs\install.ps1
Write-Host "cmd clink..."
New-Item ~\AppData\Local\clink\ -Force -ItemType Directory | Out-Null
Copy-Item $PSScriptRoot\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
Write-Host "PowerShell and pwsh..." -ForegroundColor Green
New-Item ~\Documents\WindowsPowerShell\ -Force -ItemType Directory | Out-Null
New-Item ~\Documents\PowerShell\ -Force -ItemType Directory | Out-Null
# https://superuser.com/a/1291446
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\extend.ps1 -Path ~\Documents\PowerShell\extend.ps1 -Force | Out-Null
Write-Host "WindowsTerminal..."
Copy-Item $PSScriptRoot\terminal\icons\ ~\Pictures\ -Recurse -Force
Copy-Item $PSScriptRoot\terminal\settings.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\ -Recurse -Force
Write-Host "Winget..."
Copy-Item $PSScriptRoot\winget\settings.json ~\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\ -Recurse -Force
