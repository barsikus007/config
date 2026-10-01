#! scoop addons
scoop install scoop-search scoop-completion

# TODO: sync with nix packages like ubuntu
#* base
scoop install jq fd bat duf gdu fzf btop neovim zoxide ripgrep
#? btop-lhm is VERY SLOW, needs ADMIN RIGHTS, but shows accurate temp
#* add
scoop install eza tlrc yazi starship fastfetch
#* pwsh/cmd specific
scoop install posh-git psfzf
scoop install clink clink-completions

scoop install lazydocker
#* unix tools
#! shim priority, weakest first
scoop install busybox microsoft-coreutils grep less wget
# TODO: clink inject; clink autorun install
