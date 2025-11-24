# [ASUS GA401IV](./README.md)

## [asus-linux](https://asus-linux.org/)

## Fedora

### [Fedora Installation](https://asus-linux.org/guides/fedora-guide/)

- Enabling Secure Boot
- Switching from Nvidia GPU to AMD Integrated
- Hide an Unnecessary Boot Message
- Desktop Wigdets
- [Keyboard -> Can I re-map the arrow keys?](https://asus-linux.org/faq/)

### Asus specific soft

```shell
sudo dnf copr enable lukenukem/asus-linux
sudo dnf update
sudo dnf install asusctl supergfxctl asusctl-rog-gui
sudo systemctl enable --now supergfxd
```

### repos

```shell
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#! https://rpmsphere.github.io/ says, that 38th is latest
# sudo dnf install https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-$(rpm -E %fedora)-1.noarch.rpm
sudo dnf install https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-38-1.noarch.rpm
sudo dnf update -y
```

### nvidia

```shell
sudo dnf install kernel-devel
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo systemctl enable nvidia-{suspend,resume,hibernate,powerd}
systemctl mask nvidia-fallback
```

### vscode

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

### microsoft-edge

```shell
TODO
```

### other

#### wifite

```shell
# install old wifite and deps from rpmfusion
sudo dnf install wifite
# clone upstream wifite2 fork
cd ~/projects
git clone https://github.com/kimocoder/wifite2.git
```

- TODO `sudo dnf copr enable phracek/PyCharm`
- Apply gnome workarounds if used
- flatpak
  - <https://flatpak.org/setup/Fedora>
  - <https://www.linuxcapable.com/install-telegram-on-fedora-linux/>
  - apps
    - com.parsecgaming.parsec
    - org.telegram.desktop
    - ? org.telegram.desktop.webview
    - wezterm
- <https://docs.docker.com/desktop/install/linux-install/#generic-installation-steps>

#### pam fix of mount password remember checkbox

```shell
sudo patch /etc/pam.d/login login.patch
```

```diff
--- /etc/pam.d/login
+++ /etc/pam.d/login
@@ -1,6 +1,8 @@
 #%PAM-1.0
 auth       substack     system-auth
 auth       include      postlogin
+# added manually next line
+auth       optional     pam_gnome_keyring.so
 account    required     pam_nologin.so
 account    include      system-auth
 password   include      system-auth
@@ -13,5 +15,7 @@
 session    optional     pam_keyinit.so force revoke
 session    include      system-auth
 session    include      postlogin
+# added manually next line
+session    optional     pam_gnome_keyring.so auto_start
 -session   optional     pam_ck_connector.so
```

### TODO

- `sudo dnf install cascadia-code-nf-fonts`
- fuck gnomes all my homies use KDE
  - shortcut move window to another monitor
  - <https://gitlab.com/kirbykevinson/libinput-config>
  - custom 4 fingers gestures
    - <https://copr.fedorainfracloud.org/coprs/elxreno/libinput-gestures/>
    - <https://gitlab.com/cunidev/gestures>

### [Fedora Hibernate](https://fedoramagazine.org/hibernation-in-fedora-36-workstation/)

- [New version](https://fedoramagazine.org/update-on-hibernation-in-fedora-workstation/)
  - no need to determine offset
  - a MUCH easier
- Conflicts with Secure Boot
  - `CONFIG_LOCK_DOWN_IN_EFI_SECURE_BOOT=n` could help

#### install

```shell
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

```shell
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

## Gnome

### shortcuts (Keyboard -> View and Customize Shortcuts)

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

#### Get keycodes

```shell
cat /usr/include/linux/input-event-codes.h | grep -E '_(HOME|END|PAGE(UP|DOWN))\s'
```

#### Allow ydotool as non-root

```shell
sed -i "s/ydotoold$/ydotoold --socket-path=\/run\/user\/$UID\/.ydotool_socket --socket-own=$(id -u):$(id -g)/g" /usr/lib/systemd/system/ydotool.service
sudo systemctl daemon-reload
sudo systemctl enable --all ydotool && systemctl status ydotool
# or
sudo systemctl reload ydotool && systemctl status ydotool
```

### GNOME 46/47 workarounds

- TODO Control_R as modifier in gnome
- file-roller-nautilus
  - `sudo dnf install file-roller-nautilus`
- [GNOME moment fix](https://dausruddin.com/how-to-update-gnome-extension-properly-get-rid-of-error/)
  - wtf, no way to restart under wayland...
- [Extension Manager](https://github.com/mjakeman/extension-manager)
- TODO gnome tweaks
- TODO [adwaita for GTK3](https://github.com/lassekongo83/adw-gtk3)
- [GNOME Shell Extensions](https://extensions.gnome.org/local)
  - default
    - [for telegram and docker desktop badges](https://extensions.gnome.org/extension/615/appindicator-support/)
    - [emoji](https://extensions.gnome.org/extension/6242/emoji-copy/)
    - [fix desktop](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)
    - [clipboard history](https://extensions.gnome.org/extension/5278/pano/)
      - install [v23](https://github.com/oae/gnome-shell-pano/releases) for GNOME 46/47
        - unzip to `~/.local/share/gnome-shell/extensions`
        - or `gnome-extensions install -f  pano@elhan.io.zip`
      - change `Global Shortcut` from `Shift+Super+V` to `Super+V`
      - disable sound
    - [Gnome Tweaks 2.0](https://extensions.gnome.org/extension/3843/just-perfection/)
      - Behavior -> Window Demands Attention Focus -> On
  - laptop
    - [windows-like gestures](https://extensions.gnome.org/extension/4245/gesture-improvements/)
      - [GNOME moment](https://github.com/sidevesh/gnome-gesture-improvements--transpiled)
    - [Profile badge indicator](https://extensions.gnome.org/extension/5335/power-profile-indicator/)
    - [GPU in power menu](https://extensions.gnome.org/extension/5344/supergfxctl-gex/)
      - [GNOME moment](https://extensions.gnome.org/extension/7018/gpu-supergfxctl-switch/)

## Grub tweak

- Spam ESC key to open menu
- `/etc/default/grub`
  - Check for `GRUB_CMDLINE_LINUX` duplicates
    - Also emove `nomodeset` if any

```shell
cat <<-EOF | sudo tee /etc/default/grub.d/99-hide-timeout >/dev/null
GRUB_TIMEOUT=1
GRUB_TIMEOUT_STYLE=hidden
EOF
# or edit /etc/default/grub (or maybe try /etc/grub.d/ then) if doesn't work, then
sudo grub2-mkconfig -o /etc/grub2.cfg
```
