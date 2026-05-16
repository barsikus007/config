{
  pkgs,
  config,
  inputs,
  username,
  ...
}:
#? secrets speedrun
# mkdir --parent ~/.config/sops/age && nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
# nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
# cd ~/config/nix && nix run nixpkgs#sops -- secrets/secrets.yaml
#? other host age key
# ssh HOST "cat /etc/ssh/ssh_host_ed25519_key.pub" | nix run nixpkgs#ssh-to-age
# cd ~/config/nix && nix run nixpkgs#sops -- secrets/hosts/HOST.yaml
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  sops.secrets."hosts/${config.system.name}/users/${username}/password_hash".neededForUsers = true;
  users.users.${username}.hashedPasswordFile =
    config.sops.secrets."hosts/${config.system.name}/users/${username}/password_hash".path;
}
