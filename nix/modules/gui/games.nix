{ pkgs, username, ... }:
{
  imports = [
    ./obs.nix
    ./wine.nix
  ];
  home-manager.users.${username}.imports = [
    ../../home/gui/games
  ];

  custom.persist.home.directories = [
    ".config/heroic"
    ".config/r2modman" # TODO: electron
    ".config/r2modmanPlus-local"
    ".config/unity3d" # ? game saves
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      (
        let
          gameDispatcher = /* python */ ''
            #!/usr/bin/env python3
            import configparser
            import os
            import shlex
            import sys

            DIR = os.path.dirname(os.path.abspath(__file__))
            REAL_PROTON = os.path.join(DIR, ".proton-real")
            APPID = os.environ.get("SteamAppId", "")
            exe_name = os.path.basename(sys.argv[2]) if len(sys.argv) > 2 else ""

            # read ~/.config/steam-games.ini
            config_path = os.path.expanduser("~/.config/steam-games.ini")
            config = configparser.ConfigParser()
            if os.path.exists(config_path):
                config.read(config_path)

            cfg = (
                config[APPID]
                if APPID in config
                else config[exe_name]
                if exe_name in config
                else config["DEFAULT"]
                if "DEFAULT" in config
                else {}
            )

            # 1. GPU offload configuration
            gpu_pref = cfg.get("gpu", "auto")
            nvidia_active = os.path.isdir("/proc/driver/nvidia/gpus")

            if gpu_pref == "nvidia" or (gpu_pref == "auto" and nvidia_active):
                os.environ["__NV_PRIME_RENDER_OFFLOAD"] = "1"
                os.environ["__NV_PRIME_RENDER_OFFLOAD_PROVIDER"] = "NVIDIA-G0"
                os.environ["__GLX_VENDOR_LIBRARY_NAME"] = "nvidia"
                os.environ["__VK_LAYER_NV_optimus"] = "NVIDIA_only"

            # 2. MangoHud
            if cfg.getboolean("mangohud", fallback=False):
                os.environ["MANGOHUD"] = "1"

            # 3. GameMode
            if cfg.getboolean("gamemode", fallback=False):
                preload = "libgamemodeauto.so.0"
                current_preload = os.environ.get("LD_PRELOAD", "")
                os.environ["LD_PRELOAD"] = (
                    f"{preload}:{current_preload}" if current_preload else preload
                )

            # 4. binary wrapper (e.g. gamescope) - only during actual game execution
            wrapper = cfg.get("wrapper", "").strip()
            is_game_run = len(sys.argv) > 1 and sys.argv[1] in ("run", "waitforexitandrun")

            if wrapper and is_game_run:
                cmd = shlex.split(wrapper) + [REAL_PROTON] + sys.argv[1:]
                os.execvp(cmd[0], cmd)
            else:
                os.execvp(REAL_PROTON, [REAL_PROTON] + sys.argv[1:])
          '';
        in
        proton-ge-bin.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            mv $steamcompattool/proton $steamcompattool/.proton-real
            cat << 'EOF' > $steamcompattool/proton
            ${gameDispatcher}
            EOF
            chmod +x $steamcompattool/proton
          '';
        })
      )
    ];
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          gamemode
          gamescope
        ];
    };
    protontricks.enable = true;
    # gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  environment.systemPackages = with pkgs; [
    protonup-qt

    #? overlay like msi afterburner
    mangohud

    r2modman

    (heroic.override {
      extraPkgs = _pkgs: [
        gamescope
        gamemode
      ];
    })
  ];

  #? clicker with position remember
  services.crossmacro = {
    enable = true;
    users = [ username ];
  };
}
