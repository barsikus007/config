#? https://github.com/ohmyzsh/ohmyzsh/issues/31#issuecomment-359728582
unsetopt nomatch

#? type aliases breaks shebang
# alias -s ts="bun"
# alias -s py="python"

autoload -Uz select-word-style
select-word-style bash

# home
bindkey "^[[H"    beginning-of-line
#? probably, for WSL (or wt.exe), but works on wezterm too
bindkey "^[OH"    beginning-of-line
# end
bindkey "^[[F"    end-of-line
#? probably, for WSL (or wt.exe), but works on wezterm too
bindkey "^[OF"    end-of-line

# page up/down
bindkey "^[[5~"   beginning-of-history
bindkey "^[[6~"   end-of-history

# alt + left/right
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
# ctrl + left/right
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# delete
bindkey "^[[3~"   delete-char
# alt + backspace
bindkey "^[^H"    backward-kill-word
# alt + delete
bindkey "^[[3;3~" delete-word
# ctrl + backspace
bindkey "^H"      backward-kill-word
# ctrl + delete
bindkey "^[[3;5~" delete-word

#? https://wiki.archlinux.org/title/Zsh#Shortcut_to_exit_shell_on_partial_command_line
exit_zsh() { exit; }
zle -N exit_zsh
bindkey '^D' exit_zsh

#? ssh completion: only Host aliases from ~/.ssh/config
#? native _ssh_hosts also pulls known_hosts, /etc/hosts and HostName values (85 entries),
#? and _ssh_users adds every system user; setting the style short-circuits both
_ssh_config_hosts() {
    rg -iN --no-heading '^\s*Host\s+' ~/.ssh/config \
        | sed 's/^[[:space:]]*[Hh]ost[[:space:]]*//' \
        | tr -s ' ' '\n' \
        | rg -v '[*?%]|^$' \
        | sort -u
}
#? -e re-evaluates on every completion, so config edits need no reload
zstyle -e ':completion:*:ssh:*' hosts 'reply=(${(f)"$(_ssh_config_hosts)"})'
zstyle ':completion:*:ssh:*' tag-order hosts

#? https://www.reddit.com/r/zsh/comments/eo80b6/comment/feaaib8/
function set-term-title-precmd() {
    emulate -L zsh
    print -rn -- $'\e]0;'${(V%):-'%~'}$'\a' >$TTY
}
function set-term-title-preexec() {
    emulate -L zsh
    print -rn -- $'\e]0;'${(V)1}$'\a' >$TTY
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec set-term-title-preexec
add-zsh-hook precmd set-term-title-precmd
set-term-title-precmd
