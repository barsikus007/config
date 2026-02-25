# very fucking WIP

## crosvm debian

```shell
mkdir -p /data/local/tmp/vm/debian
cd /data/local/tmp/vm/debian

wget https://github.com/polygraphene/gunyah-on-sd-guide/releases/download/v0.0.3/kernel
wget https://dl.google.com/android/ferrochrome/3600000/aarch64/images.tar.gz
tar xvf images.tar.gz vmlinuz initrd.img root_part kernel_extras_part

crosvm --log-level debug run \
  --disable-sandbox --no-balloon --protected-vm-without-firmware --swiotlb 64 \
  --params 'root=/dev/vda rw' --mem 4096 --cpus 4 \
  --rwdisk /data/local/tmp/vm/debian/root_part /data/local/tmp/vm/debian/kernel

cat > vm_config.json <<EOF
{
    "name": "debian",
    "disks": [
        {
            "partitions": [
                {
                    "label": "ROOT",
                    "path": "/data/local/tmp/vm/debian/root_part",
                    "writable": true,
                    "guid": "49ED921A-9CE1-4CCB-BA83-668378BFA640"
                },
                {
                    "label": "KERNEL_EXTRAS",
                    "path": "/data/local/tmp/vm/debian/kernel_extras_part",
                    "writable": false
                }
            ],
            "writable": true
        }
    ],
    "kernel": "/data/local/tmp/vm/debian/vmlinuz",
    "initrd": "/data/local/tmp/vm/debian/initrd.img",
    "params": "root=/dev/vda1 rw",
    "protected": true,
    "cpu_topology": "match_host",
    "platform_version": "~1.0",
    "memory_mib": 4096,
    "debuggable": true,
    "console_out": true,
    "connect_console": true,
    "network": true
}
EOF
vm run /data/local/tmp/vm/debian/vm_config.json
```

## References

- [fix 12 error: out of memory](https://github.com/polygraphene/gunyah-on-sd-guide?tab=readme-ov-file#failed-to-initialize-virtual-machine-out-of-memory-os-error-12)
  - `ulimit -l unlimited`
- [fix 13 error: permission (memlock rlimit)](https://github.com/polygraphene/gunyah-on-sd-guide#vm-command-causes-permission-denied-error)
  - `magiskpolicy --live "allow virtualizationservice magisk process { setrlimit }"`
- [google sources docs](https://android.googlesource.com/platform/packages/modules/Virtualization/+/refs/heads/android15-release/docs/custom_vm.md)
- [arch guide](https://dev.to/besworks/official-linux-terminal-on-android-hkf#comment-2n13j)
- [nixos avf](https://github.com/nix-community/nixos-avf)
