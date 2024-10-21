#!/bin/sh

confirm() {
  printf "%s [Y/n] " "$1"
  read -r resp < /dev/tty
  if [ "$resp" = "" ] || [ "$resp" = "Y" ] || [ "$resp" = "y" ] || [ "$resp" = "yes" ]; then
    return 0
  fi
  if [ "$2" = "abort" ]; then
    echo "Abort."
    echo
    exit 0
  fi
  return 1
}

soft_envs() {
  soft_unix="git curl wget"
  soft_base="mc bat duf gdu fzf btop neovim zoxide ripgrep"
  # fd make bzip2
  soft_add="eza tmux tree neofetch"
  soft_add_ubuntu="nala build-essential software-properties-common"
  soft_to_purge="snapd"
}

setup_font() {
  (
    tmpfile=$(mktemp --suffix .zip)
    wget https://github.com/microsoft/cascadia-code/releases/latest/download/CascadiaCode-2404.23.zip -O "$tmpfile"
    # /usr/share/fonts/truetype/cascadia ?
    sudo unzip -j "$tmpfile" ttf/Cascadia*.ttf -d /usr/share/fonts/cascadia
    sudo fc-cache -v
    rm "$tmpfile"
  )
}

setup_docker() {
  (
    curl -sSL https://get.docker.com | sh
    # seems like it's not needed
    # sudo groupadd docker
    sudo usermod -aG docker "$USER"
    newgrp docker; exit
  )
}

setup_user() {
  (
    if ! hash bat; then
      if hash batcat; then
        echo "Linking bat..."
        mkdir -p ~/.local/bin
        ln -s "$(which batcat)" ~/.local/bin/bat
      else
        echo "batcat isn't installed to link"
      fi
    fi
  )
}

setup_linux() {
  (
    echo "Setting up neovim shims..."
    for role in editor vi vim; do
      sudo update-alternatives --set $role "$(which nvim)"
    done
    # /usr/libexec/neovim/ is unstable thing, could broke
    for role in ex rview rvim view vimdiff; do
      sudo update-alternatives --set $role /usr/libexec/neovim/$role
    done
    if ! hash starship; then
      echo "Setting up starship..."
      curl -sS https://starship.rs/install.sh | sh
    fi
    setup_user
  )
}

setup_ubuntu() {
  # shellcheck disable=SC2086
  (
    soft_envs
    echo "Installing nala and $soft_unix $soft_base $soft_add $soft_add_ubuntu..."
    sudo apt install nala && \
    sudo nala fetch --auto && \
    uuu && \
    sudo nala install $soft_unix $soft_base $soft_add $soft_add_ubuntu -y
    confirm "Do you want to remove $soft_to_purge?" && sudo nala purge $soft_to_purge -y
    setup_linux
  )
}

setup_arch() {
  # shellcheck disable=SC2086
  (
    soft_envs
    sudo pacman -S $soft_unix $soft_base $soft_add -y
    sudo pacman -Rsn $soft_to_purge -y
    setup_linux
  )
}

mkcd() { (mkdir -p "$@" && cd "$@" || exit;) }

llalias() {
  if hash eza &> /dev/null; then
    alias ll=ezall
    alias l=ezal
  elif hash exa &> /dev/null; then
    alias ll=exall
    alias l=exal
  else
    alias ll='ls -laFbgh'
    alias l='ls -CFbh'
  fi
}

lllazy() {
  llalias
  alias ll
  eval ll "$@"
}

llazy() {
  llalias
  alias l
  eval l "$@"
}

dcsh() { docker compose exec -it "$1" sh -c 'bash || sh'; }

# export-aliases() {
#   # export aliases
#   # alias | awk -F'[ =]' '{print "alias "$2"='\''"$3"'\''"}'
#   alias | sed -z 's/\n/\&\&/g' | sed -e 's/[^(alias)] /\\\\ /g'
# }

# ripgrep->fzf->vim [QUERY]
rfv() (
  # https://junegunn.github.io/fzf/tips/ripgrep-integration/
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  # shellcheck disable=SC2016
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            vim {1} +{2}     # No selection. Open the current line in Vim.
          else
            vim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)


desc() {  # TODO WIP
  # TODO warp all funcs with ()
  (
    sudo=false
    command=$1
    i=3
    if [ "$command" = "-" ]; then
      command=""
      for arg in "$@"; do
        [ "$arg" = "-" ] && [ "$command" != "" ] && break
        [ "$arg" = "-" ] && continue
        i=$((i + 1))
        command="$command $arg"
      done
    elif [ "$command" = "sudo" ]; then
      sudo=true
      command=$2
      echo 123
    fi
    echo "$command" "${@:$i}"
    echo "$command --help"
    help=$($command --help)
    for arg in "${@:$i}"; do
      if [[ "$arg" = -* ]]; then
        echo "$help" | grep --regexp=" $arg[, ]" -
      else
        echo "$arg"
      fi
    done
    # [[ "$URL" == "$PATTERN"* ]]
  )
}

restore_wifi() {
  (
    iface=wlp2s0
    old_region=RU
    sudo airmon-ng stop "$iface"mon
    sudo ip link set "$iface" down
    sudo iw reg set $old_region
    sudo iw dev $iface set power_save on
    sudo iw dev $iface set txpower auto
    sudo ip link set "$iface" up
    sudo service NetworkManager start
    sudo service wpa_supplicant start
  )
}

prepare_wifi() {  # TODO WIP
  (
    # TODO seconf iface iw dev
    # iface_iw=phy0
    iface=wlp2s0  # TODO WIP
    new_region=BZ
    # can be also AM, BZ, GR, GY, NZ, VE, CN, RU
    # codes were taken from https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt
    # clear  # TODO WIP
    sudo airmon-ng stop "$iface"mon
    sudo ip link set "$iface" down
    echo "Old region was $(iw reg get)"
    sudo iw reg set $new_region
    echo "New region is $(iw reg get)"  # TODO WIP
    # sudo iw phy $iface_iw reg set $new_region  # TODO https://hackware.ru/?p=4125
    iw dev $iface get power_save
    sudo iw dev $iface set power_save off
    iw dev $iface get power_save
    sudo iw dev $iface set txpower fixed 30mBm  # TODO WIP
    sudo ip link set "$iface" up
    iw dev
    sudo airmon-ng check kill
    sudo airmon-ng start $iface
    iw dev
  )
}

prepare_wifite() {
  (
    wifite_dir=~/Projects/wifite2
    prepare_wifi
    cd $wifite_dir || return 1  # TODO WIP
    return  # TODO WIP
  )
}

handshake_capture() {  # TODO WIP
  (
    iface=wlp2s0  # TODO WIP
    prepare_wifite || return 1  # TODO WIP
    sudo python3 wifite.py -ab -mac --skip-crack -ic --showb --showm -i "$iface"mon -inf -p 900 --clients-only --no-wps --wpadt 30 --wpat 1200 --no-pmkid --hs-dir ~/hs
    sudo chown -R "$USER:$USER" ~/hs
    restore_wifi
  )
}

# TODO WIP
alias crack_hs="cd ~/Projects/wifite2 && sudo python3 wifite.py --cracked --crack -ic --dict ./wordlist-probable.txt --hs-dir ~/hs"

wps_attack() {  # TODO WIP
  (
    iface=wlp2s0  # TODO WIP
    prepare_wifite || return 1  # TODO WIP
    sudo python3 wifite.py -ab -mac --skip-crack -ic --showb --showm -i "$iface"mon -inf -p 900 --wps-only --wps-timeouts 1000
    restore_wifi
  )
}

demotoggle() {
  # demo toggle function (for dedicated key)
  # sudo sed -i 's/StartLimitInterval=200/StartLimitInterval=2/' /usr/lib/systemd/user/asusd-user.service && systemctl --user daemon-reload
  (
    DEMO_FILE=~/.config/.is-demo-working
    if [ -f "$DEMO_FILE" ]; then
      nodemo && rm "$DEMO_FILE"
    else
      demo && touch "$DEMO_FILE"
    fi
  )
}

fan() {
  # fan switch function (for Fn+F5 key)
  (
    asusctl profile -n
    FAN_STATE=$(asusctl profile -p)
    FAN_STATE_LOWER=$(echo "$FAN_STATE" | awk '{print $4}' | tr '[:upper:]' '[:lower:]')
    [ "$FAN_STATE_LOWER" = quiet ] && FAN_STATE_LOWER=power-saver
    PREV_ID=$(cat ~/.config/.prev-fan-notification-id)
    [ -z "$PREV_ID" ] && PREV_ID=0
    notify-send --hint int:transient:1 "Power Profile" "$FAN_STATE" -t 1 -i power-profile-"$FAN_STATE_LOWER" -p -r "$PREV_ID" > ~/.config/.prev-fan-notification-id
  )
}
