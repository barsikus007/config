export XDG_BIN_HOME=$HOME/.local/bin
export PATH=$XDG_BIN_HOME:$PATH

for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
  # shellcheck source=/dev/null
  source "$file"
done

HISTSIZE=100000
HISTFILESIZE=100000
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
#? default settings
HISTCONTROL=ignoreboth
shopt -s histappend

#? If not running interactively, don't do anything
case $- in
  (*i*) ;;
  (*) return;;
esac


alias ip='ip -color=auto'

#? eza/exa/ls lazy usage
alias ll=lllazy
alias l=llazy

#? editor
if hash nvim &> /dev/null; then
  alias editor=nvim
  export EDITOR=nvim
  export VISUAL=nvim
  export MANPAGER='nvim +Man!'
fi

#? https://starship.rs/guide/#🚀-installation
if hash starship &> /dev/null; then
  eval "$(starship init bash)"
fi

#? https://yazi-rs.github.io/docs/quick-start/
if hash yazi &> /dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

#? pager
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

#? proto and tools
export PROTO_HOME=$XDG_CONFIG_HOME/proto
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
#? go
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"
#? rust
# shellcheck source=/dev/null
source "$HOME/.cargo/env" &> /dev/null

#? https://junegunn.github.io/fzf/shell-integration/
if hash fzf &> /dev/null; then
  _FZF_VERSION=$(fzf --version | awk '{print $1}')
  _FZF_VERSION_MAJOR=$(echo "$_FZF_VERSION" | cut -d. -f1)
  _FZF_VERSION_MINOR=$(echo "$_FZF_VERSION" | cut -d. -f2)
  #? ubuntu 2204 and lower moment
  # shellcheck source=/dev/null
  if [ "$_FZF_VERSION_MAJOR" == 0 ] && [ "$_FZF_VERSION_MINOR" -le 47 ]; then
    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
      source /usr/share/doc/fzf/examples/key-bindings.bash
    else
      echo 'sudo curl https://raw.githubusercontent.com/junegunn/fzf/refs/tags/0.44.1/shell/key-bindings.bash --output /usr/share/doc/fzf/examples/key-bindings.bash'
    fi
    if [ "$_FZF_VERSION_MINOR" -ge 21 ]; then
      source /usr/share/bash-completion/completions/fzf
    else
      source /usr/share/doc/fzf/examples/completion.bash
    fi
  else
    eval "$(fzf --bash)"
  fi
fi

#? https://github.com/ajeetdsouza/zoxide#installation
if hash zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi
