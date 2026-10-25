{
  services.pipewire.extraConfig = {
    pipewire = {
      "10-fix-popping" = {
        #? https://ventureo.codeberg.page/source/sound.html#choppy-audio
        "context.properties" = {
          #? multiply min-quantum while sound still popping (starting from 512)
          "default.clock.min-quantum" = 1024; # default 32
        };
      };
    };
  };

  #? browsers and apps based on them holds rt slots for hours after audio stops and rtkit never revokes them,
  #? so the default per-user process limit runs out and easyeffects gets denied
  # security.rtkit.args = [
  #   "--processes-per-user-max=64"
  #   "--threads-per-user-max=128"
  # ];
}
