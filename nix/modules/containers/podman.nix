{ pkgs, username, ... }:
{
  users.users.${username}.extraGroups = [ "podman" ];
  virtualisation = {
    containers = {
      enable = true;
      registries.search = [
        "docker.io"
        # "quay.io"
        # "ghcr.io"
        # "mcr.microsoft.com"
      ];
    };
    podman = {
      #? https://github.com/containers/podman/blob/main/rootless.md
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  environment.systemPackages = with pkgs; [
    podman-tui
    podman-compose
    podman-desktop
  ];
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };
}
