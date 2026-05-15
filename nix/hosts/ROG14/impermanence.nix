{ username, ... }:
let
  # TODO: config: persistentDir
  persistentDir = "/persistent";
in
{
  imports = [
    ../../modules/impermanence/on-zfs.nix
  ];

  # sudo mkdir -p /persistent/etc/NetworkManager /persistent/var/{db,log,lib}
  environment.persistence."${persistentDir}" = {
    # enable = false; # ? NB: Defaults to true, not needed

    # sudo cp -ax /var/lib{bluetooth,...,waydroid} /persistent/var/lib
    directories = [
      {
        directory = ".Trash-1000";
        user = username;
        group = "users";
      }
      "/etc/asusd" # ? current anime state
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/var/db" # ? ./sudo/lectured/$(id -u)
      "/var/log" # ? https://nixos.org/manual/nixos/unstable/#sec-var-journal
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/fprint" # ? enrolled fingerprints
      "/var/lib/libvirt"
      # "/var/lib/misc" # TODO: is this needed? dnsmasq waydroid
      # "/var/lib/NetworkManager" # TODO: is this needed?
      "/var/lib/power-profiles-daemon" # ? selected power-profile
      # "/var/lib/private" # TODO: is this needed? rustdesk
      # "/var/lib/sbctl" # TODO: is this needed? secure boot
      "/var/lib/upower" # ? history of power usage
      "/var/lib/waydroid"
    ];
    files = [
      # "/etc/adjtime" # TODO: is this needed? hwclock
      # "/etc/logrotate.status" # TODO: is this needed? /var/log/{b,w}tmp
    ];
    users.${username} = {
      # sudo mkdir -p /persistent/home/$USER && sudo chown $USER: /persistent/home/$USER
      # cp -ax /home/$USER/{...} /persistent/home/$USER/
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Games"
        "Music"
        "Pictures"
        "Videos"

        "config"
        "hax"
        "Sync"

        ".cache/cliphist"
        ".cache/cloud-code" # ? gemini auth
        ".cache/danksearch" # ? index
        ".cache/noctalia" # ? to disable prompt on startup
        ".cache/tlrc"

        ".config/bcompare5"
        ".config/chromium" # TODO: ??
        ".config/Code"
        ".config/copyq" # TODO: ??
        ".config/dconf" # TODO: ??
        ".config/discord"
        ".config/easyeffects" # TODO: config?
        ".config/Element"
        ".config/fsearch"
        ".config/GIMP" # TODO: config
        ".config/glib-2.0" # TODO: generate?
        ".config/hatch" # TODO: generate
        ".config/heroic" # TODO: more
        ".config/kdeconnect"
        ".config/kdedefaults" # TODO: unneded!!!!!?
        ".config/libreoffice"
        ".config/litecli"
        ".config/ludusavi"
        ".config/mozilla/firefox"
        ".config/noctalia/plugins"
        ".config/obs-studio"
        ".config/obsidian" # TODO: ??
        ".config/Podman Desktop" # TODO: ??
        ".config/qBittorrent" # TODO: ??
        ".config/r2modman" # TODO: ??
        ".config/r2modmanPlus-local"
        ".config/rog" # TODO: asus
        ".config/rustdesk"
        ".config/session" # ? KDE persist (dolphin and windows)
        ".config/sops/age"
        ".config/sourcery" # ? auth
        ".config/sunshine" # ? auth
        ".config/systemd/user/waydroid-monitor.service.d" # ? links to storage
        ".config/Throne"
        ".config/unity3d" # TODO: game saves
        ".config/VESC"
        ".config/vesktop" # TODO: ??
        ".config/waydroid-helper" # TODO: ??
        ".config/xsettingsd" # TODO: ????????????

        ".local/share" # TODO: more
        # ".local/share/Trash"
        # ".local/share/baloo"
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

        # ".local/share/direnv"
        ".local/state" # TODO: more
        # ".local/state/mpv/watch_later/"

        #? apps
        ".android"
        ".gemini"
        ".claude"
        ".thunderbird"
        ".vscode"

        #? dev
        # "go"
        # ".cargo"
        # ".docker"
        # ".dotnet"
        # ".java" # TODO: font cache
        # ".npm"
        # ".pki" # TODO: is this needed? certs

        #? games
        # ".parsec" # TODO: is this needed?
        # ".parsec-persistent" # TODO: is this needed?
        ".steam"
        ".wine"
      ];

      files = [
        ".claude.json"

        ".config/kwin_dialogsrc"
        ".config/kwinoutputconfig.json" # ? monitors
        ".config/syncthingtray.ini" # TODO: config?
        ".config/xclicker.conf"

        # ".local/share/krunnerstaterc"
        # ".local/share/user-places.xbel"
        # ".local/share/user-places.xbel.bak"
        # ".local/share/user-places.xbel.tbcache"
      ];
    };
  };
  systemd.tmpfiles.rules = [
    #? Syntax: Type Path Mode User Group Age Argument
    #? man tmpfiles.d
    #? L+ = Create symlink, remove existing file if necessary
    "L+ /home/${username}/.ssh 0700 ${username} users - /home/${username}/Sync/home/.ssh/"
    "L+ /home/${username}/projects 0700 ${username} users - /run/media/${username}/Data/projects/"

    "L+ /home/${username}/awg0.conf 0600 ${username} users - ${persistentDir}/home/${username}/awg0.conf"
    "L+ /home/${username}/wg0local.conf 0600 ${username} users - ${persistentDir}/home/${username}/wg0local.conf"

    # "L+ /home/${username}/.config/plasmashellrc 0600 ${username} users - ${persistentDir}/home/${username}/.config/plasmashellrc" # ??????? desktop
    # "L+ /home/${username}/.config/plasma-org.kde.plasma.desktop-appletsrc 0600 ${username} users - ${persistentDir}/home/${username}/.config/plasma-org.kde.plasma.desktop-appletsrc" # ??????? desktop
    # "L+ /home/${username}/.config/syncthingtray.ini 0600 ${username} users - ${persistentDir}/home/${username}/.config/syncthingtray.ini" # TODO: config?
  ];
}
