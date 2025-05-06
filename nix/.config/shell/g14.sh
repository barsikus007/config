#!/bin/sh

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
    FAN_STATE=$(asusctl profile -p | tail -n +2)
    FAN_STATE_LOWER=$(echo "$FAN_STATE" | awk '{print $4}' | tr '[:upper:]' '[:lower:]')
    [ "$FAN_STATE_LOWER" = quiet ] && FAN_STATE_LOWER=power-saver
    PREV_ID=$(cat ~/.config/.prev-fan-notification-id)
    [ -z "$PREV_ID" ] && PREV_ID=0
    notify-send --hint int:transient:1 "Power Profile" "$FAN_STATE" -t 1 -i power-profile-"$FAN_STATE_LOWER" -p -r "$PREV_ID" > ~/.config/.prev-fan-notification-id
  )
}

# TODO this is laptop specific, not G14
boost() {
  # https://www.reddit.com/r/linuxmint/comments/12n8qfe/comment/jge3kys/
  if grep -q 0 /sys/devices/system/cpu/cpufreq/boost; then
    echo "1" | sudo tee /sys/devices/system/cpu/cpufreq/boost
    echo "CPU boost enabled"
  else
    echo "0" | sudo tee /sys/devices/system/cpu/cpufreq/boost
    echo "CPU boost disabled"
  fi
}

battery() {
  awk '{print $1*10^-6 " W"}' /sys/class/power_supply/BAT0/power_now
  # TODO watch -n 5 battery
}
