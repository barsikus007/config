{ pkgs, config, ... }:
let
  rootCaCert = pkgs.fetchurl {
    name = "russian-trusted-root-ca_pem.crt";
    url = "https://gu-st.ru/content/lending/russian_trusted_root_ca_pem.crt";
    hash = "sha256-k2pD/qbo5SW8wPgazZw9IbT8S5torOp5BtaYAFr8ZQQ=";
  };
  subCaCert = pkgs.fetchurl {
    name = "russian-trusted-sub-ca_pem.crt";
    url = "https://gu-st.ru/content/lending/russian_trusted_sub_ca_pem.crt";
    hash = "sha256-8K5YnzZ3TynvNkj3mEsI1C/M5vH/7rYjbXc9rrJ0TqY=";
  };

  amigoIcon = pkgs.fetchurl {
    name = "amigo.png";
    url = "https://upload.wikimedia.org/wikipedia/commons/c/c4/%D0%9B%D0%BE%D0%B3%D0%BE%D1%82%D0%B8%D0%BF_%D0%90%D0%BC%D0%B8%D0%B3%D0%BE.png";
    hash = "sha256-0IFXSQ9g5Dj74qe3tMdNqD1zocU1Rc1IDfHFEN8Szto=";
  };

  iconSizes = [
    "16x16"
    "32x32"
    "48x48"
    "64x64"
    "128x128"
    "256x256"
    "512x512"
  ];
  mkIcon =
    size:
    pkgs.runCommandLocal "amigo-icon-${size}.png"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      /* shell */ ''
        magick ${amigoIcon} -resize ${size} png:$out
      '';

  profileDir = "${config.xdg.configHome}/mozilla/firefox/cheburnet";

  firefoxCheburnet = pkgs.writeShellApplication {
    name = "firefox-cheburnet";
    runtimeInputs = with pkgs; [
      coreutils
      nssTools
      config.programs.firefox.finalPackage
    ];
    text = ''
      PROFILE_DIR="${profileDir}"
      mkdir --parents "$PROFILE_DIR"

      if ! certutil -L -d "sql:$PROFILE_DIR" -n "Russian Trusted Root CA" >/dev/null 2>&1; then
        certutil -A -d "sql:$PROFILE_DIR" -n "Russian Trusted Root CA" -t "C,," -i "${rootCaCert}"
      fi

      if ! certutil -L -d "sql:$PROFILE_DIR" -n "Russian Trusted Sub CA" >/dev/null 2>&1; then
        certutil -A -d "sql:$PROFILE_DIR" -n "Russian Trusted Sub CA" -t "C,," -i "${subCaCert}"
      fi

      exec env MOZ_APP_REMOTINGNAME=firefox-cheburnet \
        firefox \
        --class firefox-cheburnet \
        --profile "$PROFILE_DIR" \
        --no-remote \
        "$@"
    '';
  };
in
{
  home.packages = [ firefoxCheburnet ];

  xdg.dataFile = builtins.listToAttrs (
    map (s: {
      name = "icons/hicolor/${s}/apps/amigo.png";
      value.source = mkIcon s;
    }) iconSizes
  );

  programs.firefox.profiles.cheburnet = {
    id = 1;
    isDefault = false;
    settings = config.programs.firefox.profiles.default.settings // {
      # "browser.formfill.enable" = false;
    };
    inherit (config.programs.firefox.profiles.default) userChrome;
    search = removeAttrs config.programs.firefox.profiles.default.search [ "file" ];
  };

  xdg.desktopEntries.firefox-cheburnet = {
    name = "Амиго";
    genericName = "Браузер для общения и развлечений";
    comment = "Amigo: Cheburnet Explorer";
    exec = "firefox-cheburnet %u";
    icon = "amigo";
    type = "Application";
    categories = [
      "Network"
      "WebBrowser"
    ];
    settings = {
      Keywords = "browser;amigo;cheburnet;explorer";
      StartupWMClass = "firefox-cheburnet";
    };
  };
}
