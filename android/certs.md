# [how to install certificates](README.md)

```bash
mitmproxy -p 8081 --set block_global=false

adb shell settings put global http_proxy 10.0.2.2:8080
adb shell settings put global http_proxy 228.13.37.123:8081

adb shell settings delete global http_proxy
adb shell settings delete global global_http_proxy_host
adb shell settings delete global global_http_proxy_port

# https://nibarius.github.io/learning-frida/cheat-sheet/
cert_name=http-toolkit-ca-certificate.crt
openssl x509 -inform DER -in $cert_name -out ${FILE%%.*}-conv.crt
# convert certs
cert_name=http-toolkit-ca-certificate-conv.crt
hashed_name=`openssl x509 -inform der -subject_hash_old -in $cert_name | head -1` && cp $cert_name $hashed_name.0
# or
hashed_name=`openssl x509 -inform PEM -subject_hash_old -in $cert_name | head -1` && cp $cert_name $hashed_name.0

# change certs dir to your own
cd ~/certs
adb push 871cb74d.0 /data/local/tmp
adb push 269953fb.0 /data/local/tmp
adb push c8750f0d.0 /data/local/tmp
adb shell -t su

mkdir -m 700 /data/local/certs
cp /system/etc/security/cacerts/* /data/local/certs
mount -t tmpfs tmpfs /system/etc/security/cacerts
mv /data/local/certs/* /system/etc/security/cacerts/
mv /data/local/tmp/*.0 /system/etc/security/cacerts/
chown root:root /system/etc/security/cacerts/*
chmod 644 /system/etc/security/cacerts/*
chcon u:object_r:system_file:s0 /system/etc/security/cacerts/*
# then reboot
```

## or use HTTP Toolkit with <https://github.com/NVISOsecurity/MagiskTrustUserCerts>

```bash
frida -U --codeshare akabe1/frida-multiple-unpinning -f com.punicapp.whoosh

wsl
unxz frida-server-16.0.10-android-arm64.xz
mv frida-server-16.0.10-android-arm64 frida-server
exit

adb push frida-server /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"
```
