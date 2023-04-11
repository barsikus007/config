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

# https://starship.rs/guide/#🚀-installation
if hash starship &> /dev/null; then
  eval "$(starship init bash)"
fi

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
