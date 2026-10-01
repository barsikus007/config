if (-not $env:SCOOP) {
    throw "SCOOP environment variable is not set"
}

#? copy pre-seeded cache from ISO if present
foreach ($letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()) {
    $isoCache = "${letter}:\scoop-hydrated\cache"
    if (Test-Path -LiteralPath $isoCache) {
        Write-Host "copying scoop cache from $isoCache..." -ForegroundColor Green
        if (!(Test-Path "$env:SCOOP\cache")) {
            New-Item -ItemType Directory -Path "$env:SCOOP\cache" -Force | Out-Null
        }
        Copy-Item -Path "$isoCache\*" -Destination "$env:SCOOP\cache" -Force
        break
    }
}

scoop install aria2
scoop config aria2-warning-enabled false
scoop install 7zip
scoop install mingit innounp dark gsudo

#? pre-seed scoop buckets from ISO using 7z
if (!(Test-Path "$env:SCOOP\buckets\extras\.git") -or !(Test-Path "$env:SCOOP\buckets\main\.git")) {
    foreach ($letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()) {
        $zip = "${letter}:\scoop-hydrated\scoop-buckets.zip"
        if (Test-Path -LiteralPath $zip) {
            Write-Host "pre-seeding scoop buckets from $zip..." -ForegroundColor Green
            Remove-Item -LiteralPath "$env:SCOOP\buckets" -Recurse -Force -ErrorAction SilentlyContinue
            7z x "$zip" "-o$env:SCOOP" -y | Out-Null
            break
        }
    }
}

#? fallback: if extras was not seeded or has broken .git, ensure clean state and add from remote
if (!(Test-Path "$env:SCOOP\buckets\extras\.git")) {
    if (Test-Path "$env:SCOOP\buckets\extras") {
        Remove-Item -LiteralPath "$env:SCOOP\buckets\extras" -Recurse -Force -ErrorAction SilentlyContinue
    }
    scoop bucket add extras
    scoop update
}
