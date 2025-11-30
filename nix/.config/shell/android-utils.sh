#!/bin/bash

_get_android_device() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(adb devices | tail --lines +2 | fzf | cut --fields 1)
  # [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  echo "$ANDROID_DEVICE"
}

adb_connect() {
  local ANDROID_DEVICES=(
    "192.168.1.7:5555"
    "Pixel-7-Pro.lan:5555"
    "192.168.1.15:5555"
    "OnePlus-15.lan:5555"
  )
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(printf "%s\n" "${ANDROID_DEVICES[@]}" | fzf)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  adb connect "$ANDROID_DEVICE"
}

adb_disconnect() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  adb disconnect "$ANDROID_DEVICE"
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
  yy "$ANDROID_DEVICE_FOLDER/storage/emulated/0/"
}

adbfs_connected() {
  local ADBFS_FOLDER="/run/media/$USER/adbfs"
  ls -1 "$ADBFS_FOLDER"
}

adbfs_disconnect() {
  local TO_UMOUNT
  TO_UMOUNT=$(mount | grep adbfs | fzf | cut --delimiter " " --fields 3)
  [ -z "$TO_UMOUNT" ] && echo "No mount selected" && return 1
  pgrep --full "$TO_UMOUNT"
  umount "$TO_UMOUNT"
}

scrcpy_connect() {
  local ANDROID_DEVICE
  ANDROID_DEVICE=$(_get_android_device)
  [ -z "$ANDROID_DEVICE" ] && echo "No device selected" && return 1
  scrcpy --render-driver=opengles2 --no-audio -K -b 1M -s "$ANDROID_DEVICE"
}
