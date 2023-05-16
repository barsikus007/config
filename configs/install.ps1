Copy-Item $PSScriptRoot\.config\* ~\.config\ -Recurse -Force
Copy-Item ~\.config\nvim\ C:\Users\Zephyr\AppData\Local\ -Recurse -Force
