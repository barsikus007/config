{ lib, pkgs, ... }:
let
  winePkg = with pkgs; wineWow64Packages.unstableFull;
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    package = pkgs.steam.override {
      extraPkgs = (
        pkgs: with pkgs; [
          gamemode
        ]
      );
    };
    protontricks.enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    protonup-qt

    #? overlay like msi afterburner
    mangohud

    r2modman

    (heroic.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
      ];
    })

    # native wayland support (unstable)
    winePkg
    winetricks
    bottles

    gpu-screen-recorder-gtk
  ];

  #? https://github.com/fufexan/nix-gaming/blob/9d30426090a8d274eb20dc36bd28c6e37dc3589c/modules/wine.nix#L21
  environment.sessionVariables.WINE_BIN = lib.getExe winePkg;

  # add binfmt registration
  boot.binfmt.registrations."DOSWin" = {
    interpreter = lib.getExe winePkg;
    wrapInterpreterInShell = false;
    recognitionType = "magic";
    offset = 0;
    magicOrExtension = "MZ";
  };

  # load ntsync
  boot.kernelModules = [ "ntsync" ];

  # make ntsync device accessible
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "ntsync-udev-rules";
      text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/70-ntsync.rules";
    })
  ];

  programs.gpu-screen-recorder.enable = true;
  programs.obs-studio = {
    #? https://wiki.nixos.org/wiki/OBS_Studio
    #? Missing hardware acceleration: Sometimes you need to set "Output Mode" to Advanced in settings Output tab to see the hardware accelerated Video Encoders options.
    enable = true;
    enableVirtualCamera = true;
    # optional Nvidia hardware acceleration
    package =
      with pkgs;
      (obs-studio.override {
        cudaSupport = true;
      });

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
