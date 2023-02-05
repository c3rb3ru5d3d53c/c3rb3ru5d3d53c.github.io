---
weight: 4
title: "Hunting Opaque Predicates with YARA"
description: "Hunting Opaque Predicates with YARA"
date: "2023-02-05"
draft: false
author: "c3rb3ru5d3d53c"
tags: ["YARA", "Opaque Predicates", "Malware", "Hunting"]
categories: ["Docs"]
featuredImage: "images/4c3144fc208245413dfd03ae14a961cd59e006439fa932f663c9b9af4ef7caac.png"
lightgallery: true
---

## Introduction

Malware tends to obfuscate itself using many different techniques from opaque predicates, garbage code, control flow manipulation with the stack and more. These techniques definitely make analysis more challening for reverse engineers. However, from a detection and hunting standpoint to find interesting samples to reverse engineer we can leverage our knowlege of these techniques to hunt for obfuscated code. In our case today, we will be developing a `yara` signature to hunt for one specific technique of opaque predicates, there are many variations and situations where this does not match and should only serve as a hunting signatures as more heuristic and programitic approaches for this are better for detection. With the limitations in mind, we must first understand what opaque predicates are.

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

We can confirm this by performing the following operations.

```bash
gcc -O0 op.c -o op
objdump -Mintel --disassemble=main op
# 115c:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
# 1163:	c7 45 fc 01 00 00 00 	mov    DWORD PTR [rbp-0x4],0x1
# 116a:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
# 116d:	3b 45 fc             	cmp    eax,DWORD PTR [rbp-0x4]
# 1170:	74 0f                	je     1181 <main+0x38>
```

Now that we have the basic concept understood in C, let's have a look at simpler example in assembly (Figure 2).

```asm
0:  b8 41 41 41 41          mov    eax,0x41414141
5:  bb 42 42 42 42          mov    ebx,0x42424242
a:  39 d8                   cmp    eax,ebx
c:  75 00                   jnz    e <test>
0000000e <test>:
e:  90                      nop
```
*Figure 2. Opaque Predicate in Assembly*

In this case, we have a combination of two `mov` instructions moving 32-bit immutable values into 32-bit registers, followed by a `cmp` instruction checking both the involved registers, and finally a conditional `jnz` instruction.

## Signature Development

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

We need to verify the registers in from the `mov` instructions with the immutable values are used in the `cmp` instruction. Otherwise, there would be no context for the `cmp` instruction, as `yara` does not care at this point what registers are part of the compare only that it is simply a `cmp` instruction. To accomplish this we need to add logic to the `condition`.

First we must iterate all the matches of our `$match` string. To accomplish this, we can use a `for` loop in our `condition` based on the number of matches (`#match`) (Figure 4).

```cpp
rule op {
    strings:
        $match = {b? ?? ?? ?? ?? b? ?? ?? ?? ?? 39 ?? (7?|0f ??|e3)}
    condition:
        for any i in (0..#match):(
			// Additional Logic Here
		)
}
```
*Figure 4 Loop Checking Matches for `match`*

Next, using the `for` loop we can get each opcode we ae interested in using `uint8()`, address of matches `@match` with bitwise operations to extract and compare the registers in the encoded bytes.

In this case, the first two bits of the `mov` opcodes are the mod/rm bits, and the last three bits indicate what register is being used.

| 0   | 1   | 3   | 3   | 4   | 5   | 6   | 7   |
| --- | --- | --- | --- | --- | --- | --- | --- |
| MOD | MOD | REG | REG | REG | R/M | R/M | R/M | 

*Table 2. Mod R/M Byte Encoding*

| REG Value | 8   | 16  | 32  |
| --------- | --- | --- | --- |
| 000       | al  | ax  | eax |
| 001       | cl  | cx  | ecx |
| 010       | dl  | dx  | edx |
| 011       | bl  | bx  | ebx |
| 100       | ah  | sp  | esp |
| 101       | ch  | bp  | ebp |
| 110       | dh  | si  | esi |
| 111       | bh  | di  | edi | 

*Table 3. Register Encoding*

Now that we have the encodings, we know the first `mov` instruction involves `eax`, so and the byte is `0xb8`, which in binary is `10 111 000` indicating the last three bits are the values we are interested in. We can single these bits out using a simple mask of `00 000 111` , which is equivelent to  `0x7`. Thus, `0xb8 & 0x7` will collect the value representing `eax`. This method will also work for our second `mov` instruction mathematicly decoding our second register of `ebx`.

Next, we need to decode the registers from the `cmp` instruction. The operands of the `cmp` instruction are encoded as `0xd8`, which in binary is represented by `11 011 000`.  To get the first 3 bits, we first need to shift the bits right by 3, then perform masking to avoid trailing bits. This can be performed with the operation `0xd8 >> 3 & 0x7`, which results in `011` or `ebx`. For the next operand we can simply perform the masking operation `0xd7 & 0x7`, which results in `000` or `eax`.

Now that we have the bitwise operations to decode the respective operands, we can implement them in our `condition` (Figure 5).

```cpp
rule op {
    strings:
        $match = {b? ?? ?? ?? ?? b? ?? ?? ?? ?? 39 ?? (7?|0f ??|e3)}
    condition:
        for any i in (0..#match):(
            (
                uint8(@match[i]) & 0x7 == uint8(@match[i]+11) & 0x7 and
                uint8(@match[i]+5) & 0x7 == uint8(@match[i]+11) >> 3 & 0x7
            )
        )
}
```

*Figure 5. Opaque Predicate `yara` Signature*

That was exhausting 😫, surely we are done right? 🤔

Wrong! 😲

We need to additionally check for the operands in reverse order, because the register options can swap positions. However, we can just add an `or` to our `condition` to make this work (Figure 6).

```cpp
rule op {
    strings:
        $match = {b? ?? ?? ?? ?? b? ?? ?? ?? ?? 39 ?? (7?|0f ??|e3)}
    condition:
        for any i in (0..#match):(
            (
                uint8(@match[i]) & 0x7 == uint8(@match[i]+11) & 0x7 and
                uint8(@match[i]+5) & 0x7 == uint8(@match[i]+11) >> 3 & 0x7
            ) or
            (
                uint8(@match[i]) & 0x7 == uint8(@match[i]+11) >> 3 & 0x7 and
                uint8(@match[i]+5) & 0x7 == uint8(@match[i]+11) & 0x7
            )
        )
}
```
*Figure 6. Opaque Predicate `yara` Signature*

Next, we can reduce the potential for false positives by scanning only executable sections in an executable. This can be applied to any executable format. However, for the sake of simplicity we will focus on the PE file format using the `pe` module in `yara`. To accomplish this, we iterate over each section checking of the characteristics has the `pe.SECTION_MEM_EXECUTE` flag and that the address of the matched bytes is with the section offsets. We also should check to be sure it is a 32-bit executable, as decoding instructions on different architecures would be pointless and yield more false positives.Once completed, we have a signature we can use for hunting provided in Figure 7.

```cpp
import "pe"

rule op {
    meta:
        author      = "@c3rb3ru5d3d53c"
        description = "Potential 32-bit Immutable Opaque Predicates"
        tlp         = "white"
    strings:
        $match = {b? ?? ?? ?? ?? b? ?? ?? ?? ?? 39 ?? (7?|0f ??|e3)}
    condition:
        uint16(0) == 0x5a4d and
        uint32(uint32(0x3c)) == 0x00004550 and
        pe.is_32bit() and
        for any i in (0..#match):(
            for any j in (0..pe.number_of_sections):(
                pe.sections[j].characteristics & pe.SECTION_MEM_EXECUTE and
                @match[i] >= pe.sections[j].raw_data_offset and
                @match[i] < pe.sections[j].raw_data_offset + pe.sections[j].raw_data_size - 15
            ) and
            (
                uint8(@match[i]) >> 3 == 0x17 and
                uint8(@match[i]+5) >> 3 == 0x17
            ) and
            (
                (
                    uint8(@match[i]) & 0x7 == uint8(@match[i]+11) & 0x7 and
                    uint8(@match[i]+5) & 0x7 == uint8(@match[i]+11) >> 3 & 0x7
                ) or
                (
                    uint8(@match[i]) & 0x7 == uint8(@match[i]+11) >> 3 & 0x7 and
                    uint8(@match[i]+5) & 0x7 == uint8(@match[i]+11) & 0x7
                )
            )
        )
}
```
*FIgure 7. Immutable 32-bit Opaque Predicate `yara`  Signature for PE Files*

## Limitations

Because x86 is turring complete, we are limited by the halting problem.

> In computability theory, the halting problem is the problem of determining, from a description of an arbitrary computer program and an input, whether the program will finish running, or continue to run forever. - [Wikipedia](https://en.wikipedia.org/wiki/Halting_problem)

This means that given any program with an input we cannot prove if the program will finish running or continue to execute forever. More in the context of our application, given any input, we cannot detect every possible combination of opaque predicates. It is undecidable for which no one algorithm has been proven to solve.

The more reliable way to detect opaque prediques would be to use heuristic and programmatic solutions to disassemble and inspect the executable code sections. However, this is also limited by encrypted code containing opaque predicates and of course edge cases and an infinite number of combinations that can be used.

In addition to these issue, when performing scans with this signature `yara` prints the message `slowing down scanning`, which means that while the signature maybe great for hunting, it is not great from a performance vs. detection standpoint. False positives could also be an issue, as `yara` scanning does not perform proper disassembly of the application and relies on pattern matching of bytes, which can cause false positives due to alignment issues.

We also didn't account for 8, and 16 bit immutable values being moved into registers. However, with the knowledge you have now, I hope you will be able to make some interesting opaque prediquate hunting `yara` signatures of your own.

## Conclusion

Knowing the limitations of the halting problem and slow scanning when detecting opaque prediques with `yara`; our opaque predique `yara` signature can still be used to hunt for interesting obfuscated samples. Additionally, we can use this example as a way to create more opaque predique hunting `yara` signatures. At the end of the day, hunting and detection is a cat and mouse game for which we do not have a mathematical solution for to be completely safe. Those who win, are those who detect the most, and that is something we can quantify.

## References
- https://yara.readthedocs.io/en/stable/modules/pe.html
- http://www.c-jump.com/CIS77/CPU/x86/X77_0060_mod_reg_r_m_byte.htm
- https://c9x.me/x86/html/file_module_x86_id_176.html
- http://unixwiz.net/techtips/x86-jumps.html
- https://en.wikipedia.org/wiki/Opaque_predicate
- https://en.wikipedia.org/wiki/Halting_problem
- https://hal.science/hal-02559585