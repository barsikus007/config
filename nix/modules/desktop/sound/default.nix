{ pkgs, username, ... }:
{
  home-manager.users.${username}.imports = [ ../../../home/desktop/sound ];

  environment.systemPackages = with pkgs; [
    #? visual sound nodes editor
    qpwgraph
  ];
  #? rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire.enable = true;
}
