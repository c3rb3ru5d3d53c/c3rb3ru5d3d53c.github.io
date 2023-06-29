# ANGR Python Scripting Cheatsheet


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
# Create Blank State
s = p.factory.blank_state(addr=start_address)
# Create State for Executing a Function
s = p.factory.call_state(addr=start_address)
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
# Single Step State
s.step()
```

## Bit Vectors (ASTs)
```python
x = s.solver.BVS('x', 32)
# <BV32 x_54_32>
y = s.solver.BVS('y', 32)
# <BV32 y_55_32>
(x + y).op
# '__add__'
(x + y).args
#(<BV32 x_54_32>, <BV32 y_55_32>)
(x + y).args[0]
# <BV32 x_54_32>
```

## Creating Constraints
```python
# Add Constraints to the State
s.add_constraints(s.regs.eax != 0xdeadbeef)
# s.add_constraints(s.regs.eip != 0xcafef00d)
# Access or Print Constraints
s.constraints
# Check if State is Satisfiable
state.satisfiable()
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




