---
weight: 4
title: "Reversing Additional Lockbit 3.0 API Hashing"
description: "Reversing an additional Lockbit 3.0 API hashing."
date: "2022-07-13"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Lockbit", "Ransomware"]
categories: ["Malware"]
lightgallery: true
---

I was watching [@herrcore's](https://twitter.com/herrcore) OALabs stream on Lockbit 3.0. After he wrote a utility to decrypt additional data from the ransomware, he noticed one of the buffers was a Portable Executable (PE) file. It had an interesting API hashing routine, we would be reversing for the next stream.

I decided to have a closer look. 😄

## Analysis

This is an interesting sample, I have not mapped out its full functionality yet.

However, I was able to get a decent amount of reversing done, which should give us more of an insight.

### TLS Callback

Thread Local Storage (TLS) provides unique data for each thread, so the process can access it using a global index. It is possible with this functionality to store pointers to a TLS callback function in a PE header. The callback function pointers will then be executed before the actual entry point by Windows.

Once executed, it will call the *tls_callback_0* function before the *entry* function.

The TLS callback has two functions, *InitAPIs* and *InitFuncTables* as seen below.

```cpp
void tls_callback_0(PVOID DllHandle,DWORD dwReason) {
  if (dwReason == 1) {
    InitAPIs();
    InitFuncTables();
  }
  return;
}
```

Now we will discuss the API hashing in detail.

### API Hashing

The main API hashing and resolving function will call *InitAPIs* to resolve a table of function pointers to be used later for each module. The first argument is a pointer to a DWORD hash table. This hash table starts with one DWORD hash to describe the DLL then a series of hashes to describe the functions for the module, ending with the DWORD *0x1a33acd5*, which acts as a delimiter denoting the end of the hash table for a given module.

```cpp
typedef struct _FUNC_HASHES_N {
	DWORD dwModule;    // Module Hash
	DWORD dwHash[n];   // n = # function hashes
	DWORD dwDelimiter; // 0x1a33acd5
} FUNC_HASHES_N, *PFUNC_HASHES_N;
```

Where *N* is the struct table number and *n* is the number of function hashes.

The function *ResolveModule* is responsible for resolving one module at a time based on the function hash table pointer, which is passed as the first parameter. The second parameter is the size of the function table it creates dynamically.

```cpp
void InitAPIs(void) {
  ntdll = (PFUNC_PTRS_0)ResolveModule((uint **)&FUNC_HASHES_NTDLL,92);
  kernel32 = (PFUNC_PTRS_1)ResolveModule((uint **)&FUNC_HASHES_KERNEL32,32);
  shell32 = (PFUNC_PTRS_2)ResolveModule((uint **)&FUNC_HASHES_SHELL32,4);
  shlwapi = (PFUNC_PTRS_3)ResolveModule((uint **)&FUNC_HASHES_SHLWAPI,12);
  wtsapi32 = (PFUNC_PTRS_4)ResolveModule((uint **)&FUNC_HASHES_WTSAPI32,4);
  userenv = (PFUNC_PTRS_5)ResolveModule((uint **)&FUNC_HASHES_USERENV,12);
  advapi32 = (PFUNC_PTRS_6)ResolveModule((uint **)&FUNC_HASHES_ADVAPI32,48);
  netapi32 = (PFUNC_PTRS_7)ResolveModule((uint **)&FUNC_HASHES_NETAPI32,8);
  return;
}
```

In order to allocate memory for the function pointer tables, it will resolve the API hash *0x90ad8283*, which is the function *ntdll.NtAllocateVirtualMemory*. It will allocate *RegionSize* based on how many functions are in the table. It will calculate the size by performing the bit shift operation *iFunctionCount << 2*. This will ensure that each function pointer will be allocated 0x4 bytes of memory with *PAGE_EXECUTE_READWRITE* permissions.

```cpp
pFunctionTable = (PVOID *)NULL;
BaseAddress0 = (PVOID *)NULL;
RegionSize = iFuncCount << 2;
(*(code *)::ntdll.ZwAllocateVirtualMemory)
		  ((HANDLE)0xffffffff,&BaseAddress0,0,&RegionSize,0x103000,PAGE_EXECUTE_READWRITE);
if (((BaseAddress0 != (PVOID *)NULL) &&
	((*(code *)::ntdll.ZwAllocateVirtualMemory)
			   ((HANDLE)0xffffffff,&pFunctionTable,0,(PSIZE_T)&iFuncCount,0x103000,
				PAGE_READWRITE), ValidBaseAddress1 = pFunctionTable,
	pFuncTableIter = BaseAddress0, pFunctionTable != (PVOID *)NULL)) &&
   (iResult = IsDLLExistByHash((uint)*upHashTable), iResult != 0)) {
```

It will then check the first hash to see if the DLL exists on the infected system by enumerating *C:\\Windows\\System32\\\*.dll*. In order to enumerate the directories, it resolves the following API hashes first.

```cpp
(iResult = IsDLLExistByHash((uint)*upHashTable), iResult != 0)
```

The function IsDLLExistByHash, will check 

| Hash         | Function                  |
| ------------ | ------------------------- |
| *0xaae0cefb* | kernel32.FindFirstFileExW |
| *0x63a1bff9* | kernel32.FindNextFileW    |
| *0xe0979a4*  | kernel32.FindClose        |
#### Module Hashing
The Dynamic Link Library (DLL) names are referenced by hash.

The function we are interested is as follows.

```x86asm
0:  push   ebp
1:  mov    ebp,esp
3:  push   edx
4:  push   esi
5:  mov    edx,DWORD PTR [ebp+0xc]
8:  mov    eax,0x1e4c448d
d:  xor    eax,0x29009fe6
12: not    eax
14: xor    edx,eax
16: mov    esi,DWORD PTR [ebp+0x8]
19: xor    eax,eax
1b: lods   ax,WORD PTR ds:[esi]
1d: cmp    ax,0x41
21: jb     0x2d
23: cmp    ax,0x5a
27: ja     0x2d
29: or     ax,0x20
2d: add    dh,0x7a
30: sub    dh,0x7a
33: ror    edx,0xd
36: add    edx,eax
38: test   eax,eax
3a: jne    0x19
3c: mov    eax,edx
3e: pop    esi
3f: pop    edx
40: pop    ebp
41: ret    0x8
```

Interestingly, the following operations can be simplified for *eax*.

```x86asm
8:  mov    eax,0x1e4c448d
d:  xor    eax,0x29009fe6
12: not    eax
```

The value of *eax* here is static and can be represented by *0xc8b32494* instead. It is important to note that in the binary there is a section where it performs a comparison but also modified the returned hash by performing the following.

```x86asm
not    eax  
xor    eax,0x29009fe6  
cmp    eax,DWORD PTR [ebp+0x8]
```

This can be represented as *(~eax &0xffffffff) ^ 0x29009fe6*.

Now we can now recreate the functionality in Python.

```python
def ror(n,rotations=1,width=32):
    return (2**width-1)&(n>>rotations|n<<(width-rotations))

def hashstr(string, xmod):
    # Function 004010ec
    string = bytes(string, 'ascii') + b'\x00'
    result = 0xc8b32494 ^ xmod
    for c in string:
        if c > 0x41 and c < 0x5a: c = c | 0x20
        result = ror(result, rotations=0x0d, width=32)
        result += c
        if c == 0x00: break
    return result

result = (~hashstr('kernel32.dll', 0x00000000) & 0xffffffff) ^ 0x29009fe6

print(hex(result))
```

Definitely an interesting hashing algorithm in how it has some redundant operations.

#### Function Hashing
The function name hashing takes into account the hash of the module as well.

```python
def hash_fnc(string, mod_hash):
    # 004010b8
    string = bytes(string, 'ascii') + b'\x00'
    result = 0xc8b32494 ^ mod_hash
    for c in string:
        result = ror(result, rotations=0x0d, width=32)
        result += c
        if c == 0x00: break
    return result
```

This function reuses most of the same principles from the DLL hashing, except for performing an if statement on a range of characters.

#### Finalizing Hashes

Throughout the code, it will finalize hashes with a *not* operation and an *XOR* operation against the constant *0x29009fe6*.

```python
def hash_fin(fnc_hash):
    # Finalize Hash
    return (~fnc_hash & 0xffffffff) ^ 0x29009fe6
```

We can even write a single function now to get the API hash based on the module name and exported function.

```python
def hash_all(module, function, xmod):
    # Hash Module and Function
    return hash_fin(hash_fnc(function, hash_mod(module, xmod)))
```

Once the hash is finalized, it can be added to our hash table.

#### Hash Table
The next step is for us to create a hash table, so we can easily resolve all the APIs.

```python
import sys
import pefile
import pickle
from glob import glob
from pprint import pprint
from os.path import basename

# def ror(n,rotations=1,width=32)
# def hash_mod(string, xmod)
# def hash_fnc(string, mod_hash)
# def hash_fin(fnc_hash)
# def hash_all(module, function, xmod)

def get_exports(dll):
    pe = pefile.PE(dll)
    d = [pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXPORT"]]
    pe.parse_data_directories(directories=d)
    exports = []
    for export in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        if export.name is not None: exports.append(export.name.decode())
    return list(set(exports))

dlls = glob('C:\Windows\System32\*.dll')

hashmap = {}

for dll in dlls:
    try:
        print('[-] ' + dll)
        exports = get_exports(dll)
        for export in exports:
            fnc_hash = hash_all(basename(dll), export, 0x00000000)
            fnc_name = basename(dll)[:-4] + '.' + export
            hashmap[fnc_hash] = fnc_name
            hashmap[hash_fin(hash_mod(basename(dll), 0x00000000))] = basename(dll)
        print('[+] ' + dll)
    except KeyboardInterrupt:
        pickle.dump(hashmap, open('hashmap.pickle', 'wb'), protocol=pickle.HIGHEST_PROTOCOL)
        sys.exit(0)
    except:
        pass

pickle.dump(hashmap, open('hashmap.pickle', 'wb'), protocol=pickle.HIGHEST_PROTOCOL)
```

This takes some time to run, but at the end we get a pickled Python dictionary or hash table we can use to resolve all the APIs we need. We can load the hash table by doing the following.

```python
>> import pickle
>> h = pickle.load(open('hashmap.pickle', 'rb'))
>> h[0x2A9FB8E1]
'kernel32.dll'
>> h[0xAAE0CEFB]
'kernel32.FindFirstFileExW'
```

Here are some example API hashes for *kernel32*.

```text
00401a64 e1 b8 9f 2a   DWORD    2A9FB8E1h            kernel32.dll
00401a68 fb ce e0 aa   DWORD    AAE0CEFBh            kernel32.FindFirstFileExW
00401a6c f9 bf a1 63   DWORD    63A1BFF9h            kernel32.FindNextFileW
00401a70 a4 79 09 0e   DWORD    E0979A4h             kernel32.FindClose
00401a74 c3 05 cc c7   DWORD    C7CC05C3h            kernel32.ExitProcess
00401a78 66 ae 26 8e   DWORD    8E26AE66h            kernel32.CopyFileW
00401a7c 22 22 47 d9   DWORD    D9472222h            kernel32.GetShortPathNameW
00401a80 9b f8 33 6d   DWORD    6D33F89Bh            kernel32.GetComputerNameW
00401a84 d5 5c 7f 3f   DWORD    3F7F5CD5h            kernel32.CreateNamedPipeW
00401a88 d5 ac 33 1a   DWORD    1A33ACD5h            HASH_DELIM
```

### String Decryption
The cipher text for the strings are stored in the code section as double words that are moved to the data section. The address to the cipher text is pushed to the stack along with the number of double word iterations needed to perform the decryption. This makes the cipher text more challenging to extract. However, I was at least able to recreate the routine in Python, with a few tricks using checking the modulus of the data buffer length.

```python
def decrypt_str(data):
    # 00401010
    data = bytes.fromhex(data)
    result = b''
    if (len(data) % 4)!= 0: return None
    for i in range(0, len(data), 4):
        dword = struct.unpack('<I', data[i:i+4])[0]
        dword = (~(dword ^ 0x29009fe6) & 0xffffffff)
        result += dword.to_bytes(4, byteorder='little')
    return result.decode('utf-16')
```

With this knowledge, we can now decrypt the following cipher text.

```python
>> result = decrypt(b'\x45\x60\xD5\xD6\x37\x60\x9B\xD6\x75\x60\x93\xD6')
>> print(result)
\*.dll
```

## TLS Main Function
In order to obscure control flow, it will store function pointers to an encrypted VTable structure.

The pointer has a *not* operation performed on it, then it is *ror* by a random single byte. This is stored in the following data structure.

```cpp
typedef struct _ENCRYPTED_VTABLE_ENTRY {
	DWORD EncryptedPointer; // VTable Encrypted Pointer
	USHORT Reserved0;       // Unknown
	BYTE RorSeed;           // RorSeed Key
	USHORT Reserved1;       // Unknown
	USHORT Reserved2;       // Unknown
} ENCRYPTED_VTABLE_ENTRY, *PENCRYPTED_VTABLE_ENTRY;
```

The encryption of just the pointer can be described as follows.

```python
def ror(n,rotations=1,width=32):
    return (2**width-1)&(n>>rotations|n<<(width-rotations))

def encrypt_ptr(data, key):
    return ror((~data & 0xffffffff), rotations=key, width=
```

With this knowledge, we can perform the opposite operation *rol* to decrypt pointers.

```python
def rol(n,rotations=1,width=32):
    return (2**width-1)&(n<<rotations|n>>(width-rotations))

def decrypt_ptr(data, key):
    return rol((~data & 0xffffffff), rotations=key, width=32)
```

I will continue to update this.

## Downloads
- [Hash Map](assets/hashmap.zip)
- [Python Tool](https://gist.github.com/c3rb3ru5d3d53c/4f2c984d81ef64e5f133e37726619c64)