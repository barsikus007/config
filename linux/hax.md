# zlom

## scan.sh by XAKEP

```bash
#!/bin/bash
ports=$(nmap -p- --min-rate=500 $1 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
nmap -p$ports -A $1
```

## [Cloudflare bypass](https://github.com/FDX100/cloud-killer)

## [exploitdb](https://gitlab.com/exploit-database/exploitdb)

```bash
sudo git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
searchsploit -u
```
