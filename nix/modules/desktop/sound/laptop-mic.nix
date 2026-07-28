{ username, ... }:
let
  inherit (import ../../../hosts/ROG14/ids.nix) mic;
in
{
  home-manager.users.${username}.imports = [ ../../../home/desktop/sound/laptop-mic.nix ];

  #? hw capture gain saturates well before 100%, so anything above 25% clips at the ADC
  #? and no downstream plugin can undo it - the value is linear while wpctl/UIs show the
  #? cubic scale, so 0.25 on the slider is 0.25^3 here
  services.pipewire.wireplumber.extraConfig."51-mic-default-volume"."monitor.alsa.rules" = [
    {
      matches = [ { "device.name" = mic.pipewireDevice; } ];
      actions.update-props."device.routes.default-source-volume" = 0.015625;
    }
  ];
}
