@echo off
chcp 65001 > nul

setlocal EnableDelayedExpansion

for /f "usebackq" %%a in (`git ls-remote --get-url`) do set "URL=%%a"

if "%URL:github=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:gitlab=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:bitbucket=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:kernel=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:archlinux=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:gnu=%" neq "%URL%" (
    set "ICON= "
) else if "%URL:git=%" neq "%URL%" (
    set "ICON= "
) else (
    set "ICON= "
    set "URL=localhost"
)

@REM for %%a in ("https", "http", "git", "://", "@") do (
@REM     if "!URL:%%a=!" neq "!URL!" (
@REM         set "URL=!URL:%%a=!"
@REM     )
@REM )

@REM for %%a in ("/", ".git") do (
@REM     if "!URL:%%a=!" neq "!URL!" (
@REM         set "URL=!URL:%%a=!"
@REM     )
@REM )
echo %ICON%%URL%