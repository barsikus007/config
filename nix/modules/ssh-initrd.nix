{ config, username, ... }:
#? https://wiki.nixos.org/wiki/ZFS#Remote_unlock
#? https://wiki.nixos.org/wiki/Remote_disk_unlocking
{
  #! add network modules to boot.initrd.availableKernelModules inside of hardware-configuration.nix
  #! lspci -v | grep -iA8 'network\|ethernet'
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22220;
      authorizedKeys = config.users.users.${username}.openssh.authorizedKeys.keys;
      #! https://nix-community.github.io/nixos-anywhere/howtos/secrets.html#example-decrypting-an-openssh-host-key-with-pass
      #? ssh-keygen -t ed25519 -N "" -f ./ssh_host_ed25519_key
      #? temp=$(mktemp -d)
      #? install -d -m755 "$temp/persistent/etc/ssh/initrd"
      #? cp ./ssh_host_ed25519_key* "$temp/persistent/etc/ssh/initrd/"
      #? nixos-anywhere --extra-files "$temp" --disk-encryption-keys /tmp/secret.key /tmp/secret.key --flake ./nix#VPS --target-host VPS
      hostKeys = [ "/persistent/etc/ssh/initrd/ssh_host_ed25519_key" ];
    };
  };
  boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
}
