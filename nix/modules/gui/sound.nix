{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #? visual sound nodes editor
    helvum
  ];
  #? rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.pipewire.extraConfig.pipewire = {
    "10-fix-popping" = {
      #? https://ventureo.codeberg.page/source/sound.html#choppy-audio
      "context.properties" = {
        #? multiply min-quantum while sound still popping (starting from 512)
        "default.clock.min-quantum" = 512;
        "default.clock.quantum" = 4096;
        "default.clock.max-quantum" = 8192;
      };
    };
  };

  #? more real times for realtime
  # boot.kernelParams = [ "preempt=full" ];
  #? cause user laucnhed pipewire isn't set any of this for rt
  # users.users.${username}.extraGroups = [ "audio" ];
  #? https://ventureo.codeberg.page/source/sound.html#pipewire-lowlatency-setup
  #? https://github.com/musnix/musnix/blob/d65f98e0b1f792365f1705653d7b2d266ceeff6e/modules/base.nix#L112
  # security.pam.loginLimits = [
  #   {
  #     domain = "@audio";
  #     item = "rtprio";
  #     type = "-";
  #     value = 95;
  #   }
  #   {
  #     domain = "@audio";
  #     item = "nice";
  #     type = "-";
  #     value = -19;
  #   }
  #   {
  #     domain = "@audio";
  #     item = "memlock";
  #     type = "-";
  #     value = "unlimited";
  #   }
  # ];
}
