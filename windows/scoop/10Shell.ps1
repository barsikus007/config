#! scoop addons
scoop install scoop-search scoop-completion

#! essential
#? curl wget
#! base
scoop install jq fd bat duf gdu fzf btop neovim zoxide ripgrep
#? btop-lhm VERY SLOW
#! add
scoop install eza tlrc yazi starship fastfetch
#! pwsh/cmd specific
scoop install posh-git psfzf
scoop install clink clink-completions

scoop install lazydocker
#? psreadline
#! unix tools
#? cmake
scoop install busybox
#! shim overrides
# TODO is still needed
scoop install uutils-coreutils
# scoop install which
scoop install grep
# scoop install less
#TODO: clink inject; clink autorun install
