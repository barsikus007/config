# ASUS GA401IV
- https://gitlab.com/kirbykevinson/libinput-config
- https://unix.stackexchange.com/questions/358741/asus-x540s-laptop-internal-microphone-listed-but-not-working
- https://www.reddit.com/r/ZephyrusG14/comments/jnve6t/microphone_not_working_on_ubuntu/
-
- 38. https://www.reddit.com/r/ZephyrusG14/comments/hldxcv/how_to_get_10_hours_battery/
- 39. https://discord.com/channels/736971456054952027/736971456650412114/784252533886418954
- 40. https://github.com/aredden/RestartGPU/
- 41. https://github.com/sammilucia/ASUS-G14-Debloating/
- 42. https://www.reddit.com/r/ZephyrusG14/comments/isc47y/another_solution_for_missing_pgup_pgdn_home_and/
- 43. https://drive.google.com/drive/u/0/folders/1_FsWd2CAjAK13t82ZucTlNGabuI3laWF
- 43.3 https://blog.joshwalsh.me/asus-anime-matrix/
- https://drive.google.com/file/d/1tsmKRIt1S2AUqp3S2pFVCtBNxXtQC3bE/view
- https://rog.asus.com/anime-matrix-pixel-editor/?device=DS-Animate#editor
-
- shortcuts
- grub autoboot
- grub check recovery
- https://fedoramagazine.org/hibernation-in-fedora-36-workstation/
  - test ```bash
  zxc 
  asd
  qwe
  ```
  - script
## [Hibernate](https://fedoramagazine.org/hibernation-in-fedora-36-workstation/)
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
# TODO 1 or 2 calls instead of 3
sudo ./btrfs_map_physical /swap/swapfile | column -ts $'\t' -o " | "
physical_offset=$(sudo ./btrfs_map_physical /swap/swapfile | sed -n '2p' | awk '{print $9}')
page_size=$(sudo ./btrfs_map_physical /swap/swapfile | sed -n '2p' | awk '{print $2}')
resume_offset=$((physical_offset/page_size))
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
## Shortcuts
- Show the notification list Super+V -> Super+N
  - Super+N -> None
  - Shift+Super+V -> Super+V in Pano extension
