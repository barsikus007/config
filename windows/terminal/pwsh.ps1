Set-ExecutionPolicy RemoteSigned -Force

touch $PROFILE
mkdir ~\Documents\WindowsPowerShell
mkdir ~\Documents\PowerShell
cp windows\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE
mkdir ~\AppData\Local\clink
cp windows\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
cp .config\* ~\.config\
