---
weight: 4
title: "Reversing RedLine Stealer"
date: 2022-11-29T21:57:40+08:00
lastmod: 2020-01-01T16:45:40+08:00
draft: false
author: "c3rb3ru5d3d53c"
description: "Reversing Redline Stealer Pron Lure"
images: []
tags: ["RedLine", "Stealer"]
categories: ["Malware"]
lightgallery: true
---

## Situation

Muta from `SomeOrdinaryGamers` uploaded a video on *Redline Stealer* on Aug 14, 2022, which infected Martin Shkreli.

### Key Points
- *Redline Stealer* has the ability to communicate with multiple C2 hosts.
- *Redline Stealer* has the ability to present a message box to the user upon execution.
- *Redline Stealer* communicates with the C2 server using Simple Object Access Protocol (SOAP).
- *Redline Stealer* exits if it detects the infected machine is from a near Russian countries.
- *Redline Stealer* executes its modules in random order to potentially evade heuritic detection.

## Infection Chain

The infection chain starts with a download of `[BigTitsRoundAsses] 17.12.14 - Jazmyn [1080p].scr` from `pornleech[.]ch`, which creates three files in the `TEMP%` directory, `Che.mp3` (Autoit Interpreter), `Quella.mp3`, (BAT Script) and `Travolge.mp3` (AutoIT Script).

## Obfuscated BAT Script

Once extracted, the installer executes `cmd /c cmd < Quella.mp3 & ping -n 5 localhost`, which later creates `Mantenga.exe.pif`, which is an AutoIT interpreter.

PLACEHOLDER (FIGURE FOR DEOBFUSCATED THE BAT SCRIPT)

### Obfuscated AutoIT Script

Next, the AutoIT interpreter executes `i`.  Then the AutoIT script performs process hollowing, creates the process `jsc.exe` in suspended mode, hollows the process then injects the process with Redline Stealer.

PLACEHOLDER (ADD FIGURE FOR AU3 DEOBFUSCATOR)

Installer → Quella.mp3 (BAT) → Mantenga.exe.pif (Loader) → jsc.exe

Looks like they are doing process hollowing from the AutoIT script.

```text
CreateProcessW
NtWriteVirtualMemory
NtReadVirtualMemory
NtWriteVirtualMemory
NtProtectVirtualMemory
NtSetContextThread
NtResumeThread
NtUnmapViewOfSection
```

## Redline Stealer

[Redline Stealer](https://malpedia.caad.fkie.fraunhofer.de/details/win.redline_stealer) is an information stealing malware available for purchase on underground forums and sells standalone and as a subscription service. This section of the blog is a technical analysis of Redline Stealer and its capabilities.

### Language Check

Once executed, *Redline Stealer* checks the country of origin against Armenia, Azerbaijan, Belarus, Kazakhstan, Kyrgyzstan, Moldova, Tajikistan, Uzbekistan, Ukraine, and Russia. Next, if `TimeZoneInfo.Local.Id` contains any of the hard-coded disallowed countries or `CultureInfo.CurrentUICulture.EnglishName` is `null` the program calls `Environment.Exit`.

## String Decryption

To decrypt strings, *Redline Stealer* calls `StrinDecrypt.Read`, which base64-decodes the ciphertext, then performs a rotating XOR operation using the key user string (`#US`) `Kenners`.

```python
import base64

class StringDecrypt():
    @staticmethod
	def Read(ciphertext, key):
	    key = key.encode()
	    ciphertext = base64.b64decode(ciphertext)
	    plaintext = []
	    for i in range(0, len(ciphertext)):
	        plaintext.append(ciphertext[i] ^ key[i % len(key)])
	    plaintext = bytes(plaintext).decode('utf-8')
	    return base64.b64decode(plaintext).decode('utf-8')
```
*Figure 1. Redline Stealer String Decryption Routine in Python*

## User Message

If the field `Arguments.Message` is not an empty or a `null` string, it is decrypted by calling `StringDecrypt.Read` (Figure 1) and subsequently presented to the user in a message box. The execution of *Redline Stealer* is not halted during this process, as the message box is created using a new thread. This functionality in Redline Stealer allows operators to present messages to users, such as fake error messages and more.

### C2 Communication

*Redline Stealer* uses SOAP messaging protocol to communicate with the C2 server. This section is a technical analysis of how *Redline Stealer* communicates with its C2 server.

#### Establish Connection

To establish a connection with the C2 server, Redline Stealer creates a new class object of `ConnectionProvider`, which handles all C2 communication. Once created, *Redline Stealer* decrypts all C2 servers from `Arguments.IP` with `StringDecrypt.Read` (Figure 1). Next, *Redline Stealer* splits the result using the delimiter `|` to create an array of C2 hosts. Once *Redline Stealer* has decrypted its array of C2 hosts, *Redline Stealer* connects to `net.tcp://95.217.35[.]153:9678/` using SOAP protocol, the default for Windows Communication Foundation (WCF). Once the WCF `ChannelFactory` object is created, *Redline Stealer* sets the field `connector` as this object. Next, *Redline Stealer* sets the SOAP header name as `Authorization`, with the namespace `ns1`. If unable to connect to the first C2 address, in a loop, *Redline Stealer* sleeps by calling `Thread.Sleep` for 5 seconds before attempting the next C2 address in the C2 hosts array. This means Redline Stealer can contain multiple C2 address, increasing the probability one of the C2 address will be operational.

#### Get Settings

*Redline Stealer* creates the data contract class `SettingsStruct`, which contains data members. These data members are the settings *Redline Stealer* uses during its execution, which are obtained from the C2 server (Table 1).

| Type             | Name               | Description                               |
| ---------------- | ------------------ | ----------------------------------------- |
| bool             | Id1                | Unknown                                   |
| bool             | FileSearch         | Enable File Stealing Module               |
| bool             | Filezilla          | Enable Filezilla Module                   |
| bool             | Wallets            | Enable Wallet Stealing Module             |
| bool             | GetImageBase       | Enable Collection of Image Base           |
| bool             | ScanFiles          | Enable Scanning Files                     |
| bool             | VPN                | Enable Stealing VPN Credentials           |
| bool             | GameLaunchers      | Enable Stealing Game Launcher Information |
| list\<string\>   | FileSearchPatterns | File Search Pattern List                  |
| list\<string\>   | BrowserPaths       | Browser Path List                         |
| list\<string\>   | Id12               | Unknown                                   |
| list\<Entity17\> | AdditionalWallets  | Additional Wallets to Steal               | 
*Table 1. Redline Stealer Settings Data Contract Members*

#### Result Data Contract

*Redline Stealer* stores results of data collected from the victim machine in a data contract, which is created with the data member `ID`. The value of this data member is `100822` and originates from `Arguments.ID`, which is decrypted using `StringDecrypt.Read`.

PLACEHOLDER (What does this `ID` do?)

### Modules

*Redline Stealer* creates the class `EntityResolver`, which is created from the template method `ItemBase.Extract`. If `Arguments.Version` is not equal to `1`, an instance of `FullInfoSender` is returned, otherwise an instance of `PartsSender` is returned. In this case, `Arguments.Version` is set `1`, which returns an instance of `PartsSender`. 

Next, in a while loop, *Redline Stealer* executes the `Invoker` method from the `PartsSender` instance. Once executed, Redline Stealer initializes the data contract `SystemInfo`, which will later be populated with data stolen from the infected machine. Next, if the directory `%AppData%\Yandex\YaAddon` does not exist, Redline Stealer creates the directory. Otherwise, if the directory creation time is less than three months old, the directory is deleted and created again. Once completed, *Redline Stealer* executes modules in the module groups `First` and `Main` in random order (Table 2).

| Module Group | Module Name          | Description                         |
| ------------ | -------------------- | ----------------------------------- |
| First        | GetUsername          | Gets Username                       |
| First        | GetMonitorProperites | Gets Monitor Properties             |
| First        | GetOS                | Gets OS Name                        |
| First        | GetAssemblyLocation  | Obtains Executing Assembly Location |
| First        | GetUUID              | Created a UUID                      |
| First        | GetTimezone          | Gets Timezone                       |
| Main         | GetHardwareInfo      | Get Hardware Information            |
| Main         | GetBrowsers          | Steal Browser Data                  |
| Main         | GetListOfPrograms    | Get List of Programs                |
| Main         | GetAVs               | Get List of Security Products       |
| Main         | GetProcesses         | Get List of Processes               |
| Main         | GetLanguages         | Get Languages                       |
| Main         | GetTelegramProfiles  | Enumerate Telegram Profiles         | 
| Main         | MaybeMozillaStealer  | Maybe Steal Data From Mozilla       |
| Main         | GetFileSearch        | Get File Search Results             |
| Main         | StealWallets         | Steal Crypto Wallets                |
| Main         | StealDiscord         | Steal Discord Tokens                |
| Main         | GetGameLaunchers     | Steal Game Launcher Data            |
| Main         | GetVPN               | Steal VPN Credentials               |
| Main         | GetImageBase         | Get Executing Assembly Image Base   |
*Table 2. Redline Stealer Module Groups*

The modules in the group `First` only collect data, which is later sent to the C2 server, whereas the modules in the group `Main` send data within each module. This could mean the modules in the `First` group are working on being ported to the `Main` group.

#### GetAVs (defenders)

This module performs the WMI queries provided in Figure 2, against `ROOT\\SecurityCenter` and `ROOT\\SecurityCenter2`.

```text
SELECT * FROM AntivirusProduct
SELECT * FROM AntiSpyWareProduct
SELECT * FROM FirewallProduct
```
*Figure 2. Redline Stealer WMI Queries*

Once completed, the results are appended to a list, which is sent to the C2 server.

#### GetHardwareInfo (hardwares)

This module performs the WMI query `SELECT * FROM Win32_Processor`, collecting the `Name` and `NumberOfCores` of the infected endpoint. Additionally, another WMI query is performed on `root\\CIMV2`, with the query `SELECT * FROM Win32_VideoController`, collecting the `AdaperRAM` and `Name`. The results from both of these queries are stored in a template list. Once completed, Redline Stealer appends another structure with the hard-coded key as `Total of RAM` with the value `4095.46 MB or 4294397952`. Next, the data is sent to the C2 server.

#### ListOfPrograms (softwares)

This module opens the sub registry key `HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall`. Next, the sub key names are iterated for their `DisplayName` and associated `DisplayVersion`. Once these values are obtained, they are added to a list of strings in the format described in Figure 3.

```text
DisplayName0 [DisplayVersion0]
DisplayName1 [Displayversion1]
DisplayName3 [Displayversion3]
...
```
Figure 3. Redline Stealer Program List Module Structure

Next, the results are sent to the C2 server.

#### GetBrowsers

If the infected endpoint is 32-bit Redline Stealer opens the registry key `SOFTWARE\\Clients\\StartMenuInternet`, otherwise it reads `SOFTWARE\\WOW6432Node\\Clients\\StartMenuInternet`. Once opened, Redline Stealer iterates the sub key names, collecting the `BrowserName` and the `FileVersion` from `shell\\open\\command` (default file association). If the `FileVersion` cannot be obtained, Redline Stealer sets `BrowserVersion` to `Unknown Version`. Next, the resulting data contract structure is appended to the list template and sent to the C2 server.

#### ListProcesses (processes)

Redline Stealer performs the WMI query `SELECT * FROM Win32_Processes Where SessionId='<current-processes-session-id>'`. Once completed, the results are parsed for `ProcessId`, `Name`, and `CommandLine`. The structure of the data collected is provided in Figure 4.

```text
ID: <ProcessId>, Name: <Name>, CommandLine: <CommandLine>
```
*Figure 4. Redline Stealer Process List Structure*

#### Languages

To collect languages, *Redline Stealer* iterates `InputLanguages.InstalledInputLanguages`, appending the language `EnglishName` to a list of strings. Once the results have been collected, they are sent to the C2 server.

#### GetTelegramProfiles

To scan for profiles, *Redline Stealer* calls the `FileScanning.Search` method, which takes an array of scanners classes to process. In this case, the only scanner class that is passed is `TelegramScanner`. Each scanner has two methods, `Find` to locate interesting directories, and `Collect` to obtain information. 

To collect a list of Telegram profiles, *Redline Stealer* first checks if the process `Telegram.exe` is currently running, if this is the case, Redline Stealer adds the directory where `Telegram.exe` exists and the folder `\tdata`, which contains Telegram session data to a list of the type `ScannerArgsStruct`, which is a data contract consisting of the members `Count`, `Directory`, `SearchPattern`, and `Recursive` (Table 3.).

| Type   | Name          | Description             |
| ------ | ------------- | ----------------------- |
| string | Count         | Number of Items Found   | 
| string | Directory     | Directory to Search     |
| string | SearchPattern | Search Pattern String   |
| bool   | Recursive     | Recursive Search or Not |
*Table 3. Redline Stealer ScannerArgs Data Contract*

Next, if *Redline Stealer* is unable to find a currently running process of `Telegram.exe`, *Redline Stealer* will add the directory `%AppData%\Telegram Desktop\tdata\` to the list of `ScannerArgsStruct` data contracts.

*Redline Stealer* in this process considers any filenames with a length of 16 in the Telegram `\tdata` folder a potential profile.



#### StealWallets

```text
ffnbelfdoeiohenkjibnmadjiehjhajb|YoroiWallet
ibnejdfjmmkpcnlpebklmnkoeoihofec|Tronlink
jbdaocneiiinmjbjlgalhcelgbejmnid|NiftyWallet
nkbihfbeogaeaoehlefnkodbefgpgknn|Metamask
afbcbjpbpfadlkmhmclhkeeodmamcflc|MathWallet
hnfanknocfeofbddgcijnmhnfnkdnaad|Coinbase
fhbohimaelbohpjbbldcngcnapndodjp|BinanceChain
odbfpeeihdkbihmopkbjmoonfanlbfcl|BraveWallet
hpglfhgfnhbgpjdenjgmdgoeiappafln|GuardaWallet
blnieiiffboillknjnepogjhkgnoapac|EqualWallet
cjelfplplebdjjenllpjcblmjkfcffne|JaxxxLiberty
fihkakfobkmkjojpchpfgcmhfjnmnfpi|BitAppWallet
kncchdigobghenbbaddojjnnaogfppfj|iWallet
amkmjjmmflddogmhpjloimipbofnfjih|Wombat
fhilaheimglignddkjgofkcbgekhenbh|AtomicWallet
nlbmnnijcnlegkjjpcfjclmcfggfefdm|MewCx
nanjmdknhkinifnkgdcggcfnhdaammmj|GuildWallet
nkddgncdjgjfcddamfgcmfnlhccnimig|SaturnWallet
fnjhmkhhmkbjkkabndcnnogagogbneec|RoninWallet
aiifbnbfobpmeekipheeijimdpnlpgpp|TerraStation
fnnegphlobjdpkhecapkijjdkgcjhkib|HarmonyWallet
aeachknmefphepccionboohckonoeemg|Coin98Wallet
cgeeodpfagjceefieflmdfphplkenlfk|TonCrystal
pdadjkfkgcafgbceimcpbkalnfnepbnk|KardiaChain
bfnaelmomeimhlpmgjnjophhpkkoljpa|Phantom
fhilaheimglignddkjgofkcbgekhenbh|Oxygen
mgffkfbidihjpoaomajlbgchddlicgpn|PaliWallet
aodkkagnadcbobfpggfnjeongemjbjca|BoltX
kpfopkelmapcoipemfendmdcghnegimn|LiqualityWallet
hmeobnfnfcmdkdcmlblgagmfpfboieaf|XdefiWallet
lpfcbjknijpeeillifnkikgncikgfhdo|NamiWallet
dngmlblcodfobpdpecaadgfbcggfjfnm|MaiarDeFiWallet
ffnbelfdoeiohenkjibnmadjiehjhajb|YoroiWallet
ibnejdfjmmkpcnlpebklmnkoeoihofec|Tronlink
jbdaocneiiinmjbjlgalhcelgbejmnid|NiftyWallet
nkbihfbeogaeaoehlefnkodbefgpgknn|Metamask
afbcbjpbpfadlkmhmclhkeeodmamcflc|MathWallet
hnfanknocfeofbddgcijnmhnfnkdnaad|Coinbase
fhbohimaelbohpjbbldcngcnapndodjp|BinanceChain
odbfpeeihdkbihmopkbjmoonfanlbfcl|BraveWallet
hpglfhgfnhbgpjdenjgmdgoeiappafln|GuardaWallet
blnieiiffboillknjnepogjhkgnoapac|EqualWallet
cjelfplplebdjjenllpjcblmjkfcffne|JaxxxLiberty
fihkakfobkmkjojpchpfgcmhfjnmnfpi|BitAppWallet
kncchdigobghenbbaddojjnnaogfppfj|iWallet
amkmjjmmflddogmhpjloimipbofnfjih|Wombat
fhilaheimglignddkjgofkcbgekhenbh|AtomicWallet
nlbmnnijcnlegkjjpcfjclmcfggfefdm|MewCx
nanjmdknhkinifnkgdcggcfnhdaammmj|GuildWallet
nkddgncdjgjfcddamfgcmfnlhccnimig|SaturnWallet
fnjhmkhhmkbjkkabndcnnogagogbneec|RoninWallet
aiifbnbfobpmeekipheeijimdpnlpgpp|TerraStation
fnnegphlobjdpkhecapkijjdkgcjhkib|HarmonyWallet
aeachknmefphepccionboohckonoeemg|Coin98Wallet
cgeeodpfagjceefieflmdfphplkenlfk|TonCrystal
pdadjkfkgcafgbceimcpbkalnfnepbnk|KardiaChain
bfnaelmomeimhlpmgjnjophhpkkoljpa|Phantom
fhilaheimglignddkjgofkcbgekhenbh|Oxygen
mgffkfbidihjpoaomajlbgchddlicgpn|PaliWallet
aodkkagnadcbobfpggfnjeongemjbjca|BoltX
kpfopkelmapcoipemfendmdcghnegimn|LiqualityWallet
hmeobnfnfcmdkdcmlblgagmfpfboieaf|XdefiWallet
lpfcbjknijpeeillifnkikgncikgfhdo|NamiWallet
dngmlblcodfobpdpecaadgfbcggfjfnm|MaiarDeFiWallet
bhghoamapcdpbohphigoooaddinpkbai|Authenticator
ookjlbkiijinhpmnjffcofjonbfbgaoc|TempleWallet
```

#### Exfiltration

Placeholder

#### Remote Tasks

Placeholder

##### Get Tasks

##### Execute Tasks

Placeholder

## Configuration Extraction

Placeholder

## Indicators of Compromise

| Type   | Indicator                                                        | Description                    |
| ------ | ---------------------------------------------------------------- | ------------------------------ |
| SHA256 | 532c47de5bdd433bea776290d27a741b09a1d5c5f2089e54eced922514a60799 | Redline Stealer Installer File |
| SHA256 | 3e8d604a5d545189c35d810845b3e2208e3c56081507b949ecb17a6bbd4decb1 | Messed Up PE File (Che.mp3)    |
| SHA256 | ac5f7f01c7ca6663810df33bfa62012368b6c17b7520943c094308f30adac766 | BAT Script (Quella.mp3)        |
| SHA256 | 454b381e98f092cab4e82f21a790c5ccd4dbd006e44925bcabd6c9289ea6700e | AutoIT Script  (Travolge.mp3)  |
| SHA256 | 3e26723394ade92f8163b5643960189cb07358b0f96529a477d37176d68aa0a0 | AutoIT Interpreter             |
| SHA256 | 454b381e98f092cab4e82f21a790c5ccd4dbd006e44925bcabd6c9289ea6700e | AutoIT Script                  |
| SHA256 | 676ae4b1ef05ee0ec754a970cce61a5f8d3093989a58c33087a3a5dca06364aa | Redline Stealer (Unpacked)     |
| IPv4   | 95.217.35[.]153                                                    | Redline Stealer C2                               |

## Detection

This section contains signatures to detect Redline Stealer and its infection chain.

### YARA

Placeholder

### Suricata

Placeholder

## Mitre Attack TTPs

| ID          | Tactic      | Technique   |
| ----------- | ----------- | ----------- |
| placeholder | placeholder | placeholder | 