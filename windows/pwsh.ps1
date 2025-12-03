#Requires -RunAsAdministrator
Write-Host "Run as administrator:" -ForegroundColor Green
Write-Host "Set-ExecutionPolicy RemoteSigned -Force"
Write-Host ""

Write-Host "Install scoop, to change dir:" -ForegroundColor Green
Write-Host "irm get.scoop.sh -ScoopDir D:\scoop | iex"
Write-Host ""
scoop alias rm i | Out-Null
scoop alias rm up | Out-Null
scoop alias rm un | Out-Null
scoop alias rm purge | Out-Null
scoop alias rm upgrade | Out-Null
scoop alias add purge 'scoop uninstall -p $args' 'Uninstall an app with purge'
scoop alias add upgrade 'scoop update *' 'Update all apps, just like "brew" or "apt"'
scoop alias add i 'scoop install $args' 'Alias to install'
scoop alias add up 'scoop update $args' 'Alias to update'
scoop alias add un 'scoop uninstall $args' 'Alias to uninstall'

Write-Host "Updating config files..." -ForegroundColor Green
.\$PSScriptRoot\..\configs\install.ps1
Write-Host "cmd clink..."
New-Item ~\AppData\Local\clink\ -Force -ItemType Directory | Out-Null
Copy-Item $PSScriptRoot\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
Write-Host "PowerShell and pwsh..." -ForegroundColor Green
New-Item ~\Documents\WindowsPowerShell\ -Force -ItemType Directory | Out-Null
New-Item ~\Documents\PowerShell\ -Force -ItemType Directory | Out-Null
# https://superuser.com/a/1291446
sudo New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
sudo New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
sudo New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\extend.ps1 -Path ~\Documents\PowerShell\extend.ps1 -Force | Out-Null
Write-Host "WindowsTerminal..."
sudo New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\settings.json -Path ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -Force | Out-Null
Write-Host "Winget..."
sudo New-Item -ItemType SymbolicLink -Value $PSScriptRoot\winget\settings.json -Path ~\AppData\Local\Microsoft\WinGet\Settings\defaultState\settings.json -Force | Out-Null
