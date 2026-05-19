{
  lib,
  pkgs,
  username,
  ...
}@args:
let
  channels = if args ? channels then args.channels else [ ];
  streamsDir = if args ? streamsDir then args.streamsDir else "/home/${username}/streams";
  quality = if args ? quality then args.quality else "720p60,720p,best";

  mkService = channel: {
    name = "streamlink-${channel}";
    value = {
      description = "Twitch stream auto recorder for @${channel}";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = username;
        Restart = "always";
        RestartSec = 3;
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe pkgs.streamlink)
          "--output='${streamsDir}/${channel}/{time}-{title} [v{id}].mp4'"
          "--retry-streams=60"
          "https://www.twitch.tv/${channel}"
          quality
        ];
      };
    };
  };
in
{
  systemd.services = lib.listToAttrs (map mkService channels);
}
