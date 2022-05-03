echo 'Run as administrator:'
echo 'Set-ExecutionPolicy RemoteSigned -Force'
echo ''

echo 'Install scoop:'
echo "PowerShell.exe -ExecutionPolicy Bypass -File $PSScriptRoot\scoop\InstallScoop.ps1 $args"
echo ''

# copy config
mkdir ~\Documents\WindowsPowerShell -Force | Out-Null
mkdir ~\Documents\PowerShell -Force | Out-Null
cp $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE
mkdir ~\AppData\Local\clink -Force | Out-Null
cp $PSScriptRoot\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
cp $PSScriptRoot\..\.config\* ~\.config\ -Recurse -Force
cp $PSScriptRoot\terminal\icons ~\Pictures\icons -Recurse -Force

echo 'Choose theme for terminal:'
echo Light:
echo "cp $PSScriptRoot\terminal\settings.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\ -Recurse -Force"
echo Dark:
echo "cp $PSScriptRoot\terminal\settings-dark.json ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -Recurse -Force"
