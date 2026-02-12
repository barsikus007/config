{
  lib,
  config,
  inputs,
  username,
  ...
}:
#? https://nix-community.github.io/preservation/impermanence-migration.html maybe
let
  inherit (config.fileSystems."/nix") device;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  #? sudo btrfs subvolume create /@persistent
  fileSystems."/persistent" = {
    inherit device;
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=@persistent"
      "noatime"
      "compress=zstd"
    ];
  };
  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount ${device} /btrfs_tmp
    if [[ -e /btrfs_tmp/@ ]]; then
      mkdir -p /btrfs_tmp/@-old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
      mv /btrfs_tmp/@ "/btrfs_tmp/@-old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    #? delete old roots older than 30 days
    for i in $(find /btrfs_tmp/@-old_roots/ -maxdepth 1 -mtime +30); do
      delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/@
    umount /btrfs_tmp
  '';

  # sudo mkdir -p /persistent/etc/NetworkManager /persistent/var/{db,log,lib}
  # sudo cp -ax --reflink=always ...
  environment.persistence."/persistent" = {
    # enable = false; # ? NB: Defaults to true, not needed
    hideMounts = true;

    # sudo cp -ax --reflink=always /var/lib{bluetooth,btrfs,cups,fwupd,fprint,lastlog,misc,NetworkManager,nixos,power-profiles-daemon,private,sbctl,sddm,swtpm-localca,upower,waydroid} /persistent/var/lib
    # sudo mkdir /var/lib/{AccountsService,systemd}
    # sudo cp -ax --reflink=always /var/lib/AccountsService/users /persistent/var/lib/AccountsService
    # sudo cp -ax --reflink=always /var/lib/systemd/{backlight,catalog,coredump,pstore,rfkill,timers} /persistent/var/lib/systemd
    directories = [
      {
        directory = ".Trash-1000";
        user = username;
        group = "users";
      }
      "/etc/asusd"
      "/etc/NetworkManager/system-connections"
      "/etc/nixos" # TODO: secrets
      "/var/db" # ? ./sudo/lectured/$(id -u)
      "/var/log"
      # "/var/lib/AccountsService/users" # TODO: is this needed? plasma
      "/var/lib/bluetooth"
      "/var/lib/btrfs"
      "/var/lib/cups"
      # "/var/lib/fwupd" # TODO: is this needed? firewall; fwupd-refresh:fwupd-refresh
      "/var/lib/fprint" # ? enrolled fingers
      # "/var/lib/lastlog" # TODO: is this needed? sddm
      "/var/lib/libvirt"
      # "/var/lib/misc" # TODO: is this needed? dnsmasq waydroid
      # "/var/lib/NetworkManager" # TODO: is this needed?
      "/var/lib/nixos"
      # "/var/lib/power-profiles-daemon" # TODO: is this needed? my experiments with power toggling
      # "/var/lib/private" # TODO: is this needed? rustdesk
      # "/var/lib/sbctl" # TODO: is this needed? secure boot
      # "/var/lib/sddm" # TODO: is this needed?
      # "/var/lib/swtpm-localca" # TODO: is this needed? tpm for libvirtd
      # "/var/lib/systemd/backlight" # TODO: is this needed? keyboard backlight
      # "/var/lib/systemd/catalog" # TODO: is this needed? creates auto, binary database for the Journal Message Catalog (extended log descriptions)
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/pstore"
      # "/var/lib/systemd/rfkill" # TODO: is this needed? state (enabled/disabled) of radio devices (Wi-Fi, Bluetooth)
      "/var/lib/systemd/timers"
      "/var/lib/upower" # ? history of power usage
      "/var/lib/waydroid"
    ];
    files = [
      # "/etc/adjtime" # TODO: is this needed? hwclock
      # "/etc/logrotate.status" # TODO: is this needed? /var/log/{b,w}tmp
      "/etc/machine-id" # TODO: secrets
    ];
    users.${username} = {
      # sudo mkdir -p /persistent/home/ogurez && sudo chown ogurez: /persistent/home/ogurez
      # cp -ax --reflink=always /home/ogurez/{Desktop,Documents,Downloads,Games,Music,Pictures,Videos,config,hax,projects,Sync,.cache,.config,.local,.var,.android,.floorp,.gemini,.mozilla,.ocat,.thunderbird,.vscode,go,.cargo,.docker,.dotnet,.java,.npm,.pki,.parsec,.parsec-persistent,.steam,.wine,.ssh} /persistent/home/ogurez/
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

        ".cache/cloud-code" # ? gemini auth
        ".cache/nix-index"
        ".cache/tlrc"

        ".config/autostart" # TODO: generate
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
        ".config/google-chrome" # TODO: ??
        ".config/hatch" # TODO: generate
        ".config/heroic" # TODO: more
        ".config/kdeconnect"
        ".config/kdedefaults" # TODO: unneded!!!!!?
        ".config/libreoffice"
        ".config/litecli"
        ".config/ludusavi"
        ".config/microsoft-edge" # TODO: ??
        ".config/nix" # ? gh token
        ".config/noctalia/plugins"
        ".config/obs-studio"
        ".config/obsidian" # TODO: ??
        ".config/Podman Desktop" # TODO: ??
        ".config/qBittorrent" # TODO: ??
        ".config/r2modman" # TODO: ??
        ".config/r2modmanPlus-local"
        ".config/rog" # TODO: asus
        ".config/rustdesk" # TODO: secrets
        ".config/session" # ? KDE persist (dolphin and windows)
        ".config/sourcery" # ? auth
        ".config/sunshine" # ? auth
        ".config/systemd/user/waydroid-monitor.service.d" # ? links to storage
        ".config/Throne"
        ".config/unity3d" # TODO: game saves
        ".config/VESC"
        ".config/vesktop" # TODO: ??
        ".config/waydroid-helper" # TODO: ??
        ".config/xsettingsd" # TODO: ????????????
        ".config/zsh"

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
        # ".local/share/kxmlgui5"
        # ".local/share/RecentDocuments"
        # ".local/share/sddm"

        # ".local/share/direnv"
        ".local/state" # TODO: more
        # ".local/state/mpv/watch_later/"

        #? apps
        ".android"
        ".gemini"
        ".mozilla"
        ".ocat" # TODO: macos opencore
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
    # Syntax: Type Path Mode User Group Age Argument
    # L+ = Create symlink, remove existing file if necessary
    "L+ /home/${username}/.ssh 0700 ${username} users - /home/${username}/Sync/home/.ssh/"
    "L+ /home/${username}/projects 0700 ${username} users - /run/media/${username}/Data/projects/"

    "L+ /home/${username}/awg0.conf 0600 ${username} users - /home/${username}/Sync/wg/donstux-linux-49.conf"

    # "L+ /home/${username}/.config/plasmashellrc 0600 ${username} users - /persistent/home/${username}/.config/plasmashellrc" # ??????? desktop
    # "L+ /home/${username}/.config/plasma-org.kde.plasma.desktop-appletsrc 0600 ${username} users - /persistent/home/${username}/.config/plasma-org.kde.plasma.desktop-appletsrc" # ??????? desktop
    # "L+ /home/${username}/.config/syncthingtray.ini 0600 ${username} users - /persistent/home/${username}/.config/syncthingtray.ini" # TODO: config?
  ];
}
