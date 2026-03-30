{ config, username, ... }:
{
  boot.initrd = {
    #! lspci -v | grep -iA8 'network\|ethernet'
    availableKernelModules = [ "r8169" ];
    network = {
      enable = true;
      udhcpc.enable = true;
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 22222;
        authorizedKeys = config.users.users.${username}.openssh.authorizedKeys.keys;
        #! sudo mkdir -p /etc/secrets/initrd/ && sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        # Import all pools
        zpool import -a
        # Add the load-key command to the .profile
        echo "zfs load-key -a; killall zfs; exit" >> /root/.profile
      '';
    };
  };
}
