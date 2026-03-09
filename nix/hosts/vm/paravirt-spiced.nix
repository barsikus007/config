{
  imports = [ ./minimal.nix ];
  virtualisation.vmVariant.virtualisation.qemu.options = [
    #? https://wiki.archlinux.org/title/QEMU#virtio
    "-device virtio-vga-gl" # ? paravirt 3d gpu

    "-display gtk,gl=on,grab-on-hover=on" # "-show-cursor=off"
    # "-full-screen"

    #? remote-viewer spice+unix:///run/user/1000/qemu/coolvm/spice.sock
    # "-spice gl=on,disable-ticketing=on,unix=on,addr=/run/user/1000/qemu/coolvm/spice.sock"
    # "-display spice-app,gl=on"

    # "-device virtio-serial-pci"
    # "-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
    # "-chardev spicevmc,id=spicechannel0,name=vdagent"
    "-device virtio-serial,packed=on,ioeventfd=on"
    "-device virtserialport,name=com.redhat.spice.0,chardev=vdagent0"
    "-chardev qemu-vdagent,id=vdagent0,name=vdagent,clipboard=on,mouse=off"

    "-device virtio-sound-pci,audiodev=system"
    "-audiodev pipewire,id=system"

    #TODO: https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
  ];
}
