# TODO: this is not only LTSC step, but I make it earlier for winget
scoop install extras/vcredist2022
# sudo scoop install vcredist-aio
# TODO: died: https://github.com/ScoopInstaller/Extras/issues/16590

scoop install winget
# TODO: this is not only LTSC step, but I make it earlier for windows terminal
winget upgrade --accept-source-agreements

winget install -e --id Microsoft.WindowsTerminal
# TODO: this is not only LTSC step, but I make it earlier cause I am lazy
winget install -e --id Microsoft.PowerShell -h
