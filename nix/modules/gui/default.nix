{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
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
    packages = with pkgs; [
      # fix furryfox JAP pixelated fonts
      noto-fonts-cjk-sans

      # office fonts
      corefonts

      # minecraft-like fonts
      monocraft
      miracode
      (callPackage ../../packages/minecraftia.nix { })
    ];
  };

  #? https://wiki.archlinux.org/title/Java#Java_applications_cannot_open_external_links
  # also for gio mount
  services.gvfs.enable = true;
}
