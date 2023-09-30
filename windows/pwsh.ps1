#Requires -RunAsAdministrator
Write-Output 'Run as administrator:'
Write-Output 'Set-ExecutionPolicy RemoteSigned -Force'
Write-Output ''

Write-Output 'Install scoop:'
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File $PSScriptRoot\scoop\InstallScoop.ps1 $args"
Write-Output ''

Write-Output 'Updating config files...'
.\$PSScriptRoot\..\configs\install.ps1
Write-Output 'cmd clink...'
New-Item ~\AppData\Local\clink\ -Force -ItemType Directory | Out-Null
Copy-Item $PSScriptRoot\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
Write-Output 'PowerShell and pwsh...'
New-Item ~\Documents\WindowsPowerShell\ -Force -ItemType Directory | Out-Null
New-Item ~\Documents\PowerShell\ -Force -ItemType Directory | Out-Null
# Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE
Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 ~\Documents\WindowsPowerShell\
Copy-Item $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 ~\Documents\PowerShell\
Write-Output 'WindowsTerminal...'
Copy-Item $PSScriptRoot\terminal\icons\ ~\Pictures\ -Recurse -Force
Copy-Item $PSScriptRoot\terminal\settings.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\ -Recurse -Force
Write-Output 'Winget...'
Copy-Item $PSScriptRoot\winget\settings.json ~\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\ -Recurse -Force
