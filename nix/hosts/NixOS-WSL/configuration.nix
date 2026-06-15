{
  pkgs,
  inputs,
  username,
  ...
}:
{
  networking.hostName = "NixOS-WSL";

  environment.systemPackages = (
    (import ../../shared/lists { inherit pkgs; })
    # ++ (import ../../shared/lists/10_extra.nix { inherit pkgs; })
    # ++ (import ../../shared/lists/test.nix { inherit pkgs; })
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
