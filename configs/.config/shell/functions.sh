#!/bin/sh

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
