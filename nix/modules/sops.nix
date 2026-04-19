{
  pkgs,
  config,
  inputs,
  username,
  ...
}:
{

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [ sops ];
  #? secrets speedrun
  # mkdir --parent ~/.config/sops/age && nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
  # nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
  # cd ~/config/nix && nix run nixpkgs#sops -- secrets/secrets.yaml
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/persistent/home/${username}/.config/sops/age/keys.txt";

  sops.secrets."hosts/${config.system.name}/users/${username}/password_hash".neededForUsers = true;
  users.users.${username}.hashedPasswordFile =
    config.sops.secrets."hosts/${config.system.name}/users/${username}/password_hash".path;

  sops.secrets."tokens/github_nix" = { };
  nix.extraOptions = "!include ${config.sops.secrets."tokens/github_nix".path}";
}
