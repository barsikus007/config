{ unstable, nixpkgs-unstable, ... }:
{
  # Override networking.wg-quick to use unstable's module
  disabledModules = [ "services/networking/wg-quick.nix" ];
  imports = [
    "${nixpkgs-unstable}/nixos/modules/services/networking/wg-quick.nix"
  ];
  # Overlay to include amneziawg-tools
  nixpkgs.overlays = [
    (self: super: {
      amneziawg-tools = unstable.amneziawg-tools;
    })
  ];

  # Include amneziawg package from unstable
  environment.systemPackages = with unstable; [
    wireguard-tools # Contains amneziawg support
    amneziawg-tools
  ];
}
