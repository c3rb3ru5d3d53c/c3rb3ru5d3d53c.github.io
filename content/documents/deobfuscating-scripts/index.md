---
title: Deobfuscating Scripts
description: A guide to deobfuscation of scripts for malware analysts.
toc: true
authors: c3rb3ru5d3d53c
tags:
  - malware
  - analysis
  - laboratory
  - lab
  - deobfuscation
  - scripting
categories: malware
date: '2022-07-09'
draft: false
---

I reached out on Twitter asking for suggestions on new topics to cover.

One of these topics was on deobfuscation of scripts. This is a great topic as this skill can generally be learned by anyone who understands writing code or scripts. I'll cover more advanced topics as I move forward with these guides.

![deobfuscation](images/0.jpg)

*NOTE: This guide does not cover all aspects of deobfuscation. However, once you have finished reading and practicing the concepts in this guide, you will be able to build some of your own techniques to better expand your skills.*

## Prerequisites

In order to begin learning about deobfuscation, we must first understand what obfuscation is.

> Obfuscation - The action of making something obscure, unclear, or unintelligible.

In malware analysis and reverse engineering, deobfuscation is the exact opposite. It is to make something clear and intelligible.

The other knowledge required to understand obfuscation and deobfuscation of scripts, is to understand the scripting language the malware you are working on is obfuscated with. If we cannot understand scripting at this fundamental level, it will be difficult to proceed.


### Scripting Languages
Each operating system will typically have its own set of scripting languages that are popular to automate tasks. This guide will only cover ones specific to the Windows operating system. However, more scripting languages and tips maybe added later.

> A scripting language or script language is a programming language for a runtime system that automates the execution of tasks that would otherwise be performed individually by a human operator. Scripting languages are usually interpreted at runtime rather than compiled. - [Wikipedia](https://en.wikipedia.org/wiki/Scripting_language)

### Component Object Model (COM)
In the Windows operating system, we cannot talk about scripting until we discuss the Component Object Model (COM) interface. 

> COM is a platform-independent, distributed, object-oriented system for creating binary software components that can interact. COM is the foundation technology for Microsoft's OLE (compound documents) and ActiveX (Internet-enabled components) technologies. - [Microsoft](https://docs.microsoft.com/en-us/windows/win32/com/component-object-model--com--portal)

To get a list of COM Objects, we can use the following [PowerShell](https://en.wikipedia.org/wiki/PowerShell) script.

```powershell
function Get-ComObjects {
	# Get an Object Array of COM Object names and GUIDs
	$output = @();
	Get-ChildItem -Path 'REGISTRY::HKey_Classes_Root\clsid\*\progid' | foreach {
		if ($_.name -match "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}"){
			$output += @{GUID = $matches[0]; COMObject = $_.GetValue('')};
		}
	}
	return $output;
 }
```

With this function, we can print all objects.

```powershell
Get-ComObjects | foreach {
	$_ | Format-Table
}
```

We can also query by the object GUID or the name of the COM object.

```powershell
Get-ComObjects | foreach {
	if ($_.COMObject -match "^Scripting"){
		$message = "{0},{1}" -f $_.GUID, $_.COMObject;
		Write-Host $message;
	}
}
```

The documentation and references for COM is sparse on MSDN, which can be a barrier for beginners.

The following is a list of common tools we use to enumerate COM objects for malware analysis.

- [OLEViewDotNET](https://github.com/tyranid/oleviewdotnet)
- [OLEView](https://www.japheth.de/Download/COMView.zip)

Once we have the COM names, we can use PowerShell to list the methods available to us.

```powershell
New-Object -ComObject "Scripting.FileSystemObject" | Get-Member
   TypeName: System.__ComObject#{2a0b9d10-4b87-11d3-a97a-00104b365c9f}

Name                MemberType Definition
----                ---------- ----------
BuildPath           Method     string BuildPath (string, string)
CopyFile            Method     void CopyFile (string, string, bool)
CopyFolder          Method     void CopyFolder (string, string, bool)
CreateFolder        Method     IFolder CreateFolder (string)
CreateTextFile      Method     ITextStream CreateTextFile (string, bool, bool)
DeleteFile          Method     void DeleteFile (string, bool)
DeleteFolder        Method     void DeleteFolder (string, bool)
DriveExists         Method     bool DriveExists (string)
FileExists          Method     bool FileExists (string)
FolderExists        Method     bool FolderExists (string)
GetAbsolutePathName Method     string GetAbsolutePathName (string)
GetBaseName         Method     string GetBaseName (string)
GetDrive            Method     IDrive GetDrive (string)
GetDriveName        Method     string GetDriveName (string)
GetExtensionName    Method     string GetExtensionName (string)
GetFile             Method     IFile GetFile (string)
GetFileName         Method     string GetFileName (string)
GetFileVersion      Method     string GetFileVersion (string)
GetFolder           Method     IFolder GetFolder (string)
GetParentFolderName Method     string GetParentFolderName (string)
GetSpecialFolder    Method     IFolder GetSpecialFolder (SpecialFolderConst)
GetStandardStream   Method     ITextStream GetStandardStream (StandardStreamTypes, bool)
GetTempName         Method     string GetTempName ()
MoveFile            Method     void MoveFile (string, string)
MoveFolder          Method     void MoveFolder (string, string)
OpenTextFile        Method     ITextStream OpenTextFile (string, IOMode, bool, Tristate)
Drives              Property   IDriveCollection Drives () {get}
```

What is great about the COM interface descriptions in PowerShell using *Get-Member*, we can see the types of arguments these methods expect.

## Common Techniques
In general, there are techniques that are used all throughout obfuscation of scripts. These can apply to almost any scripting language, and we should be aware of them.

### Code Evaluation
Functions that can be called to directly evaluate code are an excellent tool for malware authors. An example of this can be as follows.

```js
var code = "alert('Hello World');";
eval(code);
```

This can be done with decoding and decryption to hide the true intent of the code.

Evaluation of code is one of the first things I look for when attempting to deobfuscate a script.

We can deobfuscate this script by performing the following.

```js
var code = "alert('Hello World');";
console.log(code);
```

We simply changed the *eval* function to *console.log* to print out the code instead of executing it.

Again, one of the first things we typically look for.

### Comments
To add variation and to slow malware analysts down, malware authors will sometimes insert comments all throughout their scripts. This can make the task of deobfuscation annoying if you do not remove the comments.

### Garbage Code
When deobfuscating scripts, we will almost always do our best to ensure that the code that we are looking at is referenced or run at all. It is not uncommon for the code authors to create a large amount of useless code. Again, their job is too slow you down.

### Decoding and Decryption

To store obfuscated code, it is common for the authors to store code in an encrypted or encoded state. Executing the code to perform the decoding or decryption for us is usually the preferred method.

Some common encoding and encryption techniques are as follows.

- [Base64](https://en.wikipedia.org/wiki/Base64)
- [XOR](https://en.wikipedia.org/wiki/XOR_cipher)
- [Hex](https://en.wikipedia.org/wiki/Hexadecimal)
- [RC4](https://en.wikipedia.org/wiki/RC4)
- [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem))
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)

Of these, you should be able to visually recognize Base64, XOR and Hex.

There are of course many more. However, these should be enough to get you started.

### Concatenation
Another technique malware authors like to use is concatenation. This is usually applied to strings in order to make them difficult to read.  An example can be seen below.

```js
var message = "H" + "e" + "l" + "l" + "o";
console.log(message);
```

Depending on the scripting language the sample you are analyzing is, you will want to understand string concatenation for that specific language.

### Additional Stages
There are cases where the malware author will decide to split their obfuscated scripts into multiple stages. This usually includes downloading additional obfuscated scripts or payloads from the internet. These kinds of payloads have been observed being hosted on Discord, Google Drive, Pastebin, Dropbox, GitHub, GitLab and more. Anywhere that users can upload content under their control on the internet, this is possible.

### Upper and Lower Case
Microsoft has decided that case is not important in PowerShell as well as other scripting languages for their operating system. This introduces additional complexity, as we can do the following.

```powershell
wRiTe-HoSt "Hello World!";
```

In general, this helps malware authors evade detection signatures and decrease readability.

### Escape Characters
In PowerShell, methods or functions can be obfuscated with backticks.

```powershell
function e`X`a`M`p`L`e {
	Write-Host "Hello World!";
}
 e`X`a`M`p`L`e
```

Since they act as escape characters, it does not change the functionality at all.

However, it does change how tools inspecting the script statically look at them.

## Scripting Languages
These are some of the most common scripting languages malware authors use. However, there will always be more. If a scripting language exists, there is probably an obfuscated malicious script waiting to be analyzed.

### JScript
One scripting language malware authors like to take advantage of is Microsoft's JScript, not to be confused with JavaScript. JScript is Microsoft's implementation of the JavaScript engine using the Windows programming interface. Typically, to interact with this programming interface, we use Window's Component Object Model (COM).

In JScript, access to these objects is created using the following code.

```js
var obj = new ActiveXObject("Scripting.FileSystemObject");
```

With this object, we can write to a file by doing the following.

```js
var fobj = obj.CreateTextFile("hello.txt", true);
fobj.WriteLine("Hello World");
fobj.Close();
```

Further documentation on this COM object and additional methods can be found [here](https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object).

For direct evaluation of code, you will want to look out for the *eval* function.

### VBScript

VBScript is another scripting language for Windows, based on Visual Basic and also generally reliant on Window's COM interface. VBScript is defined as follows.

> VBScript is an Active Scripting language developed by Microsoft that is modeled on Visual Basic. It allows Microsoft Windows system administrators to generate powerful tools for managing computers with error handling, subroutines, and other advanced programming constructs. - [Wikipedia](https://en.wikipedia.org/wiki/VBScript)

Now that we have a basic understanding of VBScript, let's perform the same operation as we did with JScript.

```vbscript
Set obj = CreateObject("Scripting.FileSystemObject")
Set fobj = fs.CreateTextFile("c:\testfile.txt", True)
fobj.WriteLine("This is a test.")
fobj.Close
```

For direct evaluation, look out for *[ExecuteGlobal](https://www.vbsedit.com/html/25ebfa26-d3b9-4f82-b3c9-a8568a389dbc.asp)*

### PowerShell
PowerShell is a scripting language and shell included in the Windows operating system by Microsoft.

> PowerShell is a task automation and configuration management program from Microsoft, consisting of a command-line shell and the associated scripting language. - [Wikipedia](https://en.wikipedia.org/wiki/PowerShell)

It is still possible to access COM objects as discussed earlier in this guide. However, it is often not necessary with PowerShell due to the other built-in commands and access to the .NET interpreter.

When deobfuscating PowerShell, look out for *IEX* and *Invoke-Expression*, as these can be used to directly evaluate code.

```powershell
$code = "Write-Host 'Hello World!';";
Invoke-Expression $code;
```

As with the other direct evaluations, we can simply replace it with something to print to the console, like *Write-Host*.

```powershell
$code = "Write-Host 'Hello World!';";
Write-Host $code;
```

## Conclusion
Obfuscation can be a time-consuming task, for myself I think of it like a game of Sudoku. There is enjoyment in creating orderly code and uncovering secrets. When I need a break from reverse engineering, I'll take a task to deobfuscate a script, it always rekindles my joy of this field.