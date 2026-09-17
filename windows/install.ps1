scoop alias rm i | Out-Null
scoop alias rm up | Out-Null
scoop alias rm un | Out-Null
scoop alias rm purge | Out-Null
scoop alias rm upgrade | Out-Null
scoop alias add purge 'scoop uninstall -p $args' 'Uninstall an app with purge'
scoop alias add upgrade 'scoop update *' 'Update all apps, just like "brew" or "apt"'
scoop alias add i 'scoop install $args' 'Alias to install'
scoop alias add up 'scoop update $args' 'Alias to update'
scoop alias add un 'scoop uninstall $args' 'Alias to uninstall'

Write-Host "cmd clink..."
New-Item ~\AppData\Local\clink\ -Force -ItemType Directory | Out-Null
Set-Content -Path ~\AppData\Local\clink\starship.lua -Value 'load(io.popen([[starship init cmd]]):read([[*a]]))()' -Force
Write-Host "PowerShell and pwsh..." -ForegroundColor Green
New-Item ~\Documents\WindowsPowerShell\ -Force -ItemType Directory | Out-Null
New-Item ~\Documents\PowerShell\ -Force -ItemType Directory | Out-Null
# https://superuser.com/a/1291446
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\Microsoft.PowerShell_profile.ps1 -Path ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -Force | Out-Null
Write-Host "WindowsTerminal..."
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\terminal\settings.json -Path ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -Force | Out-Null
Write-Host "Winget..."
New-Item -ItemType SymbolicLink -Value $PSScriptRoot\winget\settings.json -Path ~\AppData\Local\Microsoft\WinGet\Settings\defaultState\settings.json -Force | Out-Null


Write-Host "DEPRECATION WARNING!!! I USE NIX NOW"
Write-Host "Installing config files..."
Copy-Item $PSScriptRoot\..\nix\.config\* ~\.config\ -Recurse -Force

Write-Host "Installing nvim config files..."
Copy-Item ~\.config\nvim\ ~\AppData\Local\ -Recurse -Force

$SCOOP_HOME = $(If (Test-Path env:SCOOP) { $env:SCOOP } Else { ($env:GIT_INSTALL_ROOT -split "scoop")[0]+"scoop" })
Write-Host "Detected scoop home: $SCOOP_HOME"

Write-Host "Installing config files for scoop apps..."
Write-Host "mpv"
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\mpv.conf -Path $SCOOP_HOME\persist\mpv\portable_config\mpv.conf -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\input.conf -Path $SCOOP_HOME\persist\mpv\portable_config\input.conf -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\scripts\ -Path $SCOOP_HOME\persist\mpv\portable_config\scripts\ -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\script-opts\ -Path $SCOOP_HOME\persist\mpv\portable_config\script-opts\ -Force | Out-Null
