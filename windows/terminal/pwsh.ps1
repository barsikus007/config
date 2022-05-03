Set-ExecutionPolicy RemoteSigned -Force

cp windows\terminal\starship.lua ~\AppData\Local\clink\ -Recurse -Force
cp windows\terminal\Microsoft.PowerShell_profile.ps1 $PROFILE -Recurse -Force
cp .config\* ~\.config\
