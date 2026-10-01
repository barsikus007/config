{ fetchurl, runCommand }:
let
  generatedXml = fetchurl {
    name = "raw.autounattend.xml";
    # echo $url | sed 's|=|" = "|g' | sed 's|&|";\n"|g'
    url = "https://schneegans.de/windows/unattend-generator/view/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-US&Keyboard=00000409&UseKeyboard2=true&Locale2=ru-RU&Keyboard2=00000419&GeoLocation=203&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&UseConfigurationSet=true&ComputerNameMode=Custom&ComputerName=NIXOS-WIN10-VRT&SystemSize=300&TimeZoneMode=Implicit&PartitionMode=Unattended&PartitionLayout=GPT&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Custom&ProductKey=QPM6N-7J2WJ-P88HH-P3YRH-YY74H&InstallFromMode=Index&InstallFromIndex=1&PEMode=Generated&UserAccountMode=Unattended&AccountName0=Admin&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AutoLogonMode=Own&PasswordExpirationMode=Unlimited&LockoutMode=Default&HideFiles=HiddenSystem&ShowFileExtensions=true&LaunchToThisPC=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&HideTaskViewButton=true&ShowAllTrayIcons=true&DisableBingResults=true&StartTilesMode=Empty&StartPinsMode=Default&DisableDefender=true&DisableSmartScreen=true&EnableLongPaths=true&DeleteJunctions=true&HideEdgeFre=true&DisableEdgeStartupBoost=true&DisablePointerPrecision=true&EffectsMode=Default&DesktopIconsMode=Default&StartFoldersMode=Default&WifiMode=Skip&ExpressSettings=DisableAll&LockKeysMode=Skip&StickyKeysMode=Default&ColorMode=Default&WallpaperMode=Default&LockScreenMode=Default&FirstLogonScript0=Get-Content%20-LiteralPath%20%27C%3A%5CWindows%5CSetup%5CScripts%5CAdditionalVMSetup.ps1%27%20-Raw%20%7C%20Invoke-Expression;&FirstLogonScriptType0=Ps1&WdacMode=Skip&TargetDisk=0&TargetDiskMode=Generated&TargetDiskIndex=True&UseActivationKey=True&ActivationKey=QPM6N-7J2WJ-P88HH-P3YRH-YY74H";
    # remove `view/` from link above to edit or change to `iso/` to download iso packed file
    hash = "sha256-P/TWX0NhIt4B/46dvSA1Js57lDwIVX+lddkmUEClu8o=";
  };
in
runCommand "autounattend.xml" { } "cp ${generatedXml} $out"
