{
  pkgs,
  inputs,
  username,
  ...
}:
{
  networking.hostName = "NixOS-WSL";

  environment.systemPackages = builtins.concatLists (
    map (pkgsList: import pkgsList { inherit pkgs; }) [
      ../../shared/lists
      # ../../shared/lists/10_extra.nix
      # ../../shared/lists/99_test.nix
    ]
  );

  imports = [
    ../.
    inputs.nixos-wsl.nixosModules.default
  ];

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
