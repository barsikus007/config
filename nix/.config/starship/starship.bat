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

if "!URL:~,5!"=="https" set "URL=!URL:~5!"
if "!URL:~,4!"=="http" set "URL=!URL:~4!"
if "!URL:~,3!"=="git" set "URL=!URL:~3!"
if "!URL:~,3!"=="://" set "URL=!URL:~3!"
if "!URL:~,1!"=="@" set "URL=!URL:~1!"

if "!URL:~-1!"=="/" set "URL=!URL:~,-1!"
if "!URL:~-4!"==".git" set "URL=!URL:~,-4!"

echo %ICON%%URL%