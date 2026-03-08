{
  _class,
  pkgs,
  config,
  ...
}:
(
  let
    packages = if (_class == "nixos") then config.environment.systemPackages else config.home.packages;
    zcompdump =
      pkgs.runCommand "zcompdump"
        {
          nativeBuildInputs = with pkgs; [ zsh ];
          env.PKG_PATHS = pkgs.lib.concatStringsSep " " packages;
        }
        ''
          export HOME=$TMPDIR
          zsh -c '
            for p in $=PKG_PATHS; do
              fpath=($p/share/zsh/site-functions(N/) $p/share/zsh/vendor-completions(N/) $fpath)
            done
            autoload -Uz compinit && compinit -d $out
          '
        '';
    #? https://ss64.com/mac/autoload-zsh.html
    #? https://github.com/zsh-users/zsh/blob/master/Completion/compinit
    #? https://medium.com/@ankitbabber/how-i-improved-my-shell-load-time-with-a-lazy-load-3acd89f8c4a3
    completionInit = ''
      autoload -U compinit && compinit -C -d ${zcompdump}
    '';
  in
  if (_class == "nixos") then
    {
      programs.zsh = {
        enableGlobalCompInit = false;
        interactiveShellInit = completionInit;
      };
    }
  else
    {
      programs.zsh = {
        inherit completionInit;
      };
    }
)
