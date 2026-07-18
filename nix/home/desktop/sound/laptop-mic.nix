let
  inherit (import ../../../hosts/ROG14/ids.nix) mic;
in
{
  xdg.dataFile."easyeffects/autoload/input/${mic.pipewireNode}:${mic.deviceProfile}.json".text =
    builtins.toJSON {
      device = mic.pipewireNode;
      preset-name = "LaptopMic";
      device-profile = mic.deviceProfile;
      device-description = mic.deviceDescription;
    };

  services.easyeffects.extraPresets = {
    #? only defaults
    LaptopMic = {
      input = {
        blocklist = [ ];
        plugins_order = [
          "echo_canceller#0"
          "rnnoise#0"
          "speex#0"
          "compressor#0"
        ];
        "echo_canceller#0"."noise-suppression".enable = false;
        "rnnoise#0"."enable-vad" = true;
        "speex#0" = {
          "enable-agc" = true;
          "enable-dereverb" = true;
          "vad".enable = true;
        };
        "compressor#0".mode = "Boosting";
      };
    };
  };
}
