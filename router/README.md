# AX3600 setup 
get ssh https://openwrt.org/inbox/toh/xiaomi/xiaomi_ax3600
custom owrt https://4pda.to/forum/index.php?s=&showtopic=983152&view=findpost&p=111379978
dualboot https://4pda.to/forum/index.php?s=&showtopic=983152&view=findpost&p=110312962

white IP https://4pda.to/forum/index.php?s=&showtopic=1013678&view=findpost&p=109028697
https://habr.com/ru/sandbox/99949/
## `/etc/hotplug.d/iface/26-grey`
```sh
#!/bin/sh
if [ "$ACTION" = "ifup" -a "$INTERFACE" = "wan" ]; then
    . /lib/functions/network.sh; network_get_ipaddr ip wan
    _ip=$(echo $ip | grep -v -E "(^100\.6[4-9]\.|^100\.[7-9][0-9]\.|^100\.1[0-1][0-9]\.|^100\.12[0-7]\.)")
    [ -z "$_ip" ] &&   echo "Reloading wan due grey IP - $ip" >> /tmp/log/ip.log && ifup wan
    [ ! -z "$_ip" ] && echo "White IP taken!           - $ip" >> /tmp/log/ip.log
fi
```