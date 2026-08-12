{ lib, pkgs, ... }:
let
  inherit (import ../../../hosts/ROG14/ids.nix) mic;
in
{
  #? above 25% the hw capture gain clips at the ADC, and no downstream plugin can undo
  #? that - the wireplumber rule next to this only covers a fresh state file, so keep a
  #? ceiling for the case of raising it by hand (slider, wpctl) and forgetting
  systemd.user.services.mic-volume-clamp = {
    Unit = {
      Description = "Clamp ${mic.pipewireNode} volume to 25%";
      PartOf = [ "pipewire.service" ];
      After = [ "pipewire.service" ];
    };
    Service = {
      ExecStart =
        let
          jq = lib.getExe pkgs.jq;
        in
        lib.getExe (
          pkgs.writeShellScriptBin "mic-volume-clamp" /* shell */ ''
            #? channelVolumes is linear while wpctl/UIs show the cubic scale, so the
            #? 25% slider position is 0.25^3 here, plus slack for float round-trips
            max=0.0157
            #? pw-mon replays existing objects as "added" on connect and emits "changed"
            #? on every volume move, so this catches both a fresh node and a later raise
            ${pkgs.pipewire}/bin/pw-mon --no-colors \
              | grep --line-buffered --fixed-strings 'node.name = "${mic.pipewireNode}"' \
              | while read -r _; do
                  read -r id vol < <(${pkgs.pipewire}/bin/pw-dump \
                    | ${jq} --raw-output 'first(.[] | select(.info.props."node.name"=="${mic.pipewireNode}")
                        | "\(.id) \(.info.params.Props[0].channelVolumes[0])") // empty')
                  [ -z "$id" ] && continue
                  #? only ever pull down, never up - going quieter than 25% stays allowed
                  if [ "$(${lib.getExe pkgs.gawk} --assign v="$vol" --assign m="$max" 'BEGIN{print (v > m) ? 1 : 0}')" = 1 ]; then
                    ${pkgs.wireplumber}/bin/wpctl set-volume "$id" 0.25
                  fi
                done
          ''
        );
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "pipewire.service" ];
  };

  xdg.dataFile."easyeffects/autoload/input/${mic.pipewireNode}:${mic.deviceProfile}.json".text =
    builtins.toJSON
      {
        device = mic.pipewireNode;
        preset-name = "LaptopMic";
        device-profile = mic.deviceProfile;
        device-description = mic.deviceDescription;
      };

  services.easyeffects.extraPresets = {
    #? only defaults
    LaptopMic = {
      input = {
        blocklist = [ ];
        plugins_order = [
          "echo_canceller#0"
          "rnnoise#0"
          "speex#0"
          "compressor#0"
        ];
        "echo_canceller#0"."noise-suppression".enable = false;
        "rnnoise#0"."enable-vad" = true;
        "speex#0" = {
          "enable-agc" = true;
          "enable-dereverb" = true;
          "vad".enable = true;
        };
        "compressor#0".mode = "Boosting";
      };
    };
  };
}
