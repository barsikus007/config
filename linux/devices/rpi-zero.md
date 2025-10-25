# [RPI](../README.md)

## [Kali](https://www.kali.org/docs/arm/raspberry-pi-zero-w/)

### WiFi setup

```bash
wpa_passphrase "Network 1" >> wpa_supplicant.conf
wpa_passphrase "Network 2 with lower priority" >> wpa_supplicant.conf
```

Then edit config values

```conf
network={
  ssid="Network 1"
  #psk="12345678"
  psk=hex_key
  priority=2
}
network={
  ssid="Network 2 with lower priority"
  #psk="12345678"
  psk=hex_key
}
```

### [Bluetooth stealth mode](https://stackoverflow.com/a/67193246/15844518)

```bash
sudoedit /etc/systemd/system/bluetooth.target.wants/bluetooth.service

ExecStart=/usr/libexec/bluetooth/bluetoothd --noplugin=hostname


sudo systemctl daemon-reload && sudo service bluetooth restart


sudo hciconfig hci0 name
sudo hciconfig hci0 name ''
```

## [Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit)

(Probably, outdated)

### setup

```bash
# Expand filesystem
sudo raspi-config --expand-rootfs
# Create password for user pi
passwd
```

### Create files

#### /boot/ssh

#### /boot/wpa_supplicant.conf

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
