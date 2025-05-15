{ pkgs, inputs, ... }:
#? 🙏 https://github.com/ViZiD/dotfiles/blob/master/modules/shared/zapret.nix
{
  disabledModules = [ "services/networking/zapret.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/zapret.nix" ];
  services.zapret = {
    enable = true;
    package = pkgs.unstable.zapret;
    udpSupport = true;
    udpPorts = [
      "443"
      "50000:50099"
    ];
    params = [
      "--filter-tcp=80,443"
      "--dpi-desync=fake,disorder2"
      "--dpi-desync-ttl=1"
      "--dpi-desync-autottl=2"

      ## I don't care until it's works
      ## "--dpi-desync=fake,multidisorder"
      ## "--dpi-desync-ttl=3"

      ## "--new"
      ## "--filter-udp=443"
      ## "--dpi-desync=fake"
      ## "--dpi-desync-repeats=2"

      "--new"
      "--filter-udp=50000-50099"
      "--filter-l7=discord,stun"
      "--dpi-desync=fake"
      ## "--dpi-desync-any-protocol"
    ];
  };
}
