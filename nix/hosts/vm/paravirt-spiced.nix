{
  imports = [ ./minimal.nix ];
  virtualisation.vmVariant.virtualisation.qemu.options = [
    #? https://wiki.archlinux.org/title/QEMU#virtio
    "-device virtio-vga-gl" # ? paravirt 3d gpu

    "-display gtk,gl=on,grab-on-hover=on" # ",show-cursor=off"
    # "-full-screen"

    #! it crashes my amdgpu iGPU with -12
    #? remote-viewer spice+unix:///run/user/1000/qemu/coolvm/spice.sock
    # "-spice gl=on,disable-ticketing=on,unix=on,addr=/run/user/1000/qemu/coolvm/spice.sock"
    # "-display spice-app,gl=on"

    #? https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
    #! spice-vdagent: non-exist and not started: https://github.com/nixos/nixpkgs/issues/481078
    #! broken on wayland: https://github.com/agentydragon/ducktape/blob/2ae95aa22b6138174745d6f8d6dcd5a16d1e46e5/debug/wyrm2_graphics_boot.md#clipboard-sharing
    "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
    "-device virtio-serial-pci"
    "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"

    "-audiodev pipewire,id=system"
    "-device virtio-sound-pci,audiodev=system"
  ];
}
