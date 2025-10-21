{ lib, pkgs, ... }:
{
  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = lib.mkForce [
      #? "https://cache.nixos.org/" cloudflare mirror, uses original keys
      "https://nixos-cache-proxy.cofob.dev"

      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
