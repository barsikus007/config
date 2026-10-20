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
}
