---
title: Twitch Streaming
description: Twitch Streaming Resources
toc: true
authors: c3rb3ru5d3d53c
tags:
  - twitch
  - cheatsheet
categories: streaming
series:
date: '2022-11-23'
draft: false
---

Twitch Live Stream Chat

```text
https://dashboard.twitch.tv/popout/u/<username>/stream-manager/chat?uuid=2
```

```css
/*
Twitch chat browsersource CSS for OBS
Just set the URL as https://www.twitch.tv/%%TWITCHCHANNEL%%/chat?popout=true
And paste this entire file into the CSS box
Original by twitch.tv/starvingpoet modified by github.com/Bluscream
General Settings
*/
body {
    color: #FFFFFF!important;
    margin: 0 auto!important;
    overflow: hidden!important;
    text-shadow:
        -1px -1px 1px #000000,
        -1px  1px 1px #000000,
         1px -1px 1px #000000,
         1px  1px 1px #000000!important;
}

html, body,
.room-selector, .room-selector__header,
.twilight-minimal-root, .tw-root--theme-light,
.popout-chat-page, .chat-room, .tw-c-background-alt,
.chat-container, .ember-chat-container {
    background: rgba(0,0,0,0)!important;
    background-color: rgba(0,0,0,0.4)!important;
}

/*
Badge Removal
To remove additional badge types - moderator, bits, etc - just make a copy of the one of the following badge selectors and replace the word inbetween the quotes with the hover text
img.badge[alt="Broadcaster"],
img.badge[alt="Moderator"],
img.badge[alt="Subscriber"],*/
img.badge[alt="Twitch Prime"],
img.badge[alt="Turbo"],
img.badge[alt="Verified"]
{
    display: none!important;
}

/**
 * Remove the header section
 */
.ember-chat .chat-room {
    top: 0!important;
}

.ember-chat .chat-header, .room-selector__header {
    display: none!important;
}

.ember-chat .chat-messages .chat-line.admin {
    display: none!important;
}

/**
 * Remove the footer section
 */

.ember-chat .chat-room, .chat-input {
    display: none!important;
    bottom: -112px!important;
}

/**
 * Font Size & Color
 */
.ember-chat .chat-messages .chat-line {
    font-size: 24px!important;
    line-height: 20px!important;
}

.chat-container, .ember-chat-container {
    color: #FFFFFF!important;
}

/**
 * Make the chat text white (optional) [thanks to @iggy12345]
**/
.chat-line__message {
    color: #FFFFFF;
}

/**
 * https://gist.github.com/Bluscream/83083d0cd483b3563b5e2b4d55519003#gistcomment-3770724
**/
html {
    font-size: 100% !important;
}

/**
 * Small fix to remove the "Stream Chat" Header and the Gift/Cheer Leaderboard header
 * https://gist.github.com/Bluscream/83083d0cd483b3563b5e2b4d55519003#gistcomment-3803252
**/
.stream-chat-header, .channel-leaderboard {
  display: none !important;
}
```