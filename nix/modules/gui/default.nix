{ pkgs, username, ... }:
{
  environment.defaultPackages = with pkgs; [
    # wayland stuff
    wl-clipboard
    libnotify

    # spell check
    hunspell
    hunspellDicts.en_US-large
    hunspellDicts.ru_RU
  ];

  # wayland stuff
  programs.ydotool.enable = true;
  users.users.${username}.extraGroups = [ "ydotool" ];

  fonts = {
    # fix furryfox fonts
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;
    # office fonts
    packages = [ pkgs.corefonts ];
  };
}
