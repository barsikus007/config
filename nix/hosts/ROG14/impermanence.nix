{
  config,
  inputs,
  username,
  ...
}:
#? https://nix-community.github.io/preservation/impermanence-migration.html maybe
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  #? sudo btrfs subvolume create /@persistent
  fileSystems."/persistent" = {
    inherit (config.fileSystems."/nix") device;
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=@persistent"
      "noatime"
      "compress=zstd"
    ];
  };
  # sudo mkdir -p /persistent/etc/NetworkManager /persistent/var/{db,log,lib}
  # sudo cp -ax --reflink=always ...
  environment.persistence."/persistent" = {
    # enable = false; # ? NB: Defaults to true, not needed
    # hideMounts = true; # ? toogle it after test

    # sudo cp -ax --reflink=always /var/lib{bluetooth,btrfs,cups,fwupd,fprint,lastlog,misc,NetworkManager,nixos,power-profiles-daemon,private,sbctl,sddm,swtpm-localca,upower,waydroid} /persistent/var/lib
    # sudo mkdir /var/lib/{AccountsService,systemd}
    # sudo cp -ax --reflink=always /var/lib/AccountsService/users /persistent/var/lib/AccountsService
    # sudo cp -ax --reflink=always /var/lib/systemd/{backlight,catalog,coredump,pstore,rfkill,timers} /persistent/var/lib/systemd
    directories = [
      # "/etc/asusd" # TODO: asus
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
      # "/var/lib/sddm" # TODO: is this needed? sddn
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
      "/etc/machine-id"
      # "/etc/supergfxd.conf" # TODO: asus
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
        "projects" # ! symlink
        "Sync"

        # TODO: https://wiki.nixos.org/wiki/Impermanence#Example_3
        # ".cache"
        ".config" # TODO: more
        ".local" # TODO: more
        # ".local/share/direnv"
        ".var" # TODO: more

        #? apps
        ".android"
        # ".floorp"
        ".gemini"
        ".mozilla"
        ".ocat" # ? macos opencore
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

        {
          directory = ".ssh"; # ! symlink
          mode = "0700";
        }
      ];
      files = [
        # ".zcompdump" # TODO: is this needed?
        ".zsh_history"
        "awg0.conf" # ! symlink
      ];
    };
  };
  # systemd.tmpfiles.rules = [
  #   # Syntax: Type Path Mode User Group Age Argument
  #   # L+ = Create symlink, remove existing file if necessary

  #   "L+ /home/${username}/projects - - - - /run/media/${username}/Data/projects/"

  #   "L+ /home/${username}/.ssh - - - - /home/${username}/Sync/home/.ssh/"

  #   "L+ /home/${username}/awg0.conf - - - - /home/${username}/Sync/wg/donstux-linux-49.conf"
  # ];
}
