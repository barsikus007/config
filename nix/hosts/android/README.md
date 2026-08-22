# [NixOS on Android](../../README.md)

## nix-on-droid

- [sudo tracking issue](https://github.com/nix-community/nix-on-droid/issues/252)

### installation

1. set bootstrap url to `https://nix-on-droid.unboiled.info/bootstrap` when asked
2. `nix shell nixpkgs#git`
3. `cd && git clone --depth=1 https://github.com/barsikus007/config && cd -`
4. `nix-on-droid switch --flake ~/config/nix`

## [NixOS-DroidVM](https://github.com/Droid-VM/DroidVM)

Qualcomm CPUs in general has no pKVM (needed for AVF): EL2 is taken by Qualcomm Gunyah, kernel runs at EL1 and can never install KVM, while Gunyah exposes protected VMs only

protected-only limits:

- no virtiofs, so no shared dirs with Android (9p still works, it rides plain virtio)
- no balloon, guest memory stays pinned in the host
- all virtio DMA goes through the swiotlb region, guest kernel needs `CONFIG_DMA_RESTRICTED_POOL=y`
- no host access to guest memory means no gdb and no crash dumps, serial console only

host's root stays mandatory: SELinux gates `/dev/gunyah` despite its `0666` mode, and raising the memlock rlimit needs `CAP_SYS_RESOURCE`

### installation

obtainium - `https://github.com/Droid-VM/DroidVM`

#### app settings

1. Disks
   - Download distro image > latest-nixos-minimal-aarch64
   - Create new disk > qcow2; ~20G; zstd comp
2. Networks
   - Create default and run
3. VM
   - set created network and disks
4. Boot VM
   - `ip a && sudo passwd root`

#### host

```shell
adb shell su --command 'nc -L -p 2222 nc <guest-ip> 22' &
adb forward tcp:12222 tcp:2222
SSHPASS='...' nixos-anywhere --env-password --flake ./nix#droidvm --target-host root@localhost --ssh-port 12222
```

disable NixOS iso after install

### update

```shell
adb shell su --command 'nc -L -p 2222 nc <guest-ip> 2222' &
adb forward tcp:12222 tcp:2222
ssh ogurez@localhost -p 12222 -o StrictHostKeychecking=no -o ConnectionAttempts=60 -o UserKnownHostsFile=/dev/null

NIX_SSHOPTS="-p 12222 -o StrictHostKeychecking=no -o ConnectionAttempts=60 -o UserKnownHostsFile=/dev/null" nh os switch --hostname=droidvm --target-host=ogurez@localhost --elevation-strategy=passwordless
```

### notes

- `<guest-ip>` comes from `adb shell su --command 'ip neigh show'`, on the bridge interface (e.g. `br0116f569`)
- check nc used ports
  - `adb shell su --command 'ps -A -o pid,args | grep "[n]c -L -p 2222"'`
- kill nc used ports
  - `adb shell su --command 'pkill -f "nc -L -p 2222"'`
- you need `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];` on a host to deploy
- client kernel [must](https://github.com/Droid-VM/DroidVM/wiki/Problem:-The-virtual-machine's-system-does-not-support-SWIOTLB-Restrict-DMA-Pool.) have `CONFIG_DMA_RESTRICTED_POOL=y` option
- adb shell's cli `/data/data/cn.classfun.droidvm/bin/droidvm`
  - VM definitions live in `files/vms.json`.
- when launching VM with more than 512 MiB [`vcpu hit unknown error: Out of memory (os error 12)`](<https://github.com/Droid-VM/DroidVM/wiki/Problem:-An-out‐of‐memory-error-occurred-while-the-virtual-machine-was-running.>)
  - rebooting the phone and launching immediately fixes it, otherwise use [gh-hugepage-reserve](https://github.com/Droid-VM/gh-hugepage-reserve) module (but it eats RAM from host)

#### display

**2D needs no guest patches.** DroidVM's crosvm fork adds `--simplefb width=W,height=H`,
which appends a `compatible = "simple-framebuffer"` device-tree node consumed by the stock
`simpledrm`/`simplefb` driver; `virtio_gpu` never enters the picture. This is the app's
default display backend. Whether plain `--gpu 2d` with a stock `virtio_gpu` guest driver
works under protected Gunyah is untested and undocumented anywhere.

**3D is not reproducible by hand.** DroidVM gets it through a six-fork stack: their crosvm,
`virglrenderer` (KGSL native-context, turnip in guest over vdrm), `gfxstream`,
`mesa`/`turnip`, guest modules `gunyah_guest.ko` + patched `virtio_gpu`
([droidvm-guest-additions](https://github.com/Droid-VM/droidvm-guest-additions)), and an
unpublished host kernel module `gunyah_host_mod`. The trick is GuestAccept: the host SHAREs
an RM memparcel, the guest accepts it into its own stage-2 by raw HVC, and stock `virtio_gpu`
SIGBUSes because it never accepts. So 3D means running the app as the host runtime, not
rebuilding that stack in Nix.
