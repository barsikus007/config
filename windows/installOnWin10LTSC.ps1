# irm = Invoke-RestMethod; iex = Invoke-Expression
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/00Bootstrap.ps1 | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/01LTSC.ps1 | Invoke-Expression
# TODO: died: https://github.com/ScoopInstaller/Extras/issues/16590; is needed?: dotnet-sdk
# Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/05System.ps1 | Invoke-Expression


Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/10Shell.ps1 | Invoke-Expression
Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/11ShellHeavy.ps1 | Invoke-Expression

Invoke-RestMethod https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/scoop/20SoftHighPriority.ps1 | Invoke-Expression


Write-Host "Notes from scoop packages" -ForegroundColor Green
# TODO parse them programmatically
$SCOOP_HOME = $(If (Test-Path env:SCOOP) { $env:SCOOP } Else { ($env:GIT_INSTALL_ROOT -split "scoop")[0]+"scoop" })
reg import "$SCOOP_HOME\apps\7zip\current\install-context.reg"
reg import "$SCOOP_HOME\apps\everything\current\install-context.reg"
reg import "$SCOOP_HOME\apps\notepadplusplus\current\install-context.reg"


winget install -e --id Microsoft.Edge -h --force


pwsh.exe -Command 'cd && git clone https://github.com/barsikus007/config --depth 1 && cd ~\config\ && sudo .\windows\pwsh.ps1 && cd -'
