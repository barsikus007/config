{ pkgs, username, ... }:
{
  networking.hostName = "ROG14-WSL"; # Define your hostname

  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.docker-desktop.enable = true;
  wsl.startMenuLaunchers = true;
  wsl.usbip.enable = true;

  # https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  programs.nix-ld = {
    enable = true;
  };

  environment.systemPackages = (import ../../shared/lists/base.nix { inherit pkgs; })
  # ++ (import ../../shared/lists/default.nix { inherit pkgs; })
  # ++ (import ../../shared/lists/test.nix { inherit pkgs; })
  #
  ;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
