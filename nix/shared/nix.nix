{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nix.package = pkgs.nix;
  nix.channel.enable = false;
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
  nix.settings = {
    auto-optimise-store = true;
    use-xdg-base-directories = true;
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    substituters = lib.mkForce [
      "https://cache.nixos.org"
      # "https://nixos-cache-proxy.cofob.dev" # ? cloudflare mirror, uses original keys

      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
