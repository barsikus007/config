{
  lib,
  pkgs,
  config,
  ...
}:
{
  # USB
  hardware.xpad-noone.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ xone ];
  # BT
  hardware.xpadneo.enable = true;
  #? vibecoded shutfixes for xbox elite controller
  #! disable hidraw to stop SDL/Steam Input/Proton from messing gamepad
  #! 0B22 -- BT-HID id of xbox elite controller
  #! steam-devices (60-steam-input) adds uaccess, and 73-seat-late re-adds it via a sticky tag,
  #! so MODE=0000 isn't enough -- strip the ACL with a late RUN (99-local runs after uaccess)
  #? /dev/input/xbox_gamepad is stable symlink for xpadneo(BT) "Xbox Wireless Controller"; phys!="" to remove Steam one
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*045E:0B22*", OWNER:="root", GROUP:="root", MODE:="0000", RUN+="${lib.getExe' pkgs.acl "setfacl"} -b /dev/%k"
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Xbox Wireless Controller", ATTRS{phys}=="?*", SYMLINK+="input/xbox_gamepad"
  '';
}
