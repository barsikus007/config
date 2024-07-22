source "$XDG_CONFIG_HOME/shell/aliases.sh"
source "$XDG_CONFIG_HOME/shell/functions.sh"

HISTSIZE=100000
HISTFILESIZE=100000
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# default settings
HISTCONTROL=ignoreboth
shopt -s histappend

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if hash nvim &> /dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
  export MANPAGER='nvim +Man!'
fi
export SYSTEMD_EDITOR=$EDITOR

export PATH=~/.local/bin:$PATH

# https://starship.rs/guide/#🚀-installation
if hash starship &> /dev/null; then
  eval "$(starship init bash)"
fi

if hash batcat &> /dev/null; then
  alias bat=batcat
  alias cat=batcat
  export PAGER=batcat
fi
if hash bat &> /dev/null; then
  unalias bat &> /dev/null
  alias cat=bat
  export PAGER=bat
fi
export BAT_THEME="Coldark-Dark"
export LESS="--mouse"

# https://www.shellcheck.net/wiki/SC2155
# proto
export PROTO_HOME=$XDG_CONFIG_HOME/proto
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
# go
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"

# ubuntu 2204 moment
# eval "$(fzf --bash)"
source /usr/share/doc/fzf/examples/key-bindings.bash
# source /usr/share/doc/fzf/examples/completion.bash
source /usr/share/bash-completion/completions/fzf

if hash zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi


# pipx, pdm, hatch autocomplete
# TODO autocompletions resolver
# if hash register-python-argcomplete &> /dev/null; then
#   eval "$(register-python-argcomplete pipx)"
# fi
# if hash hatch &> /dev/null; then
#   eval "$(_HATCH_COMPLETE=bash_source hatch)"
# fi
# or
# {
#   register-python-argcomplete pipx;
#   pmd completion bash;
#   _HATCH_COMPLETE=bash_source hatch;
# } >> ~/.bash_completion
