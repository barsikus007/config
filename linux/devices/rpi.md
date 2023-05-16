# RPI
## Kali
- https://www.reddit.com/user/Maeky1986/comments/lkb54g/tutorial_raspberry_pi_kali_2021_headless_install/
- https://youtu.be/VXxb_F1Vb7Y
## Create files:
### /wpa_supplicant.conf
```conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=RU
update_config=1
network={
	ssid="WIFI_NAME1"
	psk="WIFI_PASSWORD1"
	priority=1
	key_mgmt=WPA-PSK
}
network={
	ssid="WIFI_NAME2"
	psk="WIFI_PASSWORD2"
	priority=2
	key_mgmt=WPA-PSK
}
```
### /ssh

## Initial setup
```bash
# Expand filesystem
sudo raspi-config --expand-rootfs
# Create password for user pi
passwd
```
