{ pkgs, ... }:
{
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
  ];
}
