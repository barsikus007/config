{ lib, pkgs, ... }:
let
  telegramPriority = pkgs.writeShellApplication {
    name = "telegram-priority";
    runtimeInputs = with pkgs; [
      pipewire
      jq
      playerctl
    ];
    text = builtins.readFile ./telegram-priority.sh;
  };
in
{
  systemd.user.services.telegram-priority = {
    Unit = {
      Description = "Pause media players while Telegram plays or records audio";
      PartOf = [ "pipewire.service" ];
      After = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = lib.getExe telegramPriority;
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
