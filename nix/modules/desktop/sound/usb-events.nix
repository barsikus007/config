{ lib, pkgs, ... }:
let
  #? https://archive.org/details/Microsoft_Windows-8-System-Sounds
  windowsHardwareSound =
    name: hash:
    pkgs.fetchurl {
      name = "windows-hardware-${lib.toLower name}.wav";
      url = "https://archive.org/download/Microsoft_Windows-8-System-Sounds/Windows-8-sound-effects%2FWindows8_sounds_%5Bwinsounds.com%5D_1686%2FWindows%20Hardware%20${name}.wav";
      inherit hash;
    };
  sounds = {
    add = windowsHardwareSound "Insert" "sha256-6WB7RLUdurkiSbmKQwGy4gETvjrBgeIfMNcpvbjuBGM=";
    remove = windowsHardwareSound "Remove" "sha256-vkeB7kHtYWove8qM0eUootfdHxtYJOOY5l20vuRV1o4=";
  };

  systemd-run = lib.getExe' pkgs.systemd "systemd-run";
  pw-play = lib.getExe' pkgs.pipewire "pw-play";

  #? udev runs as root while pipewire lives in the user session,
  #? so spawn a transient unit per logged-in user with their runtime dir
  playForAllUsers = pkgs.writeShellApplication {
    name = "usb-sound-play";
    text = /* shell */ ''
      for runtime_dir in /run/user/*; do
        [ -S "$runtime_dir/pipewire-0" ] || continue
        ${systemd-run} --quiet --collect \
          --uid="''${runtime_dir##*/}" \
          --setenv="XDG_RUNTIME_DIR=$runtime_dir" \
          -- ${pw-play} "$1" || :
      done
    '';
  };
in
{
  #? DEVTYPE=usb_device gives one event per physical device, usb_interface fires per function
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="${lib.getExe playForAllUsers} ${sounds.add}"
    ACTION=="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="${lib.getExe playForAllUsers} ${sounds.remove}"
  '';
}
