# rock-3a
## Install
```bash
tzselect
# 7 39 2 1
sudo apt install git -y
sudo apt install mc bat btop ncdu tmux tree neovim neofetch -y
git clone https://github.com/barsikus007/config.git
~/config/configs/install.sh
bash
u
sudo apt install linux-headers-current-rockchip64 -y
# sudo apt install linux-headers-edge-rk35xx

# armbian-bsp-cli-rock-3a-edge for armbian-add-overlay
# linux-image-edge-rk35xx

# https://radxa-repo.github.io/jammy/
```
## SATA HAT
```bash
# curl -sL https://rock.sh/get-rockpi-penta | sudo -E bash -
sudo apt install software-properties-common -y
curl -sL https://rock.sh/get-rockpi-penta | sed -e 's/$ARMBIAN_URL | sudo -E bash -/$ARMBIAN_URL > rockpi-penta-install.sh/' | sudo -E bash -
sed -i "s/focal/jammy/" rockpi-penta-install.sh
chmod +x rockpi-penta-install.sh && sudo ./rockpi-penta-install.sh

# overlay fix
# https://forum.radxa.com/t/how-to-turn-off-blue-led-or-green-led-under-armbian-system/15264/3
wget https://raw.githubusercontent.com/radxa/kernel/stable-4.19-rock3/arch/arm64/boot/dts/rockchip/overlay/{rk3568-pwm8-m0-fan,rk3568-pwm15-m0,rk3568-i2c3-m0}.dts
sed -i 's/active/default/g' {rk3568-pwm8-m0-fan,rk3568-pwm15-m0,rk3568-i2c3-m0}.dts
sudo armbian-add-overlay rk3568-i2c3-m0.dts
sudo armbian-add-overlay rk3568-pwm15-m0.dts
sudo armbian-add-overlay rk3568-pwm8-m0-fan.dts
```

## Other
- OMV
- https://wiki.omv-extras.org/doku.php?id=omv6:armbian_bullseye_install#install_omv
- systemctl unmask systemd-networkd.service

## [Fix PCIE](https://forum.radxa.com/t/m2-ssd-will-randomly-fail-to-write-on-rock3a/9442/29)
### Ubuntu
```bash
sudo cp ~/NAS/rock3a-fix-pcie.dtbo /boot/dtbs/$(uname -r)/rockchip/overlay/
```
### Armbian
```bash
cat <<EOT >> rock3a-fix-pcie.dts
/dts-v1/;
/plugin/;
/ {
        fragment@0 {
                target-path = <&pcie2x1>;
                __overlay__ {
                                /delete-property/ vpcie3v3-supply;
                };
        };
};
EOT
# or
cat <<EOT >> rock3a-fix-pcie.dts
/dts-v1/;
/plugin/;
/ {
        fragment@0 {
                target-path = <&pcie2x1>;
                __overlay__ {
                                vpcie3v3-supply = <&vcc3v3_sys>;
                };
        };
};
EOT
sudo armbian-add-overlay rock3a-fix-pcie.dts
```

## NAS
### ZFS
```bash
sudo apt install zfsutils-linux zfs-dkms -y
sudo reboot

sudo /sbin/modprobe zfs

sudo zpool create -O utf8only=on -O normalization=formD -O compression=lz4 tank raidz sda sdb sdc sdd

sudo zfs create tank/apps
sudo zfs create tank/storage
sudo chown rock:rock /tank/storage/
```
### SMART
```bash
sudo apt install smartmontools -y
```
## Ubuntu-20.04-linux-4.19
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
