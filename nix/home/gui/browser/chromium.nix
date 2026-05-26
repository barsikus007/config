{ pkgs, config, ... }:
let
  configDir = "${config.xdg.configHome}/BraveSoftware/Brave-Browser";

  extensionJson = ext: {
    name = "${configDir}/External Extensions/${ext}.json";
    value.text = builtins.toJSON {
      external_update_url = "https://clients2.google.com/service/update2/crx";
    };
  };

  extensions = [
    # https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
    "cjpalhdlnbpafiamejdnhcphjbkeiagm"
    # https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
    "jinjaccalgkegednnccohejagnlnfdag"
    # https://chromewebstore.google.com/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk
    "oboonakemofpalcgghocfoadofidjkkk"
  ];
in
{
  #? https://github.com/tuxdotrs/nix-config/blob/99863948b4d6d97f44ea8cba12a7e5a88369126e/modules/home/brave/default.nix#L26
  home.file = builtins.listToAttrs (map extensionJson extensions);
  programs.chromium = {
    inherit extensions;
    enable = true;
    package = (
      #? no thorium? https://github.com/NixOS/nixpkgs/pull/336138#issuecomment-2299603455
      # pkgs.microsoft-edge.override {
      #! vivaldi is unfree :(
      pkgs.brave.override {
        # https://wiki.nixos.org/wiki/Chromium#Accelerated_video_playback
        commandLineArgs = [
          "--enable-features=AcceleratedVideoEncoder"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
      }
    );
  };
}
