{ pkgs, username, ... }:
{
  imports = [
    ./kde-sunshined.nix
  ];
  virtualisation.vmVariant = {
    virtualisation = {
      qemu.options = [
        "-device vfio-pci,host=01:00.0,x-vga=on"
      ];
    };

    environment.systemPackages =
      with pkgs;
      [
        gpu-screen-recorder
        gpu-screen-recorder-gtk
      ]
      ++ import ../../shared/lists { inherit pkgs; };
    users.users.${username}.extraGroups = [ "video" ];
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;
  };
}
