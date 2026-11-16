{ lib, pkgs, ... }:
{
  openwrt.vm = import ./vm.nix { inherit lib pkgs; };
}
