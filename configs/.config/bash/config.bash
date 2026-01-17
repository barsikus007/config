# shellcheck disable=SC1091
for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
  # shellcheck source=/dev/null
  source "$file"
done

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

# https://yazi-rs.github.io/docs/quick-start/
if hash yazi &> /dev/null; then
  function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
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
# rust
source "$HOME/.cargo/env" &> /dev/null

if hash fzf &> /dev/null; then
  FZF_VERSION=$(fzf --version | awk '{print $1}')
  FZF_VERSION_MAJOR=$(echo "$FZF_VERSION" | cut -d. -f1)
  FZF_VERSION_MINOR=$(echo "$FZF_VERSION" | cut -d. -f2)
  # ubuntu 2204 and lower moment
  if [ "$FZF_VERSION_MAJOR" == 0 ] && [ "$FZF_VERSION_MINOR" -le 47 ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
    if [ "$FZF_VERSION_MINOR" -ge 21 ]; then
      source /usr/share/bash-completion/completions/fzf
    else
      source /usr/share/doc/fzf/examples/completion.bash
    fi
  else
    eval "$(fzf --bash)"
  fi
fi

if hash zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi


# uv, hatch autocomplete
# TODO autocompletions resolver
# TODO move to setup_completions
# TODO file or folder?
# uv generate-shell-completion bash > /etc/bash_completion.d/uv.bash-completion
# https://python-poetry.org/docs/#bash
# https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#complete
# if hash uv &> /dev/null; then
#   eval "$(uv generate-shell-completion bash)"
# fi
# if hash hatch &> /dev/null; then
#   eval "$(_HATCH_COMPLETE=bash_source hatch)"
# fi
# or
# {
#   uv generate-shell-completion bash;
#   _HATCH_COMPLETE=bash_source hatch;
#   starship completions bash;
# } >> ~/.bash_completion
