# ASUS GA401IV
## TODO
- https://gitlab.com/kirbykevinson/libinput-config
- custom 4 fingers gestures
  - https://copr.fedorainfracloud.org/coprs/elxreno/libinput-gestures/
  - https://gitlab.com/cunidev/gestures
## [Fedora Installation](https://asus-linux.org/wiki/fedora-guide/)
```bash
# TODO script
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
- Show the notification list Super+V -> Super+N
  - Super+N -> None?TODO
  - Shift+Super+V -> Super+V in Pano extension
  - FN+F5 -> `bash -c 'fan'`
  - ROG key -> `bash -c 'demotoggle'`
  - Fn+Right-Arrow -> `TODO end`
  - Fn+Left-Arrow -> `TODO home'`
  - R-Ctrl+Right-Arrow -> `TODO end`
  - R-Ctrl+Left-Arrow -> `TODO home'`
  - R-Ctrl+Up-Arrow -> `TODO PgUp'`
  - R-Ctrl+Down-Arrow -> `TODO PgDown'`
## Grub tweak
```bash
sudo nvim /etc/default/grub
# ---
GRUB_TIMEOUT=1
GRUB_TIMEOUT_STYLE="hidden"
# ---
sudo grub2-mkconfig -o /etc/grub2.cfg
```
## Anime Matrix aliases
```bash
# TODO attach files
alias animeclr='asusctl anime -c > /dev/null'
alias noanime='systemctl --user stop asusd-user && animeclr'
alias anime='animeclr && systemctl --user start asusd-user'
alias demosplash='asusctl anime pixel-image -p ~/.config/rog/bad-apple.png'
alias nodemo='tmux kill-session -t sound 2> /dev/null; noanime'
alias demo='nodemo && anime && sleep 0.5 && tmux new -s sound -d "play ~/Music/bad-apple.mp3 repeat -"'

# demo toggle function (for dedicated key)
demotoggle() {
  (
    DEMO_FILE=~/.config/.is-demo-working 
    if [ -f "$DEMO_FILE" ]; then
      nodemo && rm "$DEMO_FILE"
    else
      demo && touch "$DEMO_FILE"
    fi
  )
}
```
## fan switch function (for Fn+F5 key)
```bash
fan() {
  (
    asusctl profile -n
    FAN_STATE=$(asusctl profile -p)
    FAN_STATE_LOWER=$(echo "$FAN_STATE" | awk '{print $4}' | tr '[:upper:]' '[:lower:]')
    [ "$FAN_STATE_LOWER" = quiet ] && FAN_STATE_LOWER=power-saver
    PREV_ID=$(cat ~/.config/.prev-fan-notification-id)
    [ -z "$PREV_ID" ] && PREV_ID=0
    notify-send --hint int:transient:1 "Power Profile" "$FAN_STATE" -t 1 -i power-profile-"$FAN_STATE_LOWER" -p -r "$PREV_ID" > ~/.config/.prev-fan-notification-id
  )
}
```