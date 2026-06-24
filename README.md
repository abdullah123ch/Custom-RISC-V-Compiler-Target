# Custom RISC-V Compiler Target

## Overview

This repository contains a custom RISC-V compiler extension and a single-cycle RISC-V processor used primarily as a validation target for the compiler's custom instruction set.

The hardware is implemented in SystemVerilog and includes:
- A single-cycle datapath target for the custom compiler
- Instruction and data memories
- Register file and ALU
- Main control unit with custom opcodes
- A testbench for functional simulation

## Key Features

- Supports standard RISC-V base instructions: `ADD`, `ADDI`, `LW`, `SW`, `BEQ`, `JAL`, `LUI`
- Adds a custom instruction opcode space `OPC_CUSTOM_0` with:
  - `MASKI`  : extract low bits from a register
  - `BSWAP`  : byte-swap a 32-bit word
  - `CABS`   : absolute value of a signed integer
  - `BITREV` : bit reversal of a 32-bit word
  - `SW.BSWAP`: store word with byte-swap performed before memory write
- Supports memory byte-swapping on store through dedicated control signal `mem_bswap`

## Repository Structure

- `Makefile` - simulation build and run targets
- `bin/` - tool stubs or compiler binaries (not part of RTL simulation flow)
- `docs/guide.md` - LLVM backend custom instruction guide
- `include/` - opcode and memory path definitions
- `llvm/` - LLVM target files for custom instruction support
- `sim/` - simulation testbench and command notes
- `src/` - RTL source code for the processor
- `sw/` - example software programs and inline assembly usage

## RTL Design Modules

### `src/single_cycle.sv`
Top-level CPU module containing:
- Program counter (`pc`)
- Instruction memory (`instr_mem`)
- Main controller (`main_controller`)
- Immediate generator (`imm_gen`)
- Register file (`reg_file`)
- ALU controller (`alu_controller`)
- ALU (`alu`)
- Data memory (`data_mem`)

It performs:
- PC update and branching
- Instruction fetch
- Control signal generation
- ALU operations and operand selection
- Memory load/store
- Write-back muxing

### `src/main_controller.sv`
The control unit decodes instruction opcodes and function fields to generate control signals.
It supports:
- `OPC_ARI_RTYPE`
- `OPC_ARI_ITYPE`
- `OPC_LOAD`
- `OPC_STORE`
- `OPC_BRANCH`
- `OPC_JAL`
- `OPC_LUI`
- `OPC_CUSTOM_0`

Custom extension decoding is performed using `func3`:
- `func3 == 3'b000` : custom R-type ALU operations (`BITREV`, `CABS`, `BSWAP`)
- `func3 == 3'b001` : custom I-type operation (`MASKI`)
- `func3 == 3'b010` : custom store operation (`SW.BSWAP`)

### `src/alu_controller.sv`
Maps ALU opcodes and function bits to a concrete ALU operation code.

### `src/alu.sv`
Implements arithmetic and logic operations, plus the custom functional behavior needed for the custom instruction extensions.

### `src/imm_gen.sv`
Extracts immediate values from fetched instructions for I-type, S-type, B-type, U-type, and J-type formats.

### `src/instr_mem.sv`
Instruction memory module used by the testbench to source program instructions.

### `src/data_mem.sv`
Data memory module with a write path that uses `mem_bswap` to optionally swap bytes before writing.

## Custom Instruction Set

### Supported custom instructions

- `MASKI rd, rs1, imm`
  - Immediate-type
  - Extracts the low `imm` bits from source register `rs1`
  - Writes the result to `rd`

- `BSWAP rd, rs1`
  - Register-type
  - Swaps the byte order of the 32-bit value in `rs1`
  - Writes the result to `rd`

- `CABS rd, rs1`
  - Register-type
  - Computes the absolute value of signed 32-bit `rs1`
  - Writes the result to `rd`

- `BITREV rd, rs1`
  - Register-type
  - Reverses all 32 bits in `rs1`
  - Writes the result to `rd`

- `SW.BSWAP rs2, offset(rs1)`
  - Store-type
  - Writes `rs2` to memory at the computed address after byte-swapping the data

### Opcode definitions

Defined in `include/opcode.vh`:
- `OPC_CUSTOM_0 = 7'b0001011`
- `FNC7_BITREV  = 7'b0000001`
- `FNC7_CABS   = 7'b0000010`
- `FNC7_BSWAP  = 7'b0000100`

## Example Software Flow

The sample program in `sw/program.S` demonstrates a data-processing pipeline:
1. Initialize input and output pointers
2. Create a network header using `MASKI` and `BSWAP`
3. Loop over 3 sensor values
4. `LW` raw data from input buffer
5. Apply `CABS` to compute absolute value
6. Apply `BITREV` to scramble the payload
7. Use `SW.BSWAP` to store the scrambled data with byte-swapped ordering
8. Halt in an infinite `BEQ x0, x0, halt` loop

The C code in `sw/stream.c` shows how to use inline assembly to call custom instructions from C.

## Simulation and Build Instructions

### Prerequisites

- SystemVerilog simulator that supports `vlog` and `vsim` (ModelSim / QuestaSim compatible)
- `gtkwave` for waveform viewing (optional)

### Run the simulation

From the repository root:

```bash
make
```

This runs the default `all` target, which compiles the RTL and testbench and executes the simulation.

### View waveforms

After running the simulation, if `dump.vcd` is generated:

```bash
make wave
```

### Clean simulation files

```bash
make clean
```

## Notes on Testbench

- The testbench is `sim/testbench.sv`.
- It initializes the clock and reset signals.
- It preloads data memory with sample sensor values at address `0x1000`.
- It runs simulation for a fixed time and prints the processed output values from data memory at `0x2000`.
- The instruction memory loader line is commented out by default and can be updated to point to `sw/program.hex` once the program is assembled.

## How to Extend the Custom Compiler Target

- Add new custom instructions by extending `include/opcode.vh` and `src/main_controller.sv`.
- Implement new behavior in `src/alu.sv` and update `src/alu_controller.sv` if needed.
- Add new programs or tests under `sw/` and adapt `sim/testbench.sv` to load them.

## Useful Files

- `src/single_cycle.sv` - top-level pipeline module
- `src/main_controller.sv` - instruction decoder and control generator
- `src/alu.sv` - arithmetic/logic/custom datapath operations
- `src/data_mem.sv` - data memory with optional byte-swapped stores
- `sw/program.S` - example assembly program for custom ISP pipeline
- `sw/stream.c` - C inline assembly example using custom instructions
- `docs/guide.md` - LLVM backend guide for custom RISC-V instruction support

## Contact

For any questions about the processor design or the custom ISA, inspect the RTL in `src/` and the opcode map in `include/opcode.vh`.
# Custom-RISC-V-Compiler-Target
