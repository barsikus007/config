Write-Host "initial system tweaks elevation (UAC, DevMode)..." -ForegroundColor Green
#? part of the 99Tweaks.ps1
Start-Process PowerShell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', '
    reg.exe add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f;
    reg.exe add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f
'

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    foreach ($letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()) {
        if (Test-Path "${letter}:\scripts\00Bootstrap.ps1") {
            $scriptDir = "${letter}:\scripts"
            break
        }
    }
}

function Invoke-LocalOrRemoteScript {
    param([string]$ScriptName)
    if ($scriptDir -and (Test-Path "$scriptDir\$ScriptName")) {
        Write-Host "running $ScriptName from $scriptDir..." -ForegroundColor Green
        & "$scriptDir\$ScriptName"
    } else {
        Write-Host "downloading $ScriptName from github..." -ForegroundColor Green
        Invoke-RestMethod "https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/nix/packages/windows/scripts/$ScriptName" | Invoke-Expression
    }
}

Write-Host "hint: to apply tweaks, run command below" -ForegroundColor Gray
if ($scriptDir -and (Test-Path "$scriptDir\99Tweaks.ps1")) {
    Write-Host "& `"$scriptDir\99Tweaks.ps1`"" -ForegroundColor Gray
} else {
    Write-Host "irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/nix/packages/windows/scripts/99Tweaks.ps1 | iex" -ForegroundColor Gray
}
Write-Host
Write-Host "scoop installation..." -ForegroundColor Green
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
$env:SCOOP = "$env:USERPROFILE\scoop"
[Environment]::SetEnvironmentVariable("SCOOP", $env:SCOOP, "User")

function Update-SessionEnvironment {
    foreach ($level in 'Machine', 'User') {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
            if ($_.Key -ne 'Path') {
                Set-Item -Path "env:$($_.Key)" -Value $_.Value
            }
        }
    }
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}
Update-SessionEnvironment

Write-Host "scoop inital packages installation..." -ForegroundColor Green
Invoke-LocalOrRemoteScript "00Bootstrap.ps1"
Write-Host "system packages installation..." -ForegroundColor Green
Invoke-LocalOrRemoteScript "01System.ps1"

Write-Host "shell packages installation..." -ForegroundColor Green
Invoke-LocalOrRemoteScript "10Shell.ps1"
Invoke-LocalOrRemoteScript "11ShellHeavy.ps1"
Invoke-LocalOrRemoteScript "12Dev.ps1"

Write-Host "GUI packages installation..." -ForegroundColor Green
Invoke-LocalOrRemoteScript "20SoftHighPriority.ps1"
Invoke-LocalOrRemoteScript "21FileAssociations.ps1"


Write-Host "importing context menus and file associations from scoop packages..." -ForegroundColor Green
Get-ChildItem -Path "$env:SCOOP\apps\*\current\install-context*.reg", "$env:SCOOP\apps\*\current\install-associations*.reg" | ForEach-Object {
    Write-Host "importing $($_.Name) for $($_.Directory.Parent.Name)" -ForegroundColor Cyan
    reg import $_.FullName
}


Write-Host "Firefox installation & configuration from Nix..." -ForegroundColor Green
$persist = "$env:SCOOP\persist\firefox"
New-Item -ItemType Directory -Path "$persist\distribution", "$persist\profile\chrome" -Force | Out-Null

$ffSource = "C:\ProgramData\FirefoxConfig"
if (-not (Test-Path $ffSource)) {
    foreach ($letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()) {
        if (Test-Path "${letter}:\firefox") {
            $ffSource = "${letter}:\firefox"
            break
        }
    }
}

if (Test-Path $ffSource) {
    if (Test-Path "$ffSource\distribution\policies.json") {
        Copy-Item "$ffSource\distribution\policies.json" "$persist\distribution\" -Force
    }
    if (Test-Path "$ffSource\profile\user.js") {
        Copy-Item "$ffSource\profile\user.js" "$persist\profile\" -Force
    }
    if (Test-Path "$ffSource\profile\chrome\userChrome.css") {
        Copy-Item "$ffSource\profile\chrome\userChrome.css" "$persist\profile\chrome\" -Force
    }
    if (Test-Path "$ffSource\profile\search.json.mozlz4") {
        Copy-Item "$ffSource\profile\search.json.mozlz4" "$persist\profile\" -Force
    }
    Write-Host "Applied Nix Firefox policies, user.js, and userChrome.css to Scoop persist." -ForegroundColor Cyan
}

scoop install firefox

# link scoop profile as firefox native default-release profile
$profilesDir = "$env:APPDATA\Mozilla\Firefox\Profiles"
New-Item -ItemType Directory -Path $profilesDir -Force | Out-Null
New-Item -ItemType Junction -Path "$profilesDir\default-release" -Target "$persist\profile" -Force | Out-Null

$installHash = "28567DFCD4441A51"
$installsIni = "$env:APPDATA\Mozilla\Firefox\installs.ini"
if (Test-Path $installsIni) {
    $existing = (Get-Content $installsIni | Select-String -Pattern '^\[([0-9A-F]+)\]').Matches.Groups[1].Value
    if ($existing) { $installHash = $existing }
}

@"
[General]
StartWithLastProfile=1
Version=2

[Profile0]
Name=default-release
IsRelative=1
Path=Profiles/default-release
Default=1

[Install$installHash]
Default=Profiles/default-release
Locked=1
"@ | Out-File -FilePath "$env:APPDATA\Mozilla\Firefox\profiles.ini" -Encoding utf8 -Force

@"
[$installHash]
Default=Profiles/default-release
Locked=1
"@ | Out-File -FilePath $installsIni -Encoding utf8 -Force


pwsh.exe -Command 'cd && git clone --depth 1 https://github.com/barsikus007/config && cd ~\config\ && .\windows\install.ps1 && cd -'
