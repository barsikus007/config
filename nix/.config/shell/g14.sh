#!/bin/sh

demo_download() {
  # TODO make check if files exits
  (
    VIDEO_FOLDER=~/.config/rog
    mkdir -p $VIDEO_FOLDER
    VIDEO_ID=UkgK8eUdpAo
    VIDEO_NAME=bad_apple
    yt-dlp $VIDEO_ID -o - | ffmpeg -i - -filter_complex "[0:v]fps=30,scale=66:-1,setpts=0.645*PTS[v]" -map '[v]' -loop 0 $VIDEO_FOLDER/$VIDEO_NAME.gif $VIDEO_FOLDER/$VIDEO_NAME.mp3 -y
  )
}


# TODO split em
#? ROG G14 specific
# TODO deps: tmux asusctl sox(play)
#! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
alias animeclr='asusctl anime -E false > /dev/null'
#! alias noanime='systemctl --user stop asusd-user && animeclr'
alias noanime='tmux kill-session -t anime 2> /dev/null; animeclr'
#! alias yesanime='systemctl --user start asusd-user'
alias yesanime='tmux new -s anime -d "asusctl anime gif -p ~/.config/rog/bad-apple.gif"'
alias anime='animeclr && yesanime'
alias demosplash='asusctl anime pixel-image -p ~/.config/rog/bad-apple.png'
alias nodemo='tmux kill-session -t sound 2> /dev/null; noanime'
alias demo='nodemo && anime && sleep 0.5 && tmux new -s sound -d "play ~/.config/rog/bad-apple.mp3 repeat -"'
demotoggle() {
  # demo toggle function (for dedicated key)
  (
    DEMO_FILE=~/.config/.is-demo-working
    if [ -f "$DEMO_FILE" ]; then
      nodemo && rm "$DEMO_FILE"
    else
      demo && touch "$DEMO_FILE"
    fi
  )
}

#? asus general
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

#? laptop general
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
}

power_draw() {
  watch -n 5 zsh -c battery
}
