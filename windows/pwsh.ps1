#Requires -RunAsAdministrator
Write-Output 'Run as administrator:'
Write-Output 'Set-ExecutionPolicy RemoteSigned -Force'
Write-Output ''

Write-Output 'Install scoop:'
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File $PSScriptRoot\scoop\InstallScoop.ps1 $args"
Write-Output ''

.\$PSScriptRoot\..\configs\install.ps1
# copy configs
New-Item ~\Documents\WindowsPowerShell\ -Force -ItemType Directory | Out-Null
New-Item ~\Documents\PowerShell\ -Force -ItemType Directory | Out-Null
# Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE
Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 ~\Documents\WindowsPowerShell\
Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 ~\Documents\PowerShell\
New-Item ~\AppData\Local\clink\ -Force -ItemType Directory | Out-Null
Copy-Item $PSScriptRoot\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
Copy-Item $PSScriptRoot\terminal\icons ~\Pictures\icons\ -Recurse -Force
Copy-Item $PSScriptRoot\winget\settings.json ~\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\ -Recurse -Force

Write-Output 'Choose theme for terminal:'
Write-Output Light:
Write-Output "Copy-Item $PSScriptRoot\terminal\settings.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\ -Recurse -Force"
Write-Output Dark:
Write-Output "Copy-Item $PSScriptRoot\terminal\settings-dark.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -Recurse -Force"
