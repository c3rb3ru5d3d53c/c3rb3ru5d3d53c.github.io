---
weight: 4
title: "What is a DLL?"
description: "A guide to what a DLL is."
date: "2022-07-20"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["DLL", "PE", "Executable", "Library"]
categories: ["Docs"]
lightgallery: true
---

## Introduction

Hey everybody, it's cerberus and welcome to malware hell. Today we are going to do a whiteboard session on what a DLL is and why it is important to malware reverse engineering and analysis.

Dynamic-link library (DLL) is Microsoft's implementation of the shared library concept in the Microsoft Windows and OS/2 operating systems. These libraries usually have the file extension DLL, OCX (for libraries containing ActiveX controls), or DRV (for legacy system drivers).

- Describe PE File Format
- Explain RVAs
- Explain Dynamic Linking
- Demonstrate DLL usage

## Dynamic Linking

> Dynamic linking means that the code for some external routines is located and loaded when the program is first run. When you compile a program that uses shared libraries, the shared libraries are dynamically linked to your program by default.

Benefits:
- Save Storage Space
- Decrease Code Reuse

## Relative Virtual Addresses (RVAs)

Relative Virtual Address or RVA (here afterward) is the difference between two Virtual Addresses (VA) and represents the highest one. Virtual Address is the original address in the memory whereas Relative Virtual Address (RVA) is the relative address with respect to the ImageBase. ImageBase here means the base address where the executable file is first loaded into the memory.

We can calculate RVA with the help of the following formula:  
**RVA = VA – ImageBase**

Have a look at the example below for more clarification:

An application is loaded into the memory having a Base Address at 0x400000 and the VA is at 0x401000. So the RVA is calculated as:

**Virtual Address** = 0x00401000  
**ImageBase** = 0x00400000  
**RVA** = 0x00001000

```cpp
 typedef struct _IMAGE_EXPORT_DIRECTORY {  
	public UInt32 Characteristics;  
	public UInt32 TimeDateStamp;  
	public UInt16 MajorVersion;  
	public UInt16 MinorVersion;  
	public UInt32 Name;  
	public UInt32 Base;  
	public UInt32 NumberOfFunctions;  
	public UInt32 NumberOfNames;  
	public UInt32 AddressOfFunctions;     // RVA from base of image  (array of function addrs)
	public UInt32 AddressOfNames;         // RVA from base of image  (array of names)
	public UInt32 AddressOfNameOrdinals;  // RVA from base of image  (array of ordinals)
} IMAGE_EXPORT_DIRECTORY, *PIMAGE_EXPORT_DIRECTORY;
```

## Execution
- DLLMain
- Exported Functions
- regsvr32.exe
- rundll32.exe
- DLL Search Order (side loading)

## Analysis Tips
- Execution Context (which exported function was executed, what program executed it)
	- DllRegisterServer
	- DllUnregisterServer
- Consider the DLLMain function
