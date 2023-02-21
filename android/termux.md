# [Termux](./)
```bash
termux-setup-storage
yes | pkg up
pkg i neovim -y
## termix additions
pkg i tsu termux-api -y
```
## DriveDroid fix on Pixel 7 Pro
```bash
curl -sL https://gist.github.com/barsikus007/2e44999712cdb074a1c9a9803cad7b8f/raw/ce0bd0e58403d4cbf44a0297fa994a6e1c3fdd7e/fixdd > ~/fixdd && sudo cp fixdd /data/adb/service.d/fixdd && sudo chmod +x /data/adb/service.d/fixdd
```
