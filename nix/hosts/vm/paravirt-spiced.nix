{
  imports = [ ./spice-vdagent-wayland.nix ];

  virtualisation.vmVariant.virtualisation.qemu.options = [
    "-monitor stdio"

    #? https://wiki.archlinux.org/title/QEMU#virtio
    "-device virtio-vga-gl" # ? paravirt 3d gpu

    # "-display gtk,gl=on,grab-on-hover=on,show-menubar=off"

    #? `remote-viewer spice+unix:///run/user/1000/qemu/coolvm/spice.sock`
    "-display spice-app,gl=on"

    "-chardev spicevmc,id=ch1,name=vdagent"
    #? https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
    #! qemu-vdagent wayland cliboard feature is disabled now
    # "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
    "-device virtio-serial-pci"
    "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"

    "-audiodev pipewire,id=system"
    "-device virtio-sound-pci,audiodev=system"
  ];
}
