{ pkgs, inputs, ... }:
{
  # imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/programs/nekoray.nix" ];
  programs.nekoray = {
    enable = true;
    # package = pkgs.nekoray;
    tunMode = {
      enable = true;
      # setuid = true;
    };
  };
}
