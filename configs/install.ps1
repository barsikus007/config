Copy-Item $PSScriptRoot\.config\* ~\.config\ -Recurse -Force
Copy-Item ~\.config\nvim\ ~\AppData\Local\ -Recurse -Force
