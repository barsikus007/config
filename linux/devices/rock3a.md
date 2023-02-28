# rock-3a
## TODO
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