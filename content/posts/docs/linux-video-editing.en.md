---
weight: 4
title: "Video Editing in Linux"
description: "A guide for Video Editing in Linux"
date: "2022-06-23"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Video", "Editing"]
categories: ["Docs"]
lightgallery: true
---

Video editing in Linux has always been a hot topic in the community. It also has been discussed by a lot of Linux content creators. I have been using Linux for the past 10 years as my operating system for everything I do. With this has come challenges, of course years ago it was virtually impossible.

The landscape has shifted for Linux content creators. You really no longer need to purchase Davanchi Studio. The best new player on the block I'd recommend is Blender.

This is as simple as doing the following.
```bash
sudo snap install blender
sudo apt update
sudo apt-add-repository ppa:obsproject/obs-studio
sudo apt install audacity ffmpeg obs-studio
```

Once installed, lauch Blender and click on the Video Editing view for a new project.

## OBS Studio
I use OBS Studio to do my screen recording and voice recording.

To add a screen to capture just click the + button under sources, then select screen capture and the monitor you wish to share. Once this is completed, click the gear on Mic/Aux and Filters. I personally use the following filters in order.

- Noise Suppression
- Noise Gate
- Compressor
- Limiter
- Compressor

This will ensure the noise from your mic is acceptable, also it ensures your voice will be nice and loud so people can hear you properly

## Audacity
Once I finish recording in OBS Studio, I'll take the video and convert it to a mp3 using ffmpeg.

```bash
ffmpeg -i video.mkv video.mp3
```

I'll then peform the following filters in order.

- Compressor
- Limiter
- Compressor

During these steps you will be able to ensure the waveform is at it's peak loudness.

## Blender Editing Tips
I'll then import the video into my Blender video template (just a Blender video project containing my intro and other overlays), which contains my intro.

Once imported, I will remove the audio and replace it with the edited audio from audacity.

Navigating Blender as opposed to other video sequence editors can be quite different at first. It only took me a couple days to get used to the new controls compared to Kdenlive.

### Sequencer
| Action     | ShortCut                    |
| ---------- | --------------------------- |
| zoom       | mouse wheel up/down         |
| up/down    | shift + mouse wheel up/down |
| left/right | ctrl + mouse wheel up/down  |
| pan        | mouse wheel down and move   |
| cut clip   | the 'k' key                 |

You can resize clips by selecting the handle at the end or beginning of them, then drag using the 'g' key.

### Audio
To display the audio simply, select the audio then check *Display Waveform*.

### Rendering
Blender is a little different, to ensure you render from beginning to end you need to specify the ending frame at the bottom right. Though this may seem inconvient it is actually very helpful as it gives you total control.

To render the video, simply go to the printer icon in the top right, then under output change select where you want the file to go and the file format to be ffmpeg using the MPEG-4 container.

Once you have set the render window and the output file and format you can click Render then Render Animation and it will begin.

You will then notice a progress bar at the bottom indicating how far along your render is.

## Conclusion
I'll continue to update this guide as I refine my editing process. 🥰
