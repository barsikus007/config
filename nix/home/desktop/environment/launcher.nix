{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
{
  programs.fuzzel.enable = true;
  programs.anyrun = {
    enable = true;
    config = {
      closeOnClick = true;
      showResultsImmediately = true;

      plugins = with pkgs; [
        #? https://github.com/anyrun-org/anyrun#plugins
        "${anyrun}/lib/libapplications.so"
        "${anyrun}/lib/librink.so"
        "${anyrun}/lib/libniri_focus.so"
        "${anyrun}/lib/libkidex.so" # file

        "${anyrun}/lib/libwebsearch.so" # ?
        "${anyrun}/lib/libtranslate.so" # :<lang><word> <to_translate>
        "${anyrun}/lib/libdictionary.so" # :def<word>
        "${anyrun}/lib/libnix_run.so" # :nr
        # "${anyrun}/lib/libsymbols.so"

        # "${anyrun}/lib/librandr.so"
        # "${anyrun}/lib/libshell.so"

        "${anyrun}/lib/libstdin.so"
      ];
    };
  };
  #? https://github.com/anyrun-org/anyrun/blob/d72d303fbaa68752a8761d082ea133a95786e3b8/nix/modules/home-manager.nix#L400
  systemd.user.services.anyrun = {
    Unit = {
      Description = "Anyrun daemon";
      PartOf = "graphical-session.target";
      After = "graphical-session.target";
    };

    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe config.programs.anyrun.package} daemon";
      Restart = "on-failure";
      KillMode = "process";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    # extensions = [];
    settings = {
      close_on_focus_loss = true;
      #? controlled by niri
      launcher_window.client_side_decorations.enabled = true;

      launcher_window.layer_shell.layer = "overlay";
    };
  };
  xdg.configFile."vicinae/settings.json".target = "vicinae/settings-static.json";
  xdg.configFile."vicinae/settings.json-real" = {
    target = "vicinae/settings.json";
    source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/vicinae/settings.json";
  };
}
