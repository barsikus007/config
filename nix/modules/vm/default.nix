{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      # https://wiki.archlinux.org/title/Libvirt#Virtio-FS
      vhostUserPackages = with pkgs; [
        (callPackage ../../packages/virtiofsd/default.nix { })
      ];
    };
  };
  users.users.${username}.extraGroups = [
    "kvm"
    "libvirtd"
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}
