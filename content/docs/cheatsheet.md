---
title: CheatSheet
description: A cheat sheet of commands I use.
toc: true
authors: c3rb3ru5d3d53c
tags:
  - malware
  - analysis
  - cheatsheet
categories: malware
series:
date: '2022-06-24'
draft: false
---

| Description                    | Command                                                                                                    |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| sha256 folder                  | <pre>find . -maxdepth 1 -type f \| while read i; mv $i (sha256sum $i \| grep -Po '\^[a-f0-9]+'); end</pre> |
| download hashes from clipboard | <pre>xclip -o -s -c \| xargs -I {} echo "vt download {}" \| parallel -j 8 {}</pre>                         |
| binlex top 10 traits           | <pre>find samples/ -type f \| while read i; binlex -i $i \| jq -r 'trait' \| sort \| uniq; end \| sort \| uniq -c \| sort -rn \| head -10</pre>                                                                                            |

