---
weight: 4
title: "Linux TTS Accessibility with Festival"
description: "A guide to using festival TTS as an accessibility tool in Linux"
date: "2023-03-09"
draft: false
author: "c3rb3ru5d3d53c"
images: []
featuredImage: "images/ae87c0265df83ee84188f3c24245fa06d9fa1b1707ae51c890df772d82eead07.jpg"
tags: ["Festival", "TTS", "Accessibility"]
categories: ["Docs"]
lightgallery: true
---
## Introduction

Most Linux distributions do not come with a text-to-speech (TTS) engine installed by default. However, there are several open source TTS engines available for Linux that can be installed easily through the package manager.

I have dysgraphia, which is a neurological disorder that affects a person's ability to write. People with dysgraphia may struggle with writing legibly, organizing their thoughts on paper, and/or maintaining consistent spacing and sizing of letters and words.

In order to combat this mental limitation, I use TTS to read text more quickly and to proof read what I'm writing. Additionaly, treatment for dysgraphia can include accommodations such as using a computer. It's important for individuals with dysgraphia to receive support and accommodations to help them succeed in academic and professional settings.

The solution I found in this case is `festival`, which is a free and open-source text-to-speech (TTS) tool for Linux that allows users to generate artificial speech from written text. Festival is highly customizable and supports a range of voices, languages, and output formats. It can be used for a variety of applications, including voice interfaces, screen readers, and language learning tools.

## Installation

```bash
sudo apt install -y festival ffmpeg xdotool
sudo cp /etc/festival.scm ~/.festivalrc
```

## Version

In order to install the correct voices for `festival` TTS, you need to identify what version you have installed.

```bash
festival --version
```

Once you determine the version, you can download voices you need by changing the version at the end of the URL.

```text
http://festvox.org/packed/festival/2.5/
```

### Shortcut Script

This `bash` script, allows you to copy text then have `festival` read it back and also toggle it off when needed using a keyboard shortcut.

```bash
#!/usr/bin/env bash

if [ "$(pidof festival)" ]; then
	pkill festival;
	exit 0;
fi
xdotool key ctrl+c
xclip -o | festival --tts
```

```bash
sudo cp tts.sh /usr/local/bin/tts
sudo chmod +x /usr/local/bin/tts
```

Once completed, you can setup your shortcuts in your distribution like the following.

![shortcut](images/97a30b5bad97368f3b836f0dbec846df15706b662e1d8a0ad80549b457e1fdc3.png)

## Speed up Playback

When reading, I find it useful to speed up playback as it allows me to read at a faster pace. You can change the option for `atemo` to whatever works for you.

```lisp
(Parameter.set 'Audio_Required_Format 'aiff)
(Parameter.set 'Audio_Method 'Audio_Command)
(Parameter.set 'Audio_Command "ffplay -hide_banner -loglevel error -nodisp -autoexit -volume 100 -af 'atempo=1.8' $FILE")
```

### Set Default Voice

Finally, to set the default voice for `festival`, you can use the text below. Each voice that you have can be listed in the `repl` by doing `(voice.list)`. Each voice name, must be prefixed with `voice_`.

```lisp
(set! voice_default 'voice_cmu_us_slt_cg)
```