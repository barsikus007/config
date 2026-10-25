{
  lib,
  pkgs,
  config,
  ...
}:
#! reuse installer tools without copying full systemd and ZFS closures into RAM
{
  system.build.diskoScript = lib.mkForce (
    pkgs.writeShellScript "disko-low-memory" ''
      set -euo pipefail
      export PATH=${
        lib.makeBinPath [
          pkgs.cryptsetup
          pkgs.btrfs-progs
          pkgs.gptfdisk
          pkgs.parted
          pkgs.dosfstools
        ]
      }:$PATH

      for command in bash btrfs cryptsetup mkfs.btrfs mkfs.vfat sgdisk partprobe \
        blkid findmnt lsblk mount umount wipefs swapoff jq udevadm grep sed; do
        if ! command -v "$command" >/dev/null; then
          printf 'missing installer command: %s\n' "$command" >&2
          exit 1
        fi
      done

      exec bash ${(config.disko.devices._scripts { inherit pkgs; }).diskoScriptNoDeps} "$@"
    ''
  );
}
