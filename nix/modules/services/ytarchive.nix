{
  lib,
  pkgs,
  username,
  ...
}@args:
let
  channels = if args ? channels then args.channels else [ ];
  streamsDir = if args ? streamsDir then args.streamsDir else "/home/${username}/streams";
  quality = if args ? quality then args.quality else "best";

  mkService = channel: {
    name = "ytarchive-${channel}";
    value = {
      description = "YouTube stream auto recorder for @${channel}";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = username;
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe pkgs.ytarchive)
          "--thumbnail"
          "--output='${streamsDir}/${channel}/%(start_date)s-%(title)s [%(id)s]'"
          "--retry-stream=900"
          "--add-metadata"
          "--monitor-channel"
          "https://www.youtube.com/@${channel}/live"
          quality
        ];
      };
    };
  };
in
{
  systemd.services = lib.listToAttrs (map mkService channels);
}
