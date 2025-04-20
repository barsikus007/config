{
  config,
  lib,
  pkgs,
  ...
}:
{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  networking.hostName = "ROG14"; # Define your hostname

  environment.systemPackages = (import ../../packages { inherit pkgs; });

  boot.kernelPackages = [ pkgs.linuxPackages_xanmod_stable ];

  # services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/desktop-managers/plasma6.nix#L159-L174
  #   # plasma-browser-integration
  #   # konsole
  #   # (lib.getBin qttools) # Expose qdbus in PATH
  #   # ark
  #   # elisa
  #   # gwenview
  #   # okular
  #   # kate
  #   # khelpcenter
  #   # dolphin
  #   # baloo-widgets # baloo information in Dolphin
  #   # dolphin-plugins
  #   # spectacle
  #   # ffmpegthumbs
  #   # krdp
  #   # xwaylandvideobridge # exposes Wayland windows to X11 screen capture
  # ];

  # https://asus-linux.org/guides/nixos/
  services.supergfxd.enable = true;
  # try with supergfxctl -S
  # systemd.services.supergfxd.path = [ pkgs.pciutils ];
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

}
