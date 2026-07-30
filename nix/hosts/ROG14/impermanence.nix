{ config, username, ... }:
{
  imports = [
    ../../modules/impermanence/on-zfs.nix
  ];

  environment.persistence.${config.custom.persist.dir} = {
    # enable = false;
    directories = [
      "/etc/asusd" # ? current anime state
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/var/db" # ? ./sudo/lectured/$(id -u)
      "/var/log" # ? https://nixos.org/manual/nixos/unstable/#sec-var-journal
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/libvirt"
      # "/var/lib/misc" # TODO: is this needed? dnsmasq waydroid
      # "/var/lib/NetworkManager" # TODO: is this needed?
      "/var/lib/power-profiles-daemon" # ? selected power-profile
      # "/var/lib/private" # TODO: is this needed? rustdesk
      # "/var/lib/sbctl" # TODO: is this needed? secure boot
      "/var/lib/upower" # ? history of power usage
    ];
    files = [
      # "/etc/adjtime" # TODO: is this needed? hwclock
      # "/etc/logrotate.status" # TODO: is this needed? /var/log/{b,w}tmp
    ];
    users.${username} = {
      directories = [
        # "Desktop"
        "Documents"
        "Downloads"
        "Games"
        "Music"
        "Pictures"
        "Videos"

        "config"
        "Share" # ? samba guest LAN share
        "Sync"

        #? apps
        ".android"
        ".gemini"
        # ".java" # TODO: font cache
        ".thunderbird"

        #? games
        ".parsec"
        ".parsec-persistent"
        ".steam"

        ".cache/.bun" # ? tools installed with bunx
        ".cache/cloud-code" # ? gemini auth
        ".cache/danksearch" # ? index
        ".cache/noctalia" # ? to disable prompt on startup
        ".cache/tlrc"
        #! vulkan shader caches: without them the first whisper run on the nvidia dGPU spends
        #! ~19s compiling pipelines (vs ~0.3s warm); mesa/radv recompile fast but still cost
        ".cache/nvidia" # ? proprietary driver GLCache
        ".cache/mesa_shader_cache"
        ".cache/radv_builtin_shaders"

        ".config/bcompare5"
        ".config/BraveSoftware"
        ".config/claude" # ? xdg-ninja
        ".config/copyq" # TODO: ??
        ".config/dconf" # TODO: ??
        ".config/discord"
        ".config/easyeffects" # TODO: config?
        ".config/Element"
        ".config/fsearch"
        ".config/GIMP" # TODO: config
        ".config/glib-2.0" # TODO: generate?
        ".config/hatch" # TODO: generate
        ".config/heroic"
        ".config/kdeconnect"
        ".config/kdedefaults" # TODO: unneded!!!!!?
        ".config/libreoffice"
        ".config/litecli"
        ".config/ludusavi"
        ".config/Moonlight Game Streaming Project"
        ".config/mozilla/firefox"
        ".config/obs-studio"
        ".config/obsidian"
        ".config/Podman Desktop" # TODO: electron
        ".config/qBittorrent"
        ".config/r2modman" # TODO: electron
        ".config/r2modmanPlus-local"
        ".config/rog" # ? asus anime
        ".config/rustdesk"
        ".config/session" # ? KDE persist (dolphin and windows)
        ".config/sops/age"
        ".config/sourcery" # ? auth
        ".config/sunshine" # ? auth
        ".config/Throne"
        ".config/unity3d" # ? game saves
        ".config/VESC"
        ".config/vesktop"

        ".local/share" # TODO: more
        # ".local/share/baloo"
        # ".local/share/direnv"
        # ".local/share/dolphin"
        # ".local/share/kactivitymanagerd"
        # ".local/share/kate"
        # ".local/share/klipper"
        # ".local/share/konsole"
        # ".local/share/kscreen"
        # ".local/share/kwalletd"
        # ".local/share/kxmlgui5" #? keymaps (and more ?) for some kde/qt apps
        # ".local/share/RecentDocuments"
        # ".local/share/nix/repl-history"
        # ".local/share/wine" # ? xdg-ninja

        ".local/state" # TODO: more
        # ".local/state/noctalia"
        # ".local/state/mpv/watch_later/"
      ];

      files = [
        ".config/gh/hosts.yml"
        ".config/kwin_dialogsrc"
        ".config/kwinoutputconfig.json" # ? monitors
        ".config/xclicker.conf"

        # ".local/share/krunnerstaterc"
        # ".local/share/user-places.xbel"
        # ".local/share/user-places.xbel.bak"
        # ".local/share/user-places.xbel.tbcache"
      ]
      ++
        # ? symlink needed files
        map
          (_: {
            file = _;
            method = "symlink";
          })
          [
            # ".config/plasma-org.kde.plasma.desktop-appletsrc"
            # ".config/plasmashellrc"
            ".config/syncthingtray.ini"
          ];
    };
  };
  systemd.tmpfiles.rules = [
    #? Syntax: Type Path Mode User Group Age Argument
    #? man tmpfiles.d
    #? L+ = Create symlink, remove existing file if necessary
    "L+ /home/${username}/.ssh 0700 ${username} users - /home/${username}/Sync/home/.ssh/"

    "L+ /home/${username}/.lmstudio 0755 ${username} users - /run/media/${username}/Data/downloads/.lmstudio"
    "L+ /home/${username}/.local/share/hyprwhspr-rs 0755 ${username} users - /run/media/${username}/Data/downloads/hyprwhspr-rs"
  ];
}
