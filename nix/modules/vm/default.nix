{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  # TODO: is needed? https://wiki.nixos.org/wiki/Libvirt#Default_networking
  environment.systemPackages = with pkgs; [ dnsmasq ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      #! https://github.com/virtio-win/virtio-win-guest-tools-installer
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  users.users.${username}.extraGroups = [ "libvirtd" ];

  virtualisation.spiceUSBRedirection.enable = true;
}
