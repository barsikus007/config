{ pkgs, ... }:
{
  imports = [
    ./podman.nix
    # ./docker.nix
    # (import ./docker.nix { rootless = true; })
  ];

  environment.systemPackages = with pkgs; [
    lazydocker
    dive
  ];
}
