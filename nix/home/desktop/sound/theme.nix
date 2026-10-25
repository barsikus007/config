{ pkgs, ... }:
let
  themeName = "custom";
  notificationSound = pkgs.fetchurl {
    url = "https://deltarune.wiki/images/Snd_ominous_music.wav";
    hash = "sha256-Dv1sO1/Se90U8S7sIuRxMihKgctm/j/q/ccvxATYSOM=";
  };
in
{
  xdg.dataFile = {
    "sounds/${themeName}/index.theme".text = ''
      [Sound Theme]
      Name=${themeName}
      Directories=stereo
      Inherits=freedesktop

      [stereo]
      OutputProfile=stereo
    '';
    "sounds/${themeName}/stereo/message-new-instant.wav".source = notificationSound;
    #! https://github.com/noctalia-dev/noctalia/issues/4725
    "sounds/${themeName}/stereo/message-new-instant-critical.wav".source = notificationSound;
  };
}
