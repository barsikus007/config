#!/bin/bash

#? ROG G14 specific
#? deps: tmux asusctl sox(play)
asus_anime_demo_select() {
  # use fzf (default) or rofi (--interactive) to pick a subfolder and link its frames.gif / sound.mp3 into ~/.config/rog/
  local ROG_ANIME_DIR=~/.config/rog
  local SELECTED_VIDEO
  SELECTED_VIDEO=$(
    find "$ROG_ANIME_DIR" -mindepth 2 -maxdepth 2 \( -name "frames.gif" -o -name "sound.mp3" \) \
      -printf '%h\n' | sort -u \
      | sed "s|$ROG_ANIME_DIR/||" \
      | if [ "${1}" = "--interactive" ]; then
          rofi -dmenu -p "ROG ANIME preset> "  # | fuzzel --dmenu --prompt="ROG ANIME preset: "
        else
          fzf --prompt="ROG ANIME preset> " --preview="ls $ROG_ANIME_DIR/{}"
        fi
  ) || return 1

  local SELECTED_VIDEO_DIR="$ROG_ANIME_DIR/$SELECTED_VIDEO"
  [ -f "$SELECTED_VIDEO_DIR/frames.gif" ] && ln -sf "$SELECTED_VIDEO_DIR/frames.gif" "$ROG_ANIME_DIR/frames.gif" && echo "frames -> $SELECTED_VIDEO/frames.gif"
  [ -f "$SELECTED_VIDEO_DIR/sound.mp3" ]  && ln -sf "$SELECTED_VIDEO_DIR/sound.mp3"  "$ROG_ANIME_DIR/sound.mp3"  && echo "sound  -> $SELECTED_VIDEO/sound.mp3"
}
asus_anime_demo_select_interactive() { asus_anime_demo_select --interactive; }

asus_anime_demo_download() {
  local VIDEO_ID VIDEO_TITLE VIDEO_FOLDER
  if [ -n "$1" ]; then
    VIDEO_ID=$1
  else
    local VIDEO_ID_ENTRY
    VIDEO_ID_ENTRY=$(printf '%s\n' \
      "UkgK8eUdpAo bad-apple" \
      "dQw4w9WgXcQ rickroll" \
      | fzf --prompt="Download preset> ") || return 1
    VIDEO_ID=$(echo "$VIDEO_ID_ENTRY" | awk '{print $}')
  fi

  VIDEO_TITLE=$(yt-dlp --get-filename --output "%(title)s" "$VIDEO_ID" 2>/dev/null | tr ' /' '_-' | tr -cd '[:alnum:]_-')
  VIDEO_FOLDER=~/.config/rog/${VIDEO_ID}__${VIDEO_TITLE}
  mkdir --parents "$VIDEO_FOLDER"
  yt-dlp "$VIDEO_ID" --output - | ffmpeg -i - -filter_complex "[0:v]fps=30,scale=66:-1,setpts=0.645*PTS[v]" -map '[v]' -loop 0 "$VIDEO_FOLDER/frames.gif" "$VIDEO_FOLDER/sound.mp3" -y
}

alias asus_anime_clear='asusctl anime --enable-display false > /dev/null'
alias asus_anime_demo_stop_cleanup='asus_anime_clear && asusctl anime --enable-powersave-anim true > /dev/null'
alias asus_anime_demo_stop_gif='tmux kill-session -t anime 2> /dev/null'
alias asus_anime_demo_start_prepare='asus_anime_clear && asusctl anime --enable-powersave-anim false > /dev/null'
alias asus_anime_demo_start_gif='tmux new -s anime -d "asusctl anime gif --path ~/.config/rog/frames.gif"'
alias asus_anime_demo_show_splash='asusctl anime pixel-image --path ~/.config/rog/bad-apple.png'
alias asus_anime_demo_stop_sound='tmux kill-session -t sound 2> /dev/null'
alias asus_anime_demo_stop='asus_anime_demo_stop_sound; asus_anime_demo_stop_gif; asus_anime_demo_stop_cleanup'
alias asus_anime_demo_start_sound='tmux new -s sound -d "PULSE_SINK=alsa_output.pci-0000_04_00.6.analog-stereo play ~/.config/rog/sound.mp3 repeat -"'
#? 0.5s for matrix to start
alias asus_anime_demo_start='asus_anime_demo_stop && asus_anime_demo_start_prepare && asus_anime_demo_start_gif && sleep 0.5 && asus_anime_demo_start_sound'
asus_anime_toggle() {
  #? it could be setted to off for no reason
  asusctl anime --brightness high
  if grep -q 'builtin_anims_enabled: true' /etc/asusd/anime.ron; then
  # if grep -q 'display_enabled: true' /etc/asusd/anime.ron; then
    asusctl anime --enable-powersave-anim false
    # asusctl anime --enable-display false
  else
    asusctl anime --enable-powersave-anim true
    # asusctl anime --enable-display true
  fi
}
asus_anime_demo_toggle() {
  # demo toggle function (for dedicated key)
  (
    DEMO_FILE=/tmp/asus-is-demo-working
    if [ -f "$DEMO_FILE" ]; then
      asus_anime_demo_stop && rm "$DEMO_FILE"
    else
      asus_anime_demo_start && touch "$DEMO_FILE"
    fi
  )
}


#? asusctl specific
asus_profile_toggle() {
  # fan switch function (for Fn+F5 key)
  (
    asusctl profile next
    FAN_STATE=$(asusctl profile get | tail --lines +2)
    FAN_STATE_LOWER=$(echo "$FAN_STATE" | awk '{print $4}' | tr '[:upper:]' '[:lower:]')
    [ "$FAN_STATE_LOWER" = quiet ] && FAN_STATE_LOWER=power-saver
    PREV_ID=$(cat /tmp/asus-prev-fan-notification-id)
    [ -z "$PREV_ID" ] && PREV_ID=0
    notify-send "Power Profile" "$FAN_STATE" --transient --expire-time=1 --icon=power-profile-"$FAN_STATE_LOWER" --replace-id="$PREV_ID" --print-id > /tmp/asus-prev-fan-notification-id
  )
}


#? laptop specific
dgpu_check_processes() {
  fuser --verbose /dev/nvidia*
  cat /sys/bus/pci/devices/0000:0{1,4}:00.0/power{_state,/runtime_status}
}
dgpu_switch_to_integrated/vfio() {
  # TODO: wtf
  sudo /run/current-system/sw/bin/kill --verbose --signal QUIT \
                                    --timeout 1000 TERM \
                                    --timeout 1000 KILL \
                                    --timeout 2000 KILL \
            $(lsof -t /dev/nvidia*); \
  sudo modprobe --remove --all nvidia{_drm,_uvm,_modeset,} && sudo modprobe vfio-pci
}
dgpu_switch_to_hybrid() {
  sudo modprobe --remove vfio-pci && sudo modprobe --all nvidia{,_modeset,_uvm,_drm}
}

boost() {
  # https://www.reddit.com/r/linuxmint/comments/12n8qfe/comment/jge3kys/
  if grep --quiet 0 /sys/devices/system/cpu/cpufreq/boost; then
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
  watch --interval=5 --exec zsh -c battery
}
