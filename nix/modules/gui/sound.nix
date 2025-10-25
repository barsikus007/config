{
  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.pipewire.extraConfig.pipewire = {
    "10-fix-popping" = {
      #? https://ventureo.codeberg.page/source/sound.html#choppy-audio
      "context.properties" = {
        #? multiply min-quantum while sound still popping (starting from 512)
        default.clock.min-quantum = 1024;
        default.clock.quantum = 4096;
        default.clock.max-quantum = 8192;
      };
      # TODO: unknown source, but it helped with popping :/ (stream.properties is assume)
      "pulse.properties" = {
        "pulse.min.req" = "1024/48000";
        "pulse.default.req" = "4096/48000";
        "pulse.max.req" = "8192/48000";
        "pulse.min.quantum" = "1024/48000";
        "pulse.max.quantum" = "8192/48000";
      };
      "stream.properties" = {
        "node.latency" = "2048/44100";
        "resample.quality" = 4;
      };
    };
    "20-no-resampling" = {
      #? https://ventureo.codeberg.page/source/sound.html#pipewire-setup
      "context.properties" = {
        #? default
        # default.clock.rate = 48000;
        #? cat /proc/asound/cards
        #? cat /proc/asound/card*/codec\#* | grep -A 8 "Audio Output" -m 1 | grep rates
        default.clock.allow-rates = [
          # NVidia HDMI audio
          32000
          44100
          48000
          88200
          96000
          176400
          192000
        ];
      };
    };
  };
  # TODO: idk2
  # boot.kernelParams = [ "preempt=full" ];
  ##boot.kernelModules = [
  ##  "snd-seq"
  ##  "snd-rawmidi"
  ##];
  # security.rtkit = {
  #   args = pkgs.lib.cli.toGNUCommandLine { optionValueSeparator = "="; } {
  #     scheduling-policy = "FIFO";
  #     our-realtime-priority = 89;
  #     max-realtime-priority = 88;
  #     min-nice-level = -19;
  #     rttime-usec-max = 2000000;
  #     users-max = 100;
  #     processes-per-user-max = 1000;
  #     threads-per-user-max = 10000;
  #     actions-burst-sec = 10;
  #     actions-per-burst-max = 1000;
  #     canary-cheep-msec = 30000;
  #     canary-watchdog-msec = 60000;
  #   };
  # };
  # security.pam.loginLimits = [
  #   {
  #     domain = "@users";
  #     item = "memlock";
  #     type = "-";
  #     value = "unlimited";
  #   }
  #   {
  #     domain = "@users";
  #     item = "rtprio";
  #     type = "-";
  #     value = 95;
  #   }
  #   {
  #     domain = "@users";
  #     item = "nice";
  #     type = "-";
  #     value = -19;
  #   }
  # ];
}
