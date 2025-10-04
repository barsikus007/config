{ pkgs, ... }:
#? 🙏 https://github.com/ViZiD/dotfiles/blob/master/modules/shared/zapret.nix
#? https://github.com/Flowseal/zapret-discord-youtube/blob/main/general.bat
let
  list-general = pkgs.fetchurl {
    # https://github.com/Flowseal/zapret-discord-youtube/blob/main/lists/list-general.txt
    url = "https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/779853740f9c957551685bdebf59ad3a788b5004/lists/list-general.txt";
    sha256 = "sha256-/9dYk5fiVLfN+bY0STlqutnRQQoInS9NBGg9fWHZedk=";
  };
in
{
  services.zapret = {
    enable = false;
    udpSupport = true;
    udpPorts = [
      "443"
      "50000:50099"
    ];
    params = [
      "--filter-tcp=80"
      "--hostlist=${list-general}"
      "--dpi-desync=fake,split2"
      "--dpi-desync-autottl=2"
      "--dpi-desync-fooling=md5sig"

      "--new"
      "--filter-tcp=443"
      "--hostlist=${list-general}"
      "--dpi-desync=fake,multidisorder"
      "--dpi-desync-split-pos=midsld"
      "--dpi-desync-repeats=8"
      "--dpi-desync-fooling=md5sig,badseq"

      "--new"
      "--filter-udp=443"
      "--hostlist=${list-general}"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"

      "--new"
      "--filter-udp=50000-50099"
      "--filter-l7=discord,stun"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
    ];
  };
}
