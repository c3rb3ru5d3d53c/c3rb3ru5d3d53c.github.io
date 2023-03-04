---
weight: 4
title: "Reverse Engineering CheatSheet"
description: "A reverse engineering cheat sheet of sorts"
date: "2022-06-24"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Cheatsheet"]
categories: ["Docs"]
lightgallery: true
---

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
## Linux TTS
```bash
flite --setf duration_stretch=0.5 -voice slt -t "Hello World!"
```