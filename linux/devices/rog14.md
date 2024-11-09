# ASUS GA401IV

## [asus-linux](https://asus-linux.org/)

## Fedora

### [Fedora Installation](https://asus-linux.org/guides/fedora-guide/)

- Enabling Secure Boot
- Switching from Nvidia GPU to AMD Integrated
- Hide an Unnecessary Boot Message
- Desktop Wigdets
- [Keyboard -> Can I re-map the arrow keys?](https://asus-linux.org/faq/)

### Asus specific soft

```bash
sudo dnf copr enable lukenukem/asus-linux
sudo dnf update
sudo dnf install asusctl supergfxctl asusctl-rog-gui
sudo systemctl enable --now supergfxd
```

### repos

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#! https://rpmsphere.github.io/ says, that 38th is latest
# sudo dnf install https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-$(rpm -E %fedora)-1.noarch.rpm
sudo dnf install https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-38-1.noarch.rpm
sudo dnf update -y
```

### nvidia

```bash
sudo dnf install kernel-devel
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo systemctl enable nvidia-{suspend,resume,hibernate,powerd}
systemctl mask nvidia-fallback
```

### vscode

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

### microsoft-edge

```bash
TODO
```

### other

- TODO `sudo dnf copr enable phracek/PyCharm`

### TODO

- migrate to KDE (or nixos w/KDE)
- fedora shortcut move window to another monitor
- <https://gitlab.com/kirbykevinson/libinput-config>
- custom 4 fingers gestures
  - <https://copr.fedorainfracloud.org/coprs/elxreno/libinput-gestures/>
  - <https://gitlab.com/cunidev/gestures>

### [Fedora Hibernate](https://fedoramagazine.org/hibernation-in-fedora-36-workstation/)

- Conflicts with Secure Boot
  - `CONFIG_LOCK_DOWN_IN_EFI_SECURE_BOOT=n` could help

#### install

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
sudo systemctl enable hibernate-preparation

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
sudo systemctl enable hibernate-resume

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

#### rollback

```bash
# remove SELinux module via semodule -r systemd_sleep
# $ semodule -r systemd_sleep

# remove systemd overrides for systemd-logind.service and systemd-hibernation.service
sudo rm -rf /etc/systemd/system/systemd-hibernate.service.d/
sudo rm -rf /etc/systemd/system/systemd-logind.service.d/

# disable and remove hibernation preparation and resume services
sudo systemctl disable hibernate-resume
sudo systemctl disable hibernate-preparation
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

## Gnome shortcuts (Keyboard -> View and Customize Shortcuts)

- ROG G14 2020 specific
  - ROG key -> `bash -c 'demotoggle'`
  - FN+F5 -> `bash -c 'fan'`
  - FN+F6 -> `bash -c 'noanime && anime'`
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
sudo systemctl enable --all ydotool && systemctl status ydotool
# or
sudo systemctl reload ydotool && systemctl status ydotool
```

## Grub tweak

- Spam ESC key to open menu
- Check for `GRUB_CMDLINE_LINUX` duplicates
  - Also emove `nomodeset` if any

```bash
sudoedit /etc/default/grub
# ---
GRUB_TIMEOUT=1
GRUB_TIMEOUT_STYLE="hidden"
# ---
sudo grub2-mkconfig -o /etc/grub2.cfg
```
