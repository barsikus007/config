{
  lib,
  pkgs,
  config,
  inputs,
  flakePath,
  ...
}:
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.niri.homeModules.stylix

    ./quickshell/noctalia.nix
  ];
  home.packages = with pkgs; [
    grim
    slurp
    playerctl
    brightnessctl
  ];

  #! https://github.com/sodiboo/niri-flake/issues/1393
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/niri/config.kdl";
  xdg.configFile.niri-config.target = lib.mkForce "niri/nix-generated-config.kdl";
  programs.niri = {
    enable = true;
    package = with pkgs; niri;

    #? https://github.com/sodiboo/niri-flake/blob/main/docs.md
    #? https://niri-wm.github.io/niri/Configuration:-Introduction
    settings = {
      #! https://github.com/YaLTeR/niri/issues/1818: snip to edge
      #? win95 background
      overview.backdrop-color = "#018281";

      #? https://niri-wm.github.io/niri/Configuration:-Input
      input = {
        keyboard.numlock = true;
        touchpad = {
          # tap = true;
          # natural-scroll = true;
          accel-speed = -0.1;
          scroll-factor = 0.3;
        };
      };
      # TODO: asus
      outputs."eDP-1" = {
        mode.width = 1920;
        mode.height = 1080;
        mode.refresh = 120.003;

        scale = 1;
        position.x = 0;
        position.y = 360;
        # scale = 1.2;
        # position.x = 0;
        # position.y = 540;
        # scale = 1.5;
        # position.x = 0;
        # position.y = 720;
      };

      #? https://niri-wm.github.io/niri/Configuration:-Layout
      layout = {
        background-color = "transparent";
        preset-column-widths = [
          { proportion = 0.25; }
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 0.75; }
          { fixed = 1920; }
          { fixed = 2560; }
        ];
        preset-window-heights = [
          { proportion = 0.25; }
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 0.75; }
          { proportion = 1.0; }
        ];
        # default-column-width = {
        #   proportion = 0.5;
        # };
        focus-ring = {
          enable = true;
          #? https://brand.nixos.org/documents/nixos-branding-guide.pdf
          active.color = "#5fb8f2";
          inactive.color = "#4d6fb7";
        };
        shadow = {
          enable = true;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };
      };

      spawn-at-startup = [
        { argv = [ "kwalletd6" ]; }
      ];

      # hotkey-overlay.skip-at-startup = true;

      prefer-no-csd = true;

      binds = {
        # TODO: specific quickshell depent hotkeys; maybe make cli for unification?
        # TODO: asus
        "XF86Launch1" = {
          hotkey-overlay.title = "Asus: Toggle Bad Apple";
          action.spawn-sh = "zsh -c asus_demotoggle";
        };
        "XF86Launch4" = {
          hotkey-overlay.title = "Asus: Cycle Power Profiles";
          action.spawn-sh = "noctalia-shell ipc call powerProfile cycle";
        };
        "Mod+Shift+S" = {
          hotkey-overlay.title = "Quick ScreenCapture";
          action.spawn-sh = "noctalia-shell ipc call plugin:screen-recorder toggle";
        };
        "XF86KbdBrightnessUp".action.spawn-sh = "ydotool key 104:1 104:0";
        "XF86KbdBrightnessDown".action.spawn-sh = "ydotool key 109:1 109:0";
      };

      clipboard.disable-primary = true;

      debug = {
        #? https://github.com/niri-wm/niri/issues/3265
        # hardware.nvidia.prime.amdgpuBusId
        # render-drm-device "/dev/dri/renderD128"
        render-drm-device = "/dev/dri/by-path/pci-0000:04:00.0-render";
        # hardware.nvidia.prime.nvidiaBusId
        # ignore-drm-device "/dev/dri/renderD129"
        ignore-drm-device = [ "/dev/dri/by-path/pci-0000:01:00.0-render" ];
        #? https://github.com/niri-wm/niri/issues/2955
        honor-xdg-activation-with-invalid-serial = true;
      };
    };
  };

  services.polkit-gnome.enable = true; # ? polkit from wiki
}
