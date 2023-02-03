# Reverse Engineering CheatSheet


## SHA256 Files in Folder
```bash
find . -maxdepth 1 -type f | while read i; mv $i (sha256sum $i | grep -Po '^[a-f0-9]+'); end
```
## Download Hashes from Clipboard
```bash
xclip -o -s -c | xargs -I {} echo "vt download {}" | parallel -j 8 {}
```
## Binlex Top 10 Traits
```bash
find samples/ -type f | while read i; binlex -i $i | jq -r 'trait' | sort | uniq; end | sort | uniq -c | sort -rn | head -10
```
## Capture PCAP
```bash
tshark -i lo -F libpcap -w (date +"%Y-%m-%d").pcap
```

