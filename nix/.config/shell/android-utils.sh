#!/bin/bash

_get_android_device() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(adb devices | tail --lines +2 | fzf | cut --fields 1)
  # [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  echo "$ANDROID_DEVICE"
}

adb_connect() {
  local INTERFACE
  # Try finding interface from default route
  INTERFACE=$(ip -o -4 route show default | head -n 1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
  # Fallback to first global interface
  [ -z "$INTERFACE" ] && INTERFACE=$(ip -o -4 addr show scope global | head -n 1 | awk '{print $2}')

  if [ -z "$INTERFACE" ]; then
    echo "Error: Could not determine local interface"
    echo "ip route output:"
    ip -o -4 route show default
    return 1
  fi

  local SUBNET
  SUBNET=$(ip -o -f inet addr show "$INTERFACE" | head -n 1 | awk '{print $4}')

  if [ -z "$SUBNET" ]; then
    echo "Error: Could not determine local subnet on interface $INTERFACE"
    return 1
  fi

  echo "Scanning $SUBNET on $INTERFACE for ADB devices (port 5555) with nc..."
  local DEVICES
  # DEVICES=$(nmap -p 5555 --open -T aggressive -n --max-retries 0 "$SUBNET" -oG - | awk '/5555\/open/ {print $2}')
  local PREFIX
  PREFIX=$(echo "$SUBNET" | cut -d'/' -f1 | cut -d'.' -f1-3)
  #? Fast parallel scan using nc
  DEVICES=$(
    for i in {1..254}; do
      (
        timeout 0.5 nc -z "$PREFIX.$i" 5555 2>/dev/null && echo "$PREFIX.$i"
      ) &
    done
    wait
  )

  if [ -z "$DEVICES" ] || [ "$DEVICES" = "" ]; then
    echo "No devices found with port 5555 open"
    return 0
  fi

  local SELECTED
  SELECTED=$(echo "$DEVICES" | sed 's/$/:5555/' | fzf --prompt="ADB device> ")
  [ -z "$SELECTED" ] && return 1
  adb connect "$SELECTED"
}

adb_disconnect() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  adb disconnect "$ANDROID_DEVICE"
}

adb_shell_as_root() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  adb -s "$ANDROID_DEVICE" shell -t "su -c /data/data/com.termux/files/home/.adbrc"
}

adb_shell_as_termux() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  # shellcheck disable=SC2016
  adb -s "$ANDROID_DEVICE" shell -t 'su $(su -c "stat -c %U /data/data/com.termux") -c /data/data/com.termux/files/home/.adbrc'
}

adbfs_connect() {
  local ANDROID_DEVICE_LINE
  ANDROID_DEVICE_LINE=$(adb devices -l | tail --lines +2 | fzf)
  [ -z "$ANDROID_DEVICE_LINE" ] && echo "No device selected" && return 1

  local ANDROID_DEVICE_MODEL
  ANDROID_DEVICE_MODEL=$(echo $ANDROID_DEVICE_LINE | sed 's/.*model:\([^ ]*\).*/\1/')

  local ADBFS_FOLDER="/run/media/$USER/adbfs"
  [ ! -d "$ADBFS_FOLDER" ] && sudo mkdir -p "$ADBFS_FOLDER" && sudo chown "$(id -u):$(id -g)" "$ADBFS_FOLDER"

  local ANDROID_DEVICE_FOLDER="$ADBFS_FOLDER/$ANDROID_DEVICE_MODEL"
  echo "Device folder $ANDROID_DEVICE_FOLDER:"
  ls -la "$ANDROID_DEVICE_FOLDER"

  echo "Unmounting..."
  umount "$ANDROID_DEVICE_FOLDER"
  mkdir -p "$ANDROID_DEVICE_FOLDER"
  adbfs "$ANDROID_DEVICE_FOLDER" -o "uid=$(id -u),gid=$(id -g)"
  y "$ANDROID_DEVICE_FOLDER/storage/emulated/0/"
}

adbfs_connected() {
  local ADBFS_FOLDER="/run/media/$USER/adbfs"
  ls -1 "$ADBFS_FOLDER"
}

adbfs_disconnect() {
  local TO_UMOUNT
  TO_UMOUNT=$(mount | grep adbfs | fzf | cut --delimiter=" " --fields=3)
  [ -z "$TO_UMOUNT" ] && echo "No mount selected" && return 1
  pgrep --full "$TO_UMOUNT"
  umount "$TO_UMOUNT"
}

scrcpy_connect() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  scrcpy -K --render-driver=opengles2 --no-audio --video-bit-rate=1M --serial="$ANDROID_DEVICE" "$@"
}

scrcpy_camera() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  sudo v4l2loopback-ctl add --name "scrcpy Cam" /dev/video9
  scrcpy --render-driver=opengles2 --video-source=camera --no-audio --v4l2-sink=/dev/video9 --orientation=90 --camera-size=1920x1440 --camera-id=0 --no-window --serial="$ANDROID_DEVICE" "$@"
}

scrcpy_camera_ffmpeg() {
  sudo v4l2loopback-ctl add --name "ffmpeg Cam" /dev/video10
  ffmpeg -f v4l2 -i /dev/video9 -vf "transpose=1,format=yuv420p" -f v4l2 /dev/video10
}
