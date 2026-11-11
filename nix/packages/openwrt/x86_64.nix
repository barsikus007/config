{ pkgs, inputs, ... }:
#? https://openwrt.org/docs/guide-user/virtualization/qemu
let
  profile = {
    release = "25.12.6";
    target = "x86";
    variant = "64";
    profile = "generic";
  };
  arch = "${profile.target}_${profile.variant}";

  common = import ./. { inherit pkgs arch profile; };

  rawImage = inputs.openwrt-imagebuilder.lib.build (
    common
    // {
      inherit pkgs;
      inherit (profile)
        release
        target
        variant
        profile
        ;
      packages = common.packages ++ [ "qemu-ga" ];

      rootFsPartSize = 512;

      files = pkgs.runCommand "openwrt-vm-files" { } ''
        mkdir -p "$out"
        cp -r --no-preserve=all "${common.files}/"* "$out/"

        cat > "$out/etc/uci-defaults/99-vm-init" <<'EOF'
        #!/bin/sh
        uci set network.lan.device='eth0'
        uci set network.wan.device='eth1'
        uci set network.wan.proto='dhcp'
        uci set dropbear.@dropbear[0].Port='2222'
        uci set dropbear.@dropbear[0].PasswordAuth='off'
        uci set dropbear.@dropbear[0].RootPasswordAuth='off'
        uci commit
        EOF
        chmod 0755 "$out/etc/uci-defaults/99-vm-init"
      '';
    }
  );
in
pkgs.runCommand "openwrt-x86_64-qcow2"
  {
    nativeBuildInputs = with pkgs; [
      qemu-utils
      gzip
    ];
    passthru = {
      inherit rawImage;
    };
  }
  ''
    mkdir -p "$out"
    shopt -s nullglob
    raw_gz=("${rawImage}"/openwrt-*-x86-64-generic-squashfs-combined.img.gz)
    if [ "''${#raw_gz[@]}" -eq 0 ]; then
      raw_gz=("${rawImage}"/openwrt-*-x86-64-generic-ext4-combined.img.gz)
    fi
    if [ "''${#raw_gz[@]}" -eq 0 ]; then
      echo "Could not find OpenWrt combined image in ${rawImage}"
      exit 1
    fi
    gzip --decompress --stdout "''${raw_gz[0]}" > raw.img 2>/dev/null || [ $? -eq 2 ]
    qemu-img convert -f raw -O qcow2 raw.img "$out/openwrt.qcow2"
    rm --force raw.img
  ''
