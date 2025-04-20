Write-Host "DEPRECATION WARNING!!! I USE NIX NOW"
Write-Host "Installing config files..."
Copy-Item $PSScriptRoot\.config\* ~\.config\ -Recurse -Force
Copy-Item $PSScriptRoot\..\nix\.config\* ~\.config\ -Recurse -Force

Write-Host "Installing nvim config files..."
Copy-Item ~\.config\nvim\ ~\AppData\Local\ -Recurse -Force

$SCOOP_HOME = $(If (Test-Path env:SCOOP) { $env:SCOOP } Else { $env:GIT_INSTALL_ROOT.Split("scoop")[0]+"scoop" })
Write-Host "Detected scoop home: $SCOOP_HOME"

Write-Host "Installing config files for scoop apps..."
Write-Host "mpv"
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\mpv.conf -Path $SCOOP_HOME\persist\mpv\portable_config\mpv.conf -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\input.conf -Path $SCOOP_HOME\persist\mpv\portable_config\input.conf -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\scripts\ -Path $SCOOP_HOME\persist\mpv\portable_config\scripts\ -Force | Out-Null
New-Item -ItemType SymbolicLink -Value $HOME\.config\mpv\script-opts\ -Path $SCOOP_HOME\persist\mpv\portable_config\script-opts\ -Force | Out-Null
