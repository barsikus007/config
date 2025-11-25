{ pkgs, username, ... }:
{
  programs.virt-manager.enable = true;

  environment.defaultPackages = with pkgs; [
    # looking-glass-client
    (looking-glass-client.overrideAttrs {
      version = "B7-g3efe47ffb2";

      src = fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = "3efe47ffb21ca96ed46b2a9342b3cee4df553987";
        hash = "sha256-kIS5JuEu2DnZdB+kRQ6jUR6pcR0hYiJLjZK3witvJcM=";
        fetchSubmodules = true;
      };
    })
  ];

  # TODO: is needed? with working kvmfr
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
  ];
}
