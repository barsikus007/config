#!/bin/bash
AUTHOR='Akgnah <setq@radxa.com>'
VERSION='0.10'
PI_MODEL=`tr -d '\0' < /proc/device-tree/model`
PI_DEB="https://s3.setq.io/rockpi/deb/rockpi-penta-${VERSION}.deb"
LIBMRAA="https://s3.setq.io/rockpi/deb/libmraa-1.6.deb"
SSD1306="https://s3.setq.io/rockpi/pypi/Adafruit_SSD1306-v1.6.2.zip"
DISTRO=`cat /etc/os-release | grep VERSION_CODENAME | sed -e 's/VERSION_CODENAME\=//g'`

confirm() {
  printf "%s [Y/n] " "$1"
  read resp < /dev/tty
  if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ]; then
    return 0
  fi
  if [ "$2" == "abort" ]; then
    echo -e "Abort.\n"
    exit 0
  fi
  return 1
}

add_repo() {
  if [ "$DISTRO" == "focal" ]; then
    add-apt-repository ppa:mraa/mraa -y
  else
    echo "deb https://apt.radxa.com/$DISTRO-stable/ $DISTRO main" | tee /etc/apt/sources.list.d/apt-radxa-com.list
    wget -qO - apt.radxa.com/$DISTRO-stable/public.key | apt-key add -
    apt-get update
  fi
}

apt_check() {
  packages="unzip gcc python3-dev python3-setuptools python3-setuptools-scm python3-pip python3-pil"
  need_packages=""

  if [ "$DISTRO" == "bullseye" ]; then
    packages="$packages libc6 libjson-c5 libjson-c-dev libgtest-dev libgcc-s1 libstdc++6"
  elif [ "$DISTRO" == "focal" ]; then
    packages="$packages mraa-tools python3-mraa"
  else
    packages="$packages libmraa"
  fi

  idx=1
  for package in $packages; do
    if ! apt list --installed 2> /dev/null | grep "^$package/" > /dev/null; then
      pkg=$(echo "$packages" | cut -d " " -f $idx)
      need_packages="$need_packages $pkg"
    fi
    ((++idx))
  done

  if [ "$need_packages" != "" ]; then
    echo -e "\nPackage(s) $need_packages is required.\n"
    confirm "Would you like to apt-get install the packages?" "abort"
    apt-get install --no-install-recommends $need_packages -y
  fi
}

deb_install() {
  TEMP_DEB="$(mktemp)"
  curl -sL "$PI_DEB" -o "$TEMP_DEB"
  dpkg -i "$TEMP_DEB"
  rm -f "$TEMP_DEB"

  if [ "$DISTRO" == "bullseye" ]; then
    MRAA_DEB="$(mktemp)"
    curl -sL "$LIBMRAA" -o "$MRAA_DEB"
    dpkg -i "$MRAA_DEB"
    rm -f "$MRAA_DEB"
  fi
}

dtb_enable() {
  fname='rockpi-penta'
  mkdir -p /boot/overlay-user
  curl -sL https://s3.setq.io/rockpi/dtb/rockpi-penta.dtbo -o /boot/overlay-user/${fname}.dtbo

  ENV='/boot/armbianEnv.txt'
  [ -f /boot/dietpiEnv.txt ] && ENV='/boot/dietpiEnv.txt'

  if grep -q '^user_overlays=' "$ENV"; then
    line=$(grep '^user_overlays=' "$ENV" | cut -d'=' -f2)
    if grep -qE "(^|[[:space:]])${fname}([[:space:]]|$)" <<< $line; then
      echo "Overlay ${fname} was already added to /boot/armbianEnv.txt, skip"
    else
      sed -i -e "/^user_overlays=/ s/$/ ${fname}/" "$ENV"
    fi
  else
    sed -i -e "\$auser_overlays=${fname}" "$ENV"
  fi
}

pip_install() {
  TEMP_ZIP="$(mktemp)"
  TEMP_DIR="$(mktemp -d)"
  curl -sL "$SSD1306" -o "$TEMP_ZIP"
  unzip "$TEMP_ZIP" -d "$TEMP_DIR" > /dev/null
  cd "${TEMP_DIR}/Adafruit_SSD1306-v1.6.2"
  python3 setup.py install && cd -
  rm -rf "$TEMP_ZIP" "$TEMP_DIR"
}

main() {
  if [[ "$PI_MODEL" =~ "ROCK" ]]; then
    add_repo
    apt_check
    pip_install
    deb_install
    dtb_enable
  else
    echo 'nothing'
  fi
}

main
