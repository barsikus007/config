{
  pkgs,
  inputs,
  username,
  ...
}:
{
  networking.hostName = "NixOS-WSL";

  #! add this to flake inputs
  #? nixos-wsl = {
  #?   url = "github:nix-community/NixOS-WSL";
  #?   inputs.nixpkgs.follows = "nixpkgs";
  #?   inputs.flake-compat.follows = "flake-compat";
  #? };

  imports = [
    inputs.nixos-wsl.nixosModules.default

    ../.
  ];

  environment.systemPackages = builtins.concatLists (
    map (pkgsList: import pkgsList { inherit pkgs; }) [
      ../../shared/lists
      # ../../shared/lists/10_extra.nix
      # ../../shared/lists/99_test.nix
    ]
  );

  #? https://github.com/nix-community/NixOS-WSL
  wsl = {
    enable = true;
    defaultUser = username;
    docker-desktop.enable = true;
    interop.register = true;
    startMenuLaunchers = true;
    usbip.enable = true;
  };
}
