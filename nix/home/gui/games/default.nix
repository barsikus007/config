{ config, flakePath, ... }:
{
  xdg.configFile."steam-games.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/steam-games.ini";

  xdg.configFile."handlr/handlr.toml".text = /* toml */ ''
    [[handlers]]
    exec = "steam steam://openurl/%u"
    regexes = ['^https://(www\.)?(store\.steampowered\.com|steamcommunity\.com)/.*']
  '';

  services.ludusavi.enable = true;
  xdg.configFile."ludusavi/config.yaml".enable = false;

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      #? 0=hidden, 1=fps, 2=horizontal, 3=standard, 4=full; by default it starts from 1
      preset = [
        0
        1
        2
        3
        4
      ];
    };
  };
}
