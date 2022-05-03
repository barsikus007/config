echo 'Run as administrator:'
echo 'Set-ExecutionPolicy RemoteSigned -Force'
echo ''

echo Executing:
echo $PSScriptRoot\scoop\InstallScoop.ps1
echo ''

PowerShell.exe -ExecutionPolicy Bypass -File $PSScriptRoot\scoop\InstallScoop.ps1 $args  # D:\scoop

mkdir ~\Documents\WindowsPowerShell
mkdir ~\Documents\PowerShell
cp windows\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE
mkdir ~\AppData\Local\clink
cp windows\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
cp .config\* ~\.config\
