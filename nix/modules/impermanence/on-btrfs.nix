{ pkgs, config, ... }@args:
#! unmaintaned
let
  inherit (config.fileSystems."/nix") device;
  persistentDir = if args ? persistentDir then args.persistentDir else "/persistent";
in
{
  imports = [
    ../../modules/impermanence
  ];
  #? https://github.com/nix-community/impermanence/issues/320#issuecomment-4260870035
  boot.initrd.systemd = {
    services.impermance-btrfs-rolling-root = {
      description = "Archiving existing BTRFS root subvolume and creating a fresh one";
      # Specify dependencies explicitly
      unitConfig.DefaultDependencies = false;
      # The script needs to run to completion before this service is done
      serviceConfig = {
        Type = "oneshot";
        # NOTE: to be able to see errors in your script do this
        # StandardOutput = "journal+console";
        # StandardError = "journal+console";
      };
      # This service is required for boot to succeed
      requiredBy = [ "initrd.target" ];
      # Should complete before any file systems are mounted
      before = [ "sysroot.mount" ];

      # Wait until the root device is available
      # If you're altering a different device, specify its device unit explicitly.
      # see: systemd-escape(1)
      requires = [ "initrd-root-device.target" ];
      after = [
        "initrd-root-device.target"
        # Allow hibernation to resume before trying to alter any data
        "local-fs-pre.target"
      ];

      # The body of the script. Make your changes to data here
      script = ''
        mkdir /btrfs_tmp
        mount ${device} /btrfs_tmp
        if [[ -e /btrfs_tmp/@ ]]; then
          mkdir -p /btrfs_tmp/@-old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/@ "/btrfs_tmp/@-old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
        }

        #? delete old roots older than 30 days
        for i in $(find /btrfs_tmp/@-old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/@
        umount /btrfs_tmp
      '';
    };
    extraBin = with pkgs; {
      # "mkfs.ext4" = "${e2fsprogs}/bin/mkfs.ext4";
      "mkdir" = "${coreutils}/bin/mkdir";
      "date" = "${coreutils}/bin/date";
      "stat" = "${coreutils}/bin/stat";
      "mv" = "${coreutils}/bin/mv";
      "find" = "${findutils}/bin/find";
      "btrfs" = "${btrfs-progs}/bin/btrfs";
      # mount & umount already exist
    }; # NOTE: path = [...]; doesnt work for initrd, use full paths in your script or extraBin
  };

  # sudo cp -ax --reflink=always ...
  environment.persistence."${persistentDir}" = {
    # sudo cp -ax --reflink=always /var/lib{bluetooth,...,waydroid} /persistent/var/lib
    directories = [
      "/var/lib/btrfs"
    ];
  };
  # cp -ax --reflink=always /home/$USER/{...} /persistent/home/$USER/
}
