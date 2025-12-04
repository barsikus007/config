sudo scoop install vcredist-aio
# TODO: is needed?: dotnet-sdk
# scoop install dotnet-sdk

Function Test-Command ($commandName) {
    if (Get-Command $commandName -ErrorAction SilentlyContinue) { return $true }
    return $false
}
if (-not (Test-Command winget)) {
    scoop install winget
}
winget upgrade --accept-source-agreements

if (-not (Test-Command wt)) {
    winget install -e --id Microsoft.WindowsTerminal
}
if (-not (Test-Command pwsh)) {
    winget install -e --id Microsoft.PowerShell -h
}
