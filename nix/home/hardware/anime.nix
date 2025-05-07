{ config, ... }:
{
  #! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
  xdg.configFile."rog/rog-user.cfg".text = builtins.toJSON {
    name = "anime-bad-apple";
    anime = [
      {
        ImageAnimation = {
          file = "${config.xdg.configHome}/rog/bad-apple.gif";
          scale = 1;
          angle = 0;
          translation = [
            0.0
            0.0
          ];
          time = "Infinite";
          brightness = 1;
        };
      }
    ];
  };
}
