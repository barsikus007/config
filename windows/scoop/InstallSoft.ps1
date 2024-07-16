Write-Host "Basic setup for scoop"
scoop install mingit
scoop bucket add extras
scoop update
scoop install aria2
scoop config aria2-warning-enabled false
scoop install 7zip innounp dark

Write-Host "Fonts for terminal"
scoop bucket add nerd-fonts
scoop install gsudo
#! old one
# scoop install sudo
sudo scoop install Delugia-Nerd-Font-Complete

Write-Host "System apps"
# system
# TODO dotnet check
sudo scoop install vcredist-aio
scoop install dotnet-sdk
