{ pkgs, config, ... }:
#? sudo udevadm control --reload-rules && sudo udevadm trigger
{
  # USB
  hardware.xpad-noone.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ xone ];
  # BT
  hardware.xpadneo.enable = true;
  #? https://discourse.nixos.org/t/no-input-with-xpadneo-since-systemd-258/73514
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "60-xpadneo";
      text = ''
        # Rebind driver to xpadneo
        ACTION=="bind", SUBSYSTEM=="hid", DRIVER!="xpadneo", KERNEL=="0005:045E:*", KERNEL=="*:02FD.*|*:02E0.*|*:0B05.*|*:0B13.*|*:0B20.*|*:0B22.*", ATTR{driver/unbind}="%k", ATTR{[drivers/hid:xpadneo]bind}="%k"

        # Tag xpadneo devices for access in the user session
        ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="input", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/60-xpadneo.rules";
    })
    (pkgs.writeTextFile {
      name = "70-xpadneo-disable-hidraw";
      text = ''
        ACTION!="remove", DRIVERS=="xpadneo", SUBSYSTEM=="hidraw", MODE:="0000", TAG-="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-xpadneo-disable-hidraw.rules";
    })
  ];
  # services.udev.extraRules = ''
  #   # Xbox One Elite 2 Controller
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*045E:0B22*", MODE="0660", TAG+="uaccess"
  # '';
  #? , ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_CONTROLLER}="1"
}
