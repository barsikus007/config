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
    packages = with pkgs; [
    # fix furryfox JAP pixelated fonts
      noto-fonts-cjk-sans

      # office fonts
      corefonts

      # minecraft-like fonts
      monocraft
      miracode
      (minecraftia.overrideAttrs (_: {
        version = "2.0";

        src = fetchzip {
          url = "https://dl.dafont.com/dl/?f=minecraftia";
          hash = "sha256-Nr/ujZsM4iG9DdKyY03d9aR0A+ND5H/cbUDBRnCDrMs=";
          extension = "zip";
          stripRoot = false;
        };

        installPhase = ''
          runHook preInstall

          install -D -m444 -t $out/share/fonts/truetype $src/Minecraftia-Regular.ttf

          runHook postInstall
        '';
      }))
    ];
  };

  #? https://wiki.archlinux.org/title/Java#Java_applications_cannot_open_external_links
  # TODO allow minecraft to open file links
  services.gvfs.enable = true;
}
