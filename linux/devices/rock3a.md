# rock-3a

## Armbian install (choose legacy-kernel)

```bash
tzselect
# 7 39 2 1
base="mc git btop ncdu tmux tree neovim neofetch"
sudo apt install $base -y
git clone https://github.com/barsikus007/config.git
~/config/configs/install.sh
bash
u
sudo apt install linux-headers-legacy-rk35xx -y

#for armbian-add-overlay
sudo apt install armbian-bsp-cli-rock-3a-legacy
```

## RKMPP

```bash
sudo add-apt-repository ppa:liujianfeng1994/rockchip-multimedia -y
sudo apt update -y
sudo apt install rockchip-multimedia-config ffmpeg -y
```

## NPU

```bash
curl -L --output rknpu2-rk356x_latest_arm64.deb https://github.com/radxa-pkg/rknn2/releases/latest/download/rknpu2-rk356x_$(curl -L https://github.com/radxa-pkg/rknn2/releases/latest/download/VERSION)_arm64.deb
sudo dpkg -i rknpu2-rk356x_latest_arm64.deb
rm rknpu2-rk356x_latest_arm64.deb
```

### Test

```bash
git clone https://github.com/rockchip-linux/rknpu2
cd rknpu2/examples/rknn_yolov5_demo/
chmod +x build-linux_RK3566_RK3568.sh
./build-linux_RK3566_RK3568.sh
cd install/rknn_yolov5_demo_Linux/
./rknn_yolov5_demo model/RK3566_RK3568/yolov5s-640-640.rknn model/bus.jpg
```

## SATA HAT

```bash
curl -sL https://raw.githubusercontent.com/barsikus007/rockpi-penta/master/install.sh | sudo -E bash -

sudo systemctl stop armbian-led-state.service && sudo sed -i 's/trigger=heartbeat/trigger=none/' /etc/armbian-leds.conf && sudo sed -i 's/brightness=0/brightness=1/' /etc/armbian-leds.conf && sudo systemctl start armbian-led-state.service


# overlay fix
wget https://raw.githubusercontent.com/radxa/kernel/stable-4.19-rock3/arch/arm64/boot/dts/rockchip/overlay/{rk3568-pwm8-m0-fan,rk3568-pwm15-m0,rk3568-i2c3-m0}.dts
sed -i 's/active/default/g' {rk3568-pwm8-m0-fan,rk3568-pwm15-m0}.dts
sudo armbian-add-overlay rk3568-i2c3-m0.dts
sudo armbian-add-overlay rk3568-pwm15-m0.dts
sudo armbian-add-overlay rk3568-pwm8-m0-fan.dts
```

## Other

- OMV
  - <https://wiki.omv-extras.org/doku.php?id=omv6:armbian_bullseye_install#install_omv>
  - systemctl unmask systemd-networkd.service

## NAS

### [ZFS шnstall on android based kernels](https://github.com/radxa/kernel/issues/54#issuecomment-1788453183)

```patch
diff -durN zfs-2.2.2.orig/config/kernel.m4 zfs-2.2.2/config/kernel.m4
--- zfs-2.2.2.orig/config/kernel.m4	2023-10-13 07:03:31.000000000 +0800
+++ zfs-2.2.2/config/kernel.m4	2023-10-21 17:15:21.214263487 +0800
@@ -660,6 +660,7 @@
 MODULE_AUTHOR(ZFS_META_AUTHOR);
 MODULE_VERSION(ZFS_META_VERSION "-" ZFS_META_RELEASE);
 MODULE_LICENSE($3);
+MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);
 ])

 dnl #
diff -durN zfs-2.2.2.orig/module/os/linux/spl/spl-generic.c zfs-2.2.2/module/os/linux/spl/spl-generic.c
--- zfs-2.2.2.orig/module/os/linux/spl/spl-generic.c	2023-10-13 07:41:34.965111309 +0800
+++ zfs-2.2.2/module/os/linux/spl/spl-generic.c	2023-10-21 17:16:25.231694524 +0800
@@ -929,3 +929,4 @@
 MODULE_AUTHOR(ZFS_META_AUTHOR);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ZFS_META_VERSION "-" ZFS_META_RELEASE);
+MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);
diff -durN zfs-2.2.2.orig/module/os/linux/zfs/zfs_ioctl_os.c zfs-2.2.2/module/os/linux/zfs/zfs_ioctl_os.c
--- zfs-2.2.2.orig/module/os/linux/zfs/zfs_ioctl_os.c	2023-10-13 07:41:34.894111142 +0800
+++ zfs-2.2.2/module/os/linux/zfs/zfs_ioctl_os.c	2023-10-21 17:17:42.042612036 +0800
@@ -377,3 +377,4 @@
 MODULE_LICENSE("Dual BSD/GPL"); /* zstd / misc */
 MODULE_LICENSE(ZFS_META_LICENSE);
 MODULE_VERSION(ZFS_META_VERSION "-" ZFS_META_RELEASE);
+MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);
```

```bash
# based on https://github.com/openzfs/zfs/issues/15586#issuecomment-1836806381
# patch
OPENZFS_VERSION="2.2.2"
git clone --branch zfs-${OPENZFS_VERSION} https://github.com/openzfs/zfs zfs-${OPENZFS_VERSION}
cd zfs-${OPENZFS_VERSION}/
vim zfs.patch
git apply zfs.patch

# build
# prepare
sudo apt install build-essential autoconf automake libtool gawk fakeroot dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-generic python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx libpam0g-dev -y
sh autogen.sh
./configure
make -s -j$(nproc)

# install
mkdir build
cd build
make native-deb ..
# dkms is easier to install than patching modules package with correct kernel package name
cd ..
mkdir ../zfs-deb
mv *.deb ../zfs-deb/
cd ../zfs-deb/
sudo apt install --fix-missing openzfs-zfsutils*.deb openzfs-lib*.deb openzfs-zfs-dkms*.deb -y
# sudo apt-mark hold openzfs-zfsutils
# patch zfs-auto-snapshot
apt-get download zfs-auto-snapshot
dpkg -x zfs-auto-snapshot*.deb zfs-auto-snapshot
dpkg --control zfs-auto-snapshot*.deb zfs-auto-snapshot/DEBIAN
sed -i "s/zfsutils-linux/openzfs-zfsutils/" zfs-auto-snapshot/DEBIAN/control
dpkg -b zfs-auto-snapshot openzfs-auto-snapshot.deb
sudo apt install --fix-missing openzfs-auto-snapshot.deb
sudo apt-mark hold zfs-auto-snapshot
```

### SMART

```bash
sudo apt install smartmontools -y
```

## Old Ubuntu-20.04-linux-4.19 setup

```bash
sudo vim /etc/apt/sources.list.d/apt-radxa-com.list
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean
sudo cat /sys/class/thermal/thermal_zone*/temp
sudo apt install linux-4.19-rock-3-latest rockchip-overlay
sudo apt install curl mc neofetch stress -y
curl -sL https://rock.sh/get-rockpi-penta | sudo -E bash -
# stress --cpu 8 --io 4 --vm 4 --vm-bytes 1024M --timeout 20s
# https://wiki.radxa.com/Rock3/hardware/models
```
