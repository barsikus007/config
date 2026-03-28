{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      # https://wiki.archlinux.org/title/Libvirt#Virtio-FS
      vhostUserPackages = with pkgs; [
        #? https://gitlab.com/virtio-fs/virtiofsd/-/work_items/96#note_2957238906
        #! THANKS FOR THIS DUCKED UP WAY: https://nea.moe/blog/patching-nix-packages/
        (virtiofsd.override {
          rustPlatform.buildRustPackage = (
            oldAttrsGen:
            rustPlatform.buildRustPackage (
              finalAttrs:
              (oldAttrsGen finalAttrs)
              // {
                version = "1.13.3";

                src = fetchFromGitLab {
                  owner = "virtio-fs";
                  repo = "virtiofsd";
                  rev = "7250c77366c964deccf21d97e0c0df161da40a93";
                  hash = "sha256-3G9xM9s1tK5XsaEQLw/10KMpfIoMbo66Kxlbfo3APsY=";
                };

                cargoHash = "sha256-2T2ky5h7N5VUga2Dcckhx0mXauFcMsz95fumrppnMH8=";
              }
            )
          );
        })
      ];
    };
  };
  users.users.${username}.extraGroups = [
    "kvm"
    "libvirtd"
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}
