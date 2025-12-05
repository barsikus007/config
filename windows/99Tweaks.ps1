Write-Host "disable UAC prompts" -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

Write-Host "set wt.exe as default" -ForegroundColor Green
Write-Host "TODO: check if wt.exe exists" -ForegroundColor DarkYellow
# $registryPath = "HKCU:\Console\%%Startup"
# if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force }

# # UUIDs for Windows Terminal
# Set-ItemProperty -Path $registryPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" -Type String
# Set-ItemProperty -Path $registryPath -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" -Type String

# Write-Host "Default terminal set to Windows Terminal."

Write-Host "set ru region" -ForegroundColor Green
Set-Culture ru-RU

Write-Host "enable seconds in taskbar" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 1 -Force

Write-Host "default ssh shell to pwsh.exe" -ForegroundColor Green
Write-Host "TODO: check if path exists C:\Program Files\PowerShell\7\pwsh.exe" -ForegroundColor DarkYellow
# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String –Force

Write-Host "set wallpaper to https://www.wallpaperhub.app/wallpapers/5512" -ForegroundColor Green
$Url = "https://www.wallpaperhub.app/_next/image?url=https%3A%2F%2Fcdn.wallpaperhub.app%2Fcloudcache%2Fd%2F1%2F5%2F6%2F9%2F4%2Fd156944bf7f0d9d246b7e40e5abd72aec3bd8304.png&w=4500&q=100"
$Dest = "$env:USERPROFILE\Pictures\current_wallpaper.png"
# 1. Download the image
Write-Host "downloading 4K image..." -NoNewline
Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
Write-Host "done."
# 2. Set as Wallpaper
$Code = @'
[DllImport("user32.dll")]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
'@
Add-Type -MemberDefinition $Code -Name "Win32" -Namespace Wallpaper -PassThru | Out-Null
[Wallpaper.Win32]::SystemParametersInfo(20, 0, $Dest, 3)

Write-Host "set theming" -ForegroundColor Green
$ThemePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
# 0 = Dark, 1 = Light
Set-ItemProperty -Path $ThemePath -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path $ThemePath -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path $ThemePath -Name "ColorPrevalence" -Value 1

Write-Host "set VirtIO network as private" -ForegroundColor Green
Get-NetAdapter | Where-Object InterfaceDescription -like "*VirtIO*" | Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Write-Host "set taskbar icons (explorer.exe, wt.exe, edge.exe)" -ForegroundColor Green
# 1. Define the XML content with the specific AppIDs you requested
$XmlContent = @'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:UWA AppUserModelID="Microsoft.WindowsTerminal_8wekyb3d8bbwe!App" />
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe!App" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@
# 2. Define Paths
# Path for the CURRENT user (May require re-login to apply)
$CurrentPath = "$env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml"
# 3. Write the file to the Current User profile
Write-Host "Configuring for Current User..." -ForegroundColor Cyan
try {
    # Create directory if missing
    $Dir = [System.IO.Path]::GetDirectoryName($CurrentPath)
    if (!(Test-Path $Dir)) { New-Item -ItemType Directory -Force -Path $Dir | Out-Null }

    # Write File
    $XmlContent | Out-File -FilePath $CurrentPath -Encoding utf8 -Force
    Write-Host "Success. You must SIGN OUT and SIGN BACK IN to see changes." -ForegroundColor Yellow
}
catch {
    Write-Error "Failed to update current user: $_"
}

Write-Host "TODO: 2nd: https://win10tweaker.ru/twikinarium/system" -ForegroundColor DarkYellow

Write-Host "TODO: notepad++.exe,7zFM.exe open by default" -ForegroundColor DarkYellow

Write-Host "TODO: enable clipboard history" -ForegroundColor DarkYellow
