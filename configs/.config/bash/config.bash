source "$XDG_CONFIG_HOME/shell/aliases.sh"
source "$XDG_CONFIG_HOME/shell/functions.sh"

# If not running interactively, don't do anything after this line
case $- in
    *i*) ;;
      *) return;;
esac

export HISTSIZE=10000
export HISTFILESIZE=10000
if hash nvim &> /dev/null; then
  export EDITOR=nvim
fi
export SYSTEMD_EDITOR=$EDITOR

PATH=$PATH:~/.local/bin

# https://starship.rs/guide/#🚀-installation
if hash starship &> /dev/null; then
  eval "$(starship init bash)"
fi

if hash batcat &> /dev/null; then
  alias bat=batcat
  alias cat=bat
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export PAGER=bat
fi
if hash bat &> /dev/null; then
  alias cat=bat
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export PAGER=bat
fi
export LESS="--mouse"

# https://www.shellcheck.net/wiki/SC2155
# proto
export PROTO_HOME=$XDG_CONFIG_HOME/proto
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
# go
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"

# pipx, poetry, hatch autocomplete
# TODO autocompletions resolver
# if hash register-python-argcomplete &> /dev/null; then
#   eval "$(register-python-argcomplete pipx)"
# fi
# if hash poetry &> /dev/null; then
#   eval "$(poetry completions bash)"
# fi
# if hash hatch &> /dev/null; then
#   eval "$(_HATCH_COMPLETE=bash_source hatch)"
# fi
# or
# {
#   register-python-argcomplete pipx;
#   poetry completions bash;
#   _HATCH_COMPLETE=bash_source hatch;
# } >> ~/.bash_completion
