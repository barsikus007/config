{
  lib,
  pkgs,
  self,
  ...
}:
let
  #? t.me paths don't map 1:1 to tg:// - tg:// uses resolve?domain=/join?invite=/etc,
  #? see https://core.telegram.org/api/links for the full mapping
  tgClient = "AyuGram";
  tgMeOpen = pkgs.writeShellApplication {
    name = "tg-me-open";
    text = /* shell */ ''
      url=$1
      rest=''${url#*://}
      rest=''${rest#*/}
      path="/''${rest%%\?*}"
      query=""
      [[ "$rest" == *\?* ]] && query="''${rest#*\?}"

      case "$path" in
        /+*)
          tguri="tg://join?invite=''${path#/+}"
          ;;
        /joinchat/*)
          tguri="tg://join?invite=''${path#/joinchat/}"
          ;;
        /c/*)
          IFS='/' read -r _ _ channel post _ <<< "$path"
          tguri="tg://privatepost?channel=''${channel}"
          [[ -n "''${post:-}" ]] && tguri="''${tguri}&post=''${post}"
          ;;
        /addstickers/*)
          tguri="tg://addstickers?set=''${path#/addstickers/}"
          ;;
        /addemoji/*)
          tguri="tg://addemoji?set=''${path#/addemoji/}"
          ;;
        *)
          IFS='/' read -r _ domain post _ <<< "$path"
          tguri="tg://resolve?domain=''${domain}"
          [[ "''${post:-}" =~ ^[0-9]+$ ]] && tguri="''${tguri}&post=''${post}"
          ;;
      esac

      if [[ -n "$query" ]]; then
        case "$tguri" in
          *\?*) tguri="''${tguri}&''${query}" ;;
          *) tguri="''${tguri}?''${query}" ;;
        esac
      fi

      exec env DESKTOPINTEGRATION=1 ${tgClient} -- "$tguri"
    '';
  };
in
{
  xdg.mimeApps = {
    defaultApplications = lib.genAttrs [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ] (key: "com.ayugram.desktop.desktop");
  };

  xdg.configFile."handlr/handlr.toml".text = /* toml */ ''
    [[handlers]]
    exec = "${lib.getExe tgMeOpen} %u"
    regexes = ['^https://(www\.)?(t\.me|telegram\.(me|dog))/.*']
  '';

  home.packages = with pkgs; [
    # ayugram-desktop
    self.packages.${stdenv.hostPlatform.system}.ayugram-desktop-updated
    # self.legacyPackages.${stdenv.hostPlatform.system}.ayugram-desktop-patched
  ];
}
