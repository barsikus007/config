{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  environment.systemPackages = with pkgs; [
    # TODO: is needed? https://wiki.nixos.org/wiki/Libvirt#Default_networking
    dnsmasq
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      # https://wiki.archlinux.org/title/Libvirt#Virtio-FS
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  users.users.${username}.extraGroups = [ "libvirtd" ];

  virtualisation.spiceUSBRedirection.enable = true;
}
