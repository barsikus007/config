{ pkgs, username, ... }:
# https://wiki.nixos.org/wiki/Virt-manager
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      # https://wiki.archlinux.org/title/Libvirt#Virtio-FS
      vhostUserPackages = with pkgs; [
        # TODO: unstable: https://gitlab.com/virtio-fs/virtiofsd/-/releases
        #? https://gitlab.com/virtio-fs/virtiofsd/-/work_items/96#note_2957238906
        #! THANKS FOR THIS DUCKED UP WAY: https://nea.moe/blog/patching-nix-packages/
        (virtiofsd.override {
          rustPlatform.buildRustPackage = (
            oldAttrsGen:
            rustPlatform.buildRustPackage (
              finalAttrs:
              (oldAttrsGen finalAttrs)
              // {
                version = "1.14.0";

                src = fetchFromGitLab {
                  owner = "virtio-fs";
                  repo = "virtiofsd";
                  rev = "v${finalAttrs.version}";
                  hash = "sha256-NeqeSqPeD3hjAcbck+g8bmarbUL1Nks8AMAi/WxwzwY=";
                };

                cargoHash = "sha256-7byiMT2/jf0R7zHr/HBeXKk2T+OQhlVhZ9QJHlEY/Ao=";
              }
            )
          );
        })
      ];
    };
  };
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  users.users.${username}.extraGroups = [
    "kvm"
    "libvirtd"
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}
