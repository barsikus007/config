{ config, username, ... }:
#? https://wiki.nixos.org/wiki/ZFS#Remote_unlock
#? https://wiki.nixos.org/wiki/Remote_disk_unlocking
{
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22220;
      authorizedKeys = config.users.users.${username}.openssh.authorizedKeys.keys;
      hostKeys = [ "/persistent/etc/ssh/initrd/ssh_host_ed25519_key" ];
    };
  };
  boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
}
