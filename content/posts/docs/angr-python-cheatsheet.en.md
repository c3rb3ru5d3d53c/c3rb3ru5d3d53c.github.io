---
weight: 4
title: "ANGR Python Scripting Cheatsheet"
description: "A Cheatsheet of Useful ANGR Python Scripting Snippets"
date: "2023-06-26"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Cheatsheet", "ANGR", "Reversing", "Python"]
categories: ["Docs"]
lightgallery: true
---

# ANGR Python CheatSheet


## Starting a Project
```python
import angr, claripy
# Create the Project
p = angr.Project("stealer.exe")
# Terminate Project Execution
p.terminate_execution()
```

## Creating Project Hooks
```python
# Hook an Address
skip_bytes = 4
@p.hook(0xdeadbeef, length=skip_bytes)
def hook_state(s):
    # Change State Here
# Check If Address Hooked (Bool)
p.is_hooked(0xdeadbeef)
```

## Creating a State
```python
start_address = 0xdeadbeef
end_address   = 0xbeefdead
avoid_address = 0xcafef00d
# Create the Initial Execution State
s = p.factory.blank_state(addr=start_address)
# Setting Registers and Memory
s.regs.ebp = s.regs.esp
s.regs.ebx = 0xdeadbeef
s.mem[0x1000].uint32_t = s.regs.eax
# Setting State Options
s.options.add(angr.options.LAZY_SOLVES)
# Use unicorn engine to execute symbolically when data is concrete
s.options.add(angr.options.UNICORN)
# Make the value of memory read from an uninitialized address zero instead of an unconstrained symbol
s.options.add(angr.options.ZERO_FILL_UNCONSTRAINED_MEMORY)
```

## Creating Constraints
```python
# Add Constraints to the State
s.add_constraints(s.regs.eax == 0xdeadbeef)
# Access or Print Constraints
s.constraints
```

## Starting your Simulation
```python
# Create the Simulation Manager with the Initial Execution State
sm = p.factory.simulation_manager(s)
# Symboliclly Execute to Find Addresses and Avoiding Others
sm.explore(find=(end_address,), avoid=(avoid_address))
```

## Reading Memory
```python
sm.found[0].solver.eval(sm.found[0].memory.load(sm.found[0].regs.eax, 32), cast_to=bytes)
```



