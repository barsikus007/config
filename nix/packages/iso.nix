{
  pkgs,
  self,
  username,
  flakePath,
  ...
}:
#? https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{
  system.activationScripts.copyFlake = {
    text = ''
      if [ ! -d ${flakePath} ]; then
        mkdir --parents ${flakePath}
        cp --recursive ${self.outPath}/* ${flakePath}
        chown --recursive ${username}:100 ${flakePath}
      fi
    '';
  };

  imports = [
    ../shared/nix.nix
  ];
  environment.systemPackages = import ../shared/lists { inherit pkgs; };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    (pkgs.lib.strings.removeSuffix "\n" (
      builtins.readFile (
        builtins.fetchurl {
          url = "https://github.com/barsikus007.keys";
          sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
        }
      )
    ))
  ];
}
