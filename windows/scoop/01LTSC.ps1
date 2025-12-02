# this is not only LTSC step, but I make it earlier for winget
scoop install extras/vcredist2022
# sudo scoop install vcredist-aio
# TODO: died: https://github.com/ScoopInstaller/Extras/issues/16590

scoop install winget

winget install -e --id Microsoft.WindowsTerminal --accept-package-agreements
