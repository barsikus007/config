{ runCommand }:
let
  #? echo $paramsurl | sed 's|=|" = "|g' | sed 's|&|";\n"|g'
  paramsurl = "LanguageMode=Unattended&UILanguage=en-US&Locale=en-US&Keyboard=00000409&UseKeyboard2=true&Locale2=ru-RU&Keyboard2=00000419&GeoLocation=203&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&UseConfigurationSet=true&ComputerNameMode=Custom&ComputerName=NIXOS-WIN10-VRT&CompactOsMode=Default&TimeZoneMode=Implicit&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Custom&ProductKey=QPM6N-7J2WJ-P88HH-P3YRH-YY74H&InstallFromMode=Automatic&PEMode=Default&UserAccountMode=Unattended&AccountName0=Admin&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AutoLogonMode=Own&PasswordExpirationMode=Unlimited&LockoutMode=Default&HideFiles=HiddenSystem&ShowFileExtensions=true&LaunchToThisPC=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&HideTaskViewButton=true&ShowAllTrayIcons=true&DisableBingResults=true&StartTilesMode=Empty&StartPinsMode=Default&DisableDefender=true&DisableSmartScreen=true&EnableLongPaths=true&DeleteJunctions=true&HideEdgeFre=true&DisableEdgeStartupBoost=true&DisablePointerPrecision=true&EffectsMode=Default&DesktopIconsMode=Default&StartFoldersMode=Default&VirtIoGuestTools=true&WifiMode=Skip&ExpressSettings=DisableAll&LockKeysMode=Skip&StickyKeysMode=Default&ColorMode=Default&WallpaperMode=Default&LockScreenMode=Default&SystemScript0=C%3A%5CWindows%5CSetup%5CScripts%5CInstall.ps1&SystemScriptType0=Ps1&WdacMode=Skip";
  generatedXml = builtins.fetchurl {
    name = "raw.autounattend.xml";
    url = "https://schneegans.de/windows/unattend-generator/view/?${paramsurl}";
    # sha256 = "";
    sha256 = "sha256-MDDu30dvAExvp311SBVKOdC2Y21JkwJfY10Aj3aU4So=";
  };
in
let
  extraFragment = builtins.toFile "extra.xml" ''
    <settings pass="specialize">
      <component name="Microsoft-Windows-Deployment"
                 processorArchitecture="amd64"
                 publicKeyToken="31bf3856ad364e35"
                 language="neutral"
                 versionScope="nonSxS">
        <RunSynchronous>
          <RunSynchronousCommand wcm:action="add">
            <Order>1</Order>
            <Path>powershell.exe -noprofile -ExecutionPolicy unrestricted C:\Windows\Setup\Scripts\InstallRequirements.ps1</Path>
          </RunSynchronousCommand>
        </RunSynchronous>
      </component>
    </settings>
  '';
in
runCommand "autounattend.xml" { } "cp ${generatedXml} $out"
# runCommand "autounattend.xml" { } ''
#   ${yq-go}/bin/yq eval '.unattend.settings += [ load("${extraFragment}") ]' "${generatedXml}" > $out
# ''
