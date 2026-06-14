{
  lib,
  pkgs,
  config,
  ...
}:
let
  #? native wayland support (unstable)
  winePkg = with pkgs; wineWow64Packages.unstableFull;

  #? map stylix base16 palette to wine `Control Panel\Colors` (space-separated RGB)
  c = config.lib.stylix.colors;
  wrgb =
    base: "${toString c."${base}-rgb-r"} ${toString c."${base}-rgb-g"} ${toString c."${base}-rgb-b"}";
  wineColors = {
    ActiveTitle = "base01";
    InactiveTitle = "base00";
    GradientActiveTitle = "base01";
    GradientInactiveTitle = "base00";
    TitleText = "base05";
    InactiveTitleText = "base04";
    Window = "base00";
    WindowText = "base05";
    WindowFrame = "base03";
    Menu = "base01";
    MenuText = "base05";
    MenuBar = "base01";
    ButtonFace = "base01";
    ButtonText = "base05";
    ButtonShadow = "base00";
    ButtonHighlight = "base02";
    ButtonLight = "base02";
    ButtonDkShadow = "base00";
    GrayText = "base03";
    Highlight = "base0D";
    HighlightText = "base00";
    MenuHilight = "base0D";
    Scrollbar = "base01";
    InfoText = "base05";
    InfoWindow = "base01";
    AppWorkSpace = "base00";
    ActiveBorder = "base01";
    InactiveBorder = "base00";
  };
  #? lines `Name R G B`, consumed by `read` in wine-setup-theme
  wineColorData = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: base: "${name} ${wrgb base}") wineColors
  );
in
{
  environment.systemPackages = with pkgs; [
    winePkg
    winetricks
    bottles
    (pkgs.writeShellApplication {
      name = "wine-setup";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine-setup-wayland
        wine-setup-theme
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-setup-theme";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine reg add 'HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager' /v ThemeActive /t REG_SZ /d 0 /f
        while read -r name value; do
          wine reg add 'HKCU\Control Panel\Colors' /v "$name" /t REG_SZ /d "$value" /f
        done <<'EOF'
        ${wineColorData}
        EOF
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-reset-theme";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine reg add 'HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager' /v ThemeActive /t REG_SZ /d 1 /f
        wine reg delete 'HKCU\Control Panel\Colors' /f
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-setup-wayland";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /t REG_SZ /d wayland /f
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-reset-wayland";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine reg delete 'HKCU\Software\Wine\Drivers' /v Graphics /f
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-setup-current-resolution";
      runtimeInputs = [
        winePkg
        pkgs.jq
        pkgs.niri
      ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        #! resolution of the currently focused niri output (kanshi-profile aware)
        res="$(niri msg --json focused-output | jq -r '.modes[.current_mode] | "\(.width)x\(.height)"')"
        wine reg add 'HKCU\Software\Wine\Explorer'          /v Desktop /t REG_SZ /d Default /f
        wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /t REG_SZ /d "$res"  /f
      '';
    })
    (pkgs.writeShellApplication {
      name = "wine-reset-resolution";
      runtimeInputs = [ winePkg ];
      text = /* shell */ ''
        export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
        wine reg delete 'HKCU\Software\Wine\Explorer' /f
      '';
    })
  ];

  #? https://github.com/fufexan/nix-gaming/blob/9d30426090a8d274eb20dc36bd28c6e37dc3589c/modules/wine.nix#L21
  environment.sessionVariables.WINE_BIN = lib.getExe winePkg;

  # add binfmt registration
  boot.binfmt.registrations."DOSWin" = {
    interpreter = lib.getExe winePkg;
    wrapInterpreterInShell = false;
    recognitionType = "magic";
    offset = 0;
    magicOrExtension = "MZ";
  };

  # load ntsync
  boot.kernelModules = [ "ntsync" ];

  # make ntsync device accessible
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "ntsync-udev-rules";
      text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/70-ntsync.rules";
    })
  ];
}
