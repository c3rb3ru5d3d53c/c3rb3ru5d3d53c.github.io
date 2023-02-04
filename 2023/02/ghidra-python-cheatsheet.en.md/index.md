# Ghidra Python Scripting Cheatsheet


This is a cheatsheet I use for Ghidra scripting.

NOTE: Some of these functions use each other :smile:

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
