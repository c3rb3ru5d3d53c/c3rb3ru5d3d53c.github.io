---
weight: 4
title: "Hunting Opaque Predicates with YARA"
description: "Hunting Opaque Predicates with YARA"
date: "2023-02-04"
draft: true
author: "c3rb3ru5d3d53c"
tags: ["YARA", "Opaque Predicates", "Malware", "Hunting"]
categories: ["Docs"]
lightgallery: true
---

## Introduction

Malware tends to obfuscate itself using many different techniques from opaque predicates, garbage code, control flow manipulation with the stack and more. These techniques definitely make analysis more challening for reverse engineers. However, from a detection and hunting standpoint to find interesting samples to reverse engineer we can leverage our knowlege of these techniques to hunt for obfuscated code. In our case today, we will be developing a YARA signature to hunt for one specific technique of opaque predicates, there are many variations and situations where this does not match and should only serve as a hunting signatures as more heuristic and programitic approaches for this are better for detection. With the limitations in mind, we must first understand what opaque predicates are.

> In computer programming, an opaque predicate is a predicate, an expression that evaluates to either "true" or "false", for which the outcome is known by the programmer a priori, but which, for a variety of reasons, still needs to be evaluated at run time. - [Wikipedia](https://en.wikipedia.org/wiki/Opaque_predicate)

As the quote from Wikipedia states, opaque predicates are conditional checks in programming where the outcome is always predetermined. To understand this concept better let's have a look at an example in C (Figure 1).

```c
// Compile: gcc -O0 op.c -o op
// Run    : ./op

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv){
	int a = 0;
	int b = 1;
	if (a != b){
		printf("foo\n");
	}
	printf("bar\n");
	return 0;
}
```
*Figure 1. Opaque Predicate in C*

In this case, `a` will never be equal to `b`, meaning, `foo` will always be printed to the console. Additionally, this should also be represented in the assembly code because no optimizations are performed by the compiler because of the argument `-O0` being passed to `gcc`. Analysis of this code can be challenging as basic blocks are created and these conditions can be nested making a mess in our disassemblers and decompilers.

Now that we have the basic concept understood in C, let's have a look at another example in assembly (Figure 2).

```asm
0:  b8 41 41 41 41          mov    eax,0x41414141
5:  bb 42 42 42 42          mov    ebx,0x42424242
a:  39 d8                   cmp    eax,ebx
c:  75 00                   jnz    e <test>
0000000e <test>:
e:  90                      nop
```
*Figure 2. Opaque Predicate in Assembly*

In this case, we have a combination of two `mov` instructions moving immutable values into registers, followed by a `cmp` instruction checking both the involved registers, and finally a conditional `jnz` instruction.

Before we can create a `yara` hunting signature, we need to create the wild carded hex string to match the bytes correctly. To accomplish this, we need to know about x86 instruction encoding for moving immutable values into registers (Table 1).

| Opcode | Mnemonic      | Description       |
| ------ | ------------- | ----------------- |
| B0+ rb | MOV r8,imm8   | Move imm8 to r8   |
| B8+ rw | MOV r16,imm16 | Move imm16 to r16 |
| B8+ rd | MOV r32,imm32 | Move imm32 to r32 |

*Table 1. Instruction Encoding for `mov reg,imm`* 

This means we can detect each `mov` instruction with the `yara` search pattern `b? ?? ?? ?? ??`. 

Next, we need to identify the `cmp` instruction, for this we can use the `yara` search pattern `39 ?? ??`. Finally, we use the instruction encodings for conditional jump instructions `(7?|0f ??|e3)`. A reference to instruction encoding for x86 conditional jumps can be found [here](http://unixwiz.net/techtips/x86-jumps.html).

With all these considerations we can make the `yara` signature in Figure 3.

```cpp
rule op {
    strings:
        $match = {b? ?? ?? ?? ?? b? ?? ?? ?? ?? 39 ?? (7?|0f ??|e3)}
    condition:
		all of them
}
```
*Figure 3. Opaque Predicate `yara` Signature*

So we can dust our hands off and say we are done right? 🤔

Wrong! 😲

