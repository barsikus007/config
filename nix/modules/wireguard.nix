{ inputs, pkgs, username, ... }:
{
  # Override networking.wg-quick to use unstable's module
  disabledModules = [ "services/networking/wg-quick.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/wg-quick.nix"
  ];
  # Overlay to include amneziawg-tools
  nixpkgs.overlays = [
    (self: super: {
      amneziawg-tools = pkgs.unstable.amneziawg-tools;
    })
  ];

  networking.wg-quick.interfaces = {
    awg0 = {
      autostart = false;
      type = "amneziawg"; # Provided by unstable
      # TODO: secrets
      configFile = "/home/${username}/awg0.conf";
    };
  };

  environment.systemPackages = with pkgs.unstable; [
    wireguard-tools
    amneziawg-tools
  ];
}
