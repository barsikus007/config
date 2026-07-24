{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      #? https://wiki.archlinux.org/title/Libvirt#Virtio-FS
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  users.users.${username}.extraGroups = [
    "kvm"
    "libvirtd"
  ];

  virtualisation.spiceUSBRedirection.enable = true;

  #? QEMU with VFIO pins the whole guest RAM
  security.pam.loginLimits = [
    {
      domain = username;
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];
  #? same as libvirtd VFIO ACLs
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", OWNER="${username}", MODE="0600"
  '';
}
