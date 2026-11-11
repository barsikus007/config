{
  pkgs,
  baseImage,
}:

pkgs.writeShellApplication {
  name = "openwrt-vm";
  runtimeInputs = with pkgs; [
    coreutils
    qemu
  ];
  text = ''
    disk="''${OPENWRT_VM_DISK:-$PWD/openwrt-vm.qcow2}"
    ssh_port="''${OPENWRT_VM_SSH_PORT:-62222}"
    luci_port="''${OPENWRT_VM_LUCI_PORT:-60080}"
    lan_subnet="''${OPENWRT_VM_LAN_SUBNET:-192.168.1}"
    reset=false
    qemu_args=()

    for arg in "$@"; do
      case "$arg" in
        (--reset)
          reset=true
          ;;
        (--help)
          echo "usage: openwrt-vm [--reset] [extra qemu args...]"
          echo "  disk overlay: $disk"
          echo "  forwarded ports:"
          echo "    host:$ssh_port -> guest:2222 (Dropbear SSH)"
          echo "    host:$luci_port -> guest:80   (LuCI Web UI)"
          echo "  exit QEMU: Ctrl-A x"
          exit 0
          ;;
        *)
          qemu_args+=("$arg")
          ;;
      esac
    done

    if [ "$reset" = true ] && [ -f "$disk" ]; then
      echo "Removing existing disk overlay: $disk"
      rm --force "$disk"
    fi

    if [ ! -f "$disk" ]; then
      echo "Creating new qcow2 overlay: $disk"
      qemu-img create -f qcow2 -b "${baseImage}/openwrt.qcow2" -F qcow2 "$disk"
    fi

    echo "Starting OpenWrt VM..."
    echo "  SSH:  ssh -p $ssh_port root@127.0.0.1"
    echo "  LuCI: http://127.0.0.1:$luci_port"
    echo "  Exit: Ctrl-A x"

    exec qemu-system-x86_64 \
      -enable-kvm \
      -cpu host \
      -m 1024 \
      -smp 2 \
      -drive "file=$disk,if=virtio,format=qcow2" \
      -netdev "user,id=lan,net=$lan_subnet.0/24,restrict=on,hostfwd=tcp:127.0.0.1:$ssh_port-$lan_subnet.1:2222,hostfwd=tcp:127.0.0.1:$luci_port-$lan_subnet.1:80" \
      -device "virtio-net-pci,netdev=lan,mac=52:54:00:12:34:01" \
      -netdev "user,id=wan,net=10.0.2.0/24" \
      -device "virtio-net-pci,netdev=wan,mac=52:54:00:12:34:02" \
      -nographic \
      -serial "mon:stdio" \
      "''${qemu_args[@]}"
  '';
}
