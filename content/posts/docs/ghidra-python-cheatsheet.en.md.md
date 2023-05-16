---
weight: 4
title: "Ghidra Python Scripting Cheatsheet"
description: "A Cheatsheet of Useful Ghidra Python Scripting Snippets"
date: "2023-02-04"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Cheatsheet", "Ghidra", "Reversing"]
categories: ["Docs"]
lightgallery: true
---

This is a cheatsheet I use for Ghidra scripting.

NOTE: Some of these functions use each other :smile:

## User Input
```python
askFile('Title', 'Okay').toString()
```

## Get Python Bytes from Address

```python
def get_bytes(address, size):
	return bytes(map(lambda b: b & 0xff, getBytes(address, size)))
```

## Get Section Bytes (Program Tree)

```python
def get_section_bytes(section_name):
	section = getMemoryBlock(section_name)
	return get_bytes(section.getStart(), section.getSize())
```

## Get Executable Path

```python
currentProgram.getExecutablePath()
```

## Get Program Start Address

```python
currentProgram.getMinAddress()
```

## Get Program End Address

```python
currentProgram.getMaxAddress()
```

## Comments

```python
from ghidra.program.model.listing import CodeUnit

cu = currentProgram.getListing().getCodeUnitAt(addr)
cu.getComment(CodeUnit.EOL_COMMENT)
cu.setComment(CodeUnit.EOL_COMMENT, "Comment text")

def set_comment_eol(address, text, debug=False):
    cu = currentProgram.getListing().getCodeUnitAt(address)
    if debug is False: cu.setComment(CodeUnit.EOL_COMMENT, text)
    if debug is True: print(str(address) + ' | ' + text)
```

## Bookmarks

```python
createBookmark(addr, 'category', 'description')
```

## Functions

```python
from ghidra.program.model.symbol import SourceType
fm = currentProgram.getFunctionManager()
f = fm.getFunctionAt(currentAddress)
f = fm.getFunctionContaining(currentAddress)
f.setName("test", SourceType.USER_DEFINED)

def get_xrefs(address: int):
    return [x.getFromAddress() for x in getReferencesTo(get_address(address))]
```

## Addresses

```python
def get_address(address: int):
	return currentProgram.getAddressFactory().getAddress(str(hex(address)))
address = get_address(0x400000)
next_address = address.add(5)
current_address = currentLocation.getAddress()
```

## Labels

```python
def get_label(address):
	result = currentProgram.getListing().getCodeUnitAt(address)
	if result is None: return None
	return result.getLabel()
```

## Listing

```python
def get_codeunit(address):
	return currentProgram.getListing().getCodeUnitAt(address)
codeunit = get_codeunit(address)
mnemonic = codeunit.getMnemonicString()
number_operands = codeunit.getNumOperands()
next_codeunit = codeunit.getNext()
prev_codeunit = codeunit.getPrev()
```

## Common Imports

```python
from pprint import pprint
from hexdump import hexdump
from ghidra.program.model.lang import OperandType
from ghidra.program.model.listing import CodeUnit
from ghidra.program.flatapi import FlatProgramAPI
```

## Load Pickled Object

```python
import pickle
data = pickle.load(open('example.pickle', 'rb'))
```

## Searching Patterns
```python
from ghidra.program.flatapi import FlatProgramAPI

def search_memory(string, max_results=128):
	fpi = FlatProgramAPI(getCurrentProgram())
	return fpi.findBytes(currentProgram.getMinAddress(), ''.join(['.' if '?' in x else f'\\x{x}' for x in string.split()]), max_results)

addresses = search_memory('55 8b ec 83 ec 20 8b 4? ?? 33')
for address in addresses: print(address)
```