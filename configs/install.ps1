Write-Host "Installing config files..."
Copy-Item $PSScriptRoot\.config\* ~\.config\ -Recurse -Force

Write-Host "Installing nvim config files..."
Copy-Item ~\.config\nvim\ ~\AppData\Local\ -Recurse -Force

$SCOOP_HOME = $env:GIT_INSTALL_ROOT.Split("scoop")[0]+"scoop"
Write-Host "Detected scoop home: $SCOOP_HOME"

Write-Host "Installing config files for scoop apps..."
New-Item -ItemType SymbolicLink -Value $HOME\.config\btop\btop.conf -Path $SCOOP_HOME\apps\btop\current\btop.conf -Force | Out-Null
