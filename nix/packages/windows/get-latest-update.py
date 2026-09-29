#!/usr/bin/env python3
# ? fetch latest windows updates from microsoft catalog
import base64
import json
import re
import sys
import urllib.parse
import urllib.request


def query_catalog(search_term):
    url = f"https://www.catalog.update.microsoft.com/Search.aspx?q={urllib.parse.quote(search_term)}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    html = urllib.request.urlopen(req, timeout=15).read().decode("utf-8", errors="replace")
    return re.findall(r'goToDetails\("([a-f0-9\-]+)"\)[^>]*>\s*([^<]+)', html)


def get_download_info(uid, title):
    post_data = urllib.parse.urlencode(
        {"updateIDs": json.dumps([{"size": 0, "languages": "", "uidInfo": uid, "updateID": uid}])}
    ).encode("utf-8")
    dreq = urllib.request.Request(
        "https://www.catalog.update.microsoft.com/DownloadDialog.aspx",
        data=post_data,
        headers={"User-Agent": "Mozilla/5.0"},
    )
    dhtml = urllib.request.urlopen(dreq, timeout=15).read().decode("utf-8", errors="replace")
    urls = re.findall(r"files\[\d+\]\.url\s*=\s*['\"]([^'\"]+)['\"]", dhtml)
    if not urls:
        return None
    url = urls[0]
    filename = url.split("/")[-1]
    sha1_match = re.search(r"_([a-f0-9]{40})\.", filename)
    sri_hash = ""
    if sha1_match:
        sha1_bytes = bytes.fromhex(sha1_match.group(1))
        sri_hash = "sha1-" + base64.b64encode(sha1_bytes).decode("ascii")
    return {
        "title": title.strip(),
        "url": url,
        "filename": filename,
        "sri_hash": sri_hash,
    }


if len(sys.argv) > 1 and sys.argv[1] == "--dotnet-url":
    matches = query_catalog("Cumulative Update Windows 10 Version 21H2 x64 LTSB")
    dotnet_matches = [m for m in matches if ".NET" in m[1] and "4.8" in m[1] and "4.8.1" not in m[1]]
    if dotnet_matches:
        info = get_download_info(dotnet_matches[0][0], dotnet_matches[0][1])
        if info:
            print(info["url"])
            sys.exit(0)
    sys.exit(1)

matches = query_catalog("Cumulative Update Windows 10 Version 21H2 x64 LTSB")
if not matches:
    print("no updates found", file=sys.stderr)
    sys.exit(1)

os_matches = [m for m in matches if "Dynamic" not in m[1] and ".NET" not in m[1]]
dotnet_matches = [m for m in matches if ".NET" in m[1] and "4.8" in m[1] and "4.8.1" not in m[1]]

os_info = get_download_info(os_matches[0][0], os_matches[0][1]) if os_matches else None
dotnet_info = get_download_info(dotnet_matches[0][0], dotnet_matches[0][1]) if dotnet_matches else None

if os_info:
    print(f"OS LCU:   {os_info['title']}")
    print(f"URL:      {os_info['url']}")
    print(f"SRI:      {os_info['sri_hash']}\n")

if dotnet_info:
    print(f".NET LCU: {dotnet_info['title']}")
    print(f"URL:      {dotnet_info['url']}")
    print(f"SRI:      {dotnet_info['sri_hash']}\n")

print("Nix snippet:")
if os_info:
    name = os_info["filename"].split("_")[0] + ".msu"
    print("  cumulativeUpdate = fetchurl {")
    print(f'    name = "{name}";')
    print(f'    url = "{os_info["url"]}";')
    print(f'    hash = "{os_info["sri_hash"]}";')
    print("  };\n")

if dotnet_info:
    name = dotnet_info["filename"].split("_")[0] + ".msu"
    print("  cumulativeUpdateDotnet = fetchurl {")
    print(f'    name = "{name}";')
    print(f'    url = "{dotnet_info["url"]}";')
    print(f'    hash = "{dotnet_info["sri_hash"]}";')
    print("  };")
