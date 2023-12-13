# ASUS GA401IV

## TODO

- fedora shortcut move window to another monitor
- <https://gitlab.com/kirbykevinson/libinput-config>
- custom 4 fingers gestures
  - <https://copr.fedorainfracloud.org/coprs/elxreno/libinput-gestures/>
  - <https://gitlab.com/cunidev/gestures>

## [Fedora Installation](https://asus-linux.org/wiki/fedora-guide/)

```bash
# TODO script
# add rpmfusion repo
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo rpm -i https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-$(rpm -E %fedora)-1.noarch.rpm
```

## [Fedora Hibernate](https://fedoramagazine.org/hibernation-in-fedora-36-workstation/)

```bash
sudo btrfs subvolume create /swap
swapon

sudo touch /swap/swapfile
sudo chattr +C /swap/swapfile
sudo fallocate --length 24G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile

cat <<-EOF | sudo tee /etc/dracut.conf.d/resume.conf
add_dracutmodules+=" resume "
EOF
sudo dracut -f

uuid=$(findmnt -no UUID -T /swap/swapfile)

cd /tmp
# choose source:
# master
wget https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
# 100% working commit
wget https://raw.githubusercontent.com/osandov/osandov-linux/49aec6b85d8457fa25b5d8f6c2afb3dd4592401a/scripts/btrfs_map_physical.c
gcc -O2 -o btrfs_map_physical btrfs_map_physical.c
cmd_result="$(sudo ./btrfs_map_physical /swap/swapfile)"
echo "$cmd_result" | column -ts $'\t' -o " | "
physical_offset=$(echo "$cmd_result" | sed -n '2p' | awk '{print $9}')
page_size=$(echo "$cmd_result" | sed -n '2p' | awk '{print $2}')
resume_offset=$((physical_offset/page_size))
echo $resume_offset
cd

sudo grubby --args="resume=UUID=$uuid resume_offset=$resume_offset" --update-kernel=ALL


cat <<-EOF | sudo tee /etc/systemd/system/hibernate-preparation.service
[Unit]
Description=Enable swap file and disable zram before hibernate
Before=systemd-hibernate.service

[Service]
User=root
Type=oneshot
ExecStart=/bin/bash -c "/usr/sbin/swapon /swap/swapfile && /usr/sbin/swapoff /dev/zram0"

[Install]
WantedBy=systemd-hibernate.service
EOF
sudo systemctl enable hibernate-preparation.service

cat <<-EOF | sudo tee /etc/systemd/system/hibernate-resume.service
[Unit]
Description=Disable swap after resuming from hibernation
After=hibernate.target

[Service]
User=root
Type=oneshot
ExecStart=/usr/sbin/swapoff /swap/swapfile

[Install]
WantedBy=hibernate.target
EOF
sudo systemctl enable hibernate-resume.service

sudo mkdir -p /etc/systemd/system/systemd-logind.service.d/
cat <<-EOF | sudo tee /etc/systemd/system/systemd-logind.service.d/override.conf
[Service]
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
EOF

sudo mkdir -p /etc/systemd/system/systemd-hibernate.service.d/
cat <<-EOF | sudo tee /etc/systemd/system/systemd-hibernate.service.d/override.conf
[Service]
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
EOF

sudo shutdown

# need to disable secure boot
systemctl hibernate

# $ audit2allow -b
# #============= systemd_sleep_t ==============
# allow systemd_sleep_t unlabeled_t:dir search;
# $ cd /tmp
# $ audit2allow -b -M systemd_sleep
# $ semodule -i systemd_sleep.pp
```

remove

```bash
# remove SELinux module via semodule -r systemd_sleep
# $ semodule -r systemd_sleep

# remove systemd overrides for systemd-logind.service and systemd-hibernation.service
sudo rm -rf /etc/systemd/system/systemd-hibernate.service.d/
sudo rm -rf /etc/systemd/system/systemd-logind.service.d/

# disable and remove hibernation preparation and resume services
sudo systemctl disable hibernate-resume.service
sudo systemctl disable hibernate-preparation.service
sudo rm /etc/systemd/system/hibernate-resume.service
sudo rm /etc/systemd/system/hibernate-preparation.service

# remove kernel cmdline args via grubby –remove-args=
sudo grubby --remove-args="resume resume_offset" --update-kernel=ALL

# remove the dracut configuration and rebuild dracut
sudo rm /etc/dracut.conf.d/resume.conf
sudo dracut -f

# remove the swapfile
sudo rm /swap/swapfile
# remove the swap subvolume
sudo btrfs subvolume delete /swap
```

## Shortcuts (Keyboard -> View and Customize Shortcuts)

- ROG G14 2020 specific
  - ROG key -> `bash -c 'demotoggle'`
  - FN+F5 -> `bash -c 'fan'`
  - FN+F6 -> `bash -c 'noanime && anime'`
  - Fn+Right-Arrow -> End`ydotool key 107:1 107:0`
  - Fn+Left-Arrow -> Home`ydotool key 102:1 102:0`
  - R-Ctrl+Right-Arrow -> End`ydotool key 107:1 107:0`
  - R-Ctrl+Left-Arrow -> Home`ydotool key 102:1 102:0`
  - R-Ctrl+Up-Arrow -> PgUp`ydotool key 104:1 104:0`
  - R-Ctrl+Down-Arrow -> PgDown`ydotool key 109:1 109:0`
- Show the notification list Super+V -> Super+N
  - TODO ? Super+N -> None
- Home folder -> Super+E
- TODO move windows and workspaces shortcuts
  - TODO Move to workspace on the left Ctrl+Super_Left
- fix language change
  - `gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>Alt_L', '<Shift>XF86Keyboard']"`
  - revert `gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Super>space', '<Shift>XF86Keyboard']"`

### Get keycodes

```bash
cat /usr/include/linux/input-event-codes.h | grep -E '_(HOME|END|PAGE(UP|DOWN))\s'
```

### Allow ydotool as non-root

```bash
sed -i "s/ydotoold$/ydotoold --socket-path=\/run\/user\/$UID\/.ydotool_socket --socket-own=$(id -u):$(id -g)/g" /usr/lib/systemd/system/ydotool.service
sudo systemctl daemon-reload
sudo systemctl enable --all ydotool.service && sudo systemctl status ydotool.service
# or
sudo systemctl reload ydotool.service && sudo systemctl status ydotool.service
```

## Grub tweak

```bash
sudo nvim /etc/default/grub
# ---
GRUB_TIMEOUT=1
GRUB_TIMEOUT_STYLE="hidden"
# ---
sudo grub2-mkconfig -o /etc/grub2.cfg
```
