# THIS IS NOT ONLY LTSC STEP
scoop install extras/vcredist2022
# BUT THIS IS GLOBAL
# sudo scoop install vcredist-aio
# TODO is sudo needed, died: https://github.com/ScoopInstaller/Extras/issues/16590

scoop install winget
# winget agreement
# TODO winget upgrade --accept-source-agreements

winget install -e --id Microsoft.WindowsTerminal
# TODO or winget install -e --id Microsoft.WindowsTerminal --accept-package-agreements

# TODO no NF fonts is terminal, ltsc or old windows bug?
