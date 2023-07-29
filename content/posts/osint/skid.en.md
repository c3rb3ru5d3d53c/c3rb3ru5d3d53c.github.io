---
weight: 4
title: "Skid OSINT Investigation"
date: 2023-07-28
draft: false
author: "c3rb3ru5d3d53c"
description: "A Skid OSINT Deep Dive"
images: []
tags: ["Skid", "Malware", "OSINT"]
categories: ["Malware"]
lightgallery: true
---

# Skid OSINT Investigation

On Going very WIP!

## Starting with AlexxModder

I received a Discord message from the user `AlexxModder` asking me to be a developer for their malware project. I was not inclined to participate but rather to analyze the code. So I stated `Send me the source code`, I then received the source code as `ELYSc2.zip` (Figure placeholder). 

![chat](images/189a2e3fa6824d4a6aeba05a29e07d3fffa692c8fa4d01318eb6b24cb70df2ec.png)
*Figure placeholder: `AlexModder` sending botnet source code.*

Next, we investigated the next persona, which was obtained by visiting the site `https[:]//elys.mysellix.io`.  Which is website managed by [Sellix](https://help.sellix.io/en/articles/4590166-what-is-sellix), which is an eCommerce platform.

![alexxmodder](images/666a2dbd04fbca014b9fe20d017866ee6712d42dccdd0fad4429975463fb9e40.png)

Once on this Sellix eCommerce site, we observed sales for `Anubis V7`, `DaVinci + HWID_GEN + installation`, `ELYS Figglet Wallet` and Windows license keys. Additionally, more social accounts were found linked at the bottom of the page (Figure placeholder).

![site](images/a452b00b64d60a1f64c33bd2b6daf0daa4c9cdab54965e51df91799218461725.gif)
*Figure placeholder. Sellix eCommerce site for Elys*

In the following subsections we look into each of these social sites.

### Facebook

On this Facebook [profile](https://www.facebook.com/people/Elys-Du-Gard-H%C3%A9rault/pfbid0228iczxJXSgn1yzvjyVoPdQ4sXZwjYmU1Ge3Zd84VV1mWWiQhvRFwjkJEkdyZYwFel/), there are post for IPTV with the posts being in French. Take note of the logo, which matches the Twitter account [PinkilyCash](https://twitter.com/PinkilyCash).

![iptv](images/54fd8dc7d5bff8497f8884713496d778b510241d5251fb1a7f932749d8ecd568.png)

### TikTok

For this account the alias [libelluleadmin](https://www.tiktok.com/@libelluleadmin) is used. On this profile there are many videos showcasing the tools being sold. From this we were able to find the GitHub Account [AeX03](https://github.com/AeX03), which will be covered here later (it's important).

### Discord

On the Discord [server](https://discord.com/invite/xpaxKBEx9t), we can see `AlexxModder` again with the role of `ELYS` and one developer with the username `CliffV2`, take note of the profile picture (Figure placeholder).

![developer](images/027705f58e9be518eddbc1fc8125edf529572f487cb4aab75ebb2605830a720e.png)
*Figure placeholder. Discord Server for `eLys | Support`*

In this case, it appears `AlexxModder` operates the Discord server.

At the time of writing, there were 26 online accounts and 271 members in the Discord server (Figure placeholder).

![discord](images/82772f426230e6c5a945892582a5b8624158db7764376f41947852acb98823bc.png)
*Figure placeholder. Discord Server User Count*

### Twitter


Looking that the Twitter account [PinkilyCash](https://twitter.com/PinkilyCash), we found a link to the site `https[:]//www.elysiane[.]eu`, which purports to be a cryptocurrency called ELYS Token (`0x90E24EB24B5e61748bAfA90B09c42F79e49ADeD6`) (Figure placeholder).

![twitter](images/e28a38dca8c9c4bcf05651240a4affdee91795ea6ff5802892917bae30994dd8.png)
*Figure placeholder. [PinkilyCash](https://twitter.com/PinkilyCash) Twitter Account for ELYS Token*

The logo on the Discord server, the Twitter account and Facebook account all point to the name ELYS.

Interestingly, further down the page on this website we find pricing the ELYS BOTNET, JOYCE and ELYS TV. All of which are likely malware asides from ELYS TV.

![market](images/31d652097a33931dfa3fcb5bf825eb6f9cb9f1c947c5fa28cf594f051713d2a4.png)
*Figure placeholder. ELYS Token Website Advertised Products*

The site describes the ELYS Token as follows...

> Elys Token is a token that will be needed to make payments on our website that will allow you to buy or rent goods such as a maid to share tv channels, projects being created etc...

The cryptocurrency token has a very minimal whitepaper, which can be found on [GitBooks](https://elyss-organization.gitbook.io/untitled/).

## Investigating AeX03 and the CameLys GitHub Organization

The profile contains a link to the same domain for ELYS Token and is also part of the `CameLys` GitHub organization, which was taken down during our live stream resulting in a 404 from GitHub. The GitHub organization was likely removed by `AeX03` as this account is the most involved in all the projects on GitHub (Figure placeholder).

![aex03](images/b229ceca1fafa7e168cd5655c3f8477a63957036355cfc084da9cecd260ab570.png)

*Figure placeholder. The User [AeX03](https://github.com/AeX03) Showing Link to `eLysiane[.]eu`*

In addition to this we found the account [cryptobuks](https://github.com/cryptobuks) on GitHub, which contains again more code pushed by [AeX03](https://github.com/AeX03), which is likely the start of the ELYS Token as commits on this repository end on January 4, 2023. Where as, the GitHub organization [CameLys](https://github.com/CameLys), which has the same `main.js` file was on May 18, 2023. Indicating that [AeX03](https://github.com/AeX03) moved the code from [cryptobuks](https://github.com/cryptobuks), over to the new organization likely within a 4 month period at some point.

![cryptobuks](images/a360c22772481a0d960376d5c71bd4331421b6c71a6e7888edb55682790bebf3.png)
*Figure placeholder. GitHub Repository for ELYS Token from [cryptobuks](https://github.com/cryptobuks) being worked on by [AeX03](https://github.com/AeX03)*

## Investigating AeX03 and leducax (Le Duc)



![aex03](images/8bec945143fb08ebd25a3236dbbeffddac59fef29490cd4ef59bb2bed1f28f92.png)

```text
origin	https://github.com/leducax/l-hash.git (fetch)
Author: AeX03 <133485038+leducax@users.noreply.github.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/FVL.git (fetch)
Author: AeX03 <133485038+leducax@users.noreply.github.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/VansRose.git (fetch)
Author: AeX03 <elyscorp@hotmail.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/VSX.git (fetch)
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	httpsAeX03 Persona://github.com/leducax/leducax.github.io.git (fetch)
Author: AeX03 <133485038+leducax@users.noreply.github.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/conversepy.git (fetch)
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/nalice-IA.git (fetch)
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/leducax/leducax.git (fetch)
Author: github-actions[bot] <41898282+github-actions[bot]@users.norepAeX03ly.github.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/CameLys/ELYSc2.git (fetch)
Author: AeX03 <103602164+AeX03@users.noreply.github.com>
Author: AeX03 <elyscorp@hotmail.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
origin	https://github.com/CameLys/ELYSc2.git (fetch)
Author: AeX03 <103602164+AeX03@users.noreply.github.com>
Author: AeX03 <elyscorp@hotmail.com>
Author: Le Duc <133485038+leducax@users.noreply.github.com>
---
```
*Figure placeholder. AeX03 Overlap in Git Logs for Le Duc*

## Technical Analysis

Placeholder

## Panel

![panel](images/b1848db9d40c3f0745945f51a68b962e449de22ed1428731983be6b2d30286c9.png)

Ongoing very WIP

# Indicators

| Type     | Indicator | Description         |
| -------- | --------- | ------------------- |
| Username | AeX03     | GitHub Username     |
| Username | CameLys   | GitHub Organization | 
