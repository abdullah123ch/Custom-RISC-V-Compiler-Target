# 🛠️ Custom RISC-V Instruction Setup Guide (LLVM Backend Only)

This guide walks through the complete process of modifying the LLVM compiler backend to recognize a custom RISC-V instruction (`myadd`) and generate valid bare-metal assembly.

> **Note:** Compiling LLVM from source is resource-intensive. The steps below have been optimized to avoid common type-mismatch errors and segfaults.

```bash
git clone --depth 1 https://github.com/llvm/llvm-project.git
cd llvm-project

```

---

## Phase 2: LLVM Backend Modifications

We need to teach the LLVM backend the exact 32-bit hardware encoding for our custom instruction and how it behaves in the Intermediate Representation (IR).

### 1. Define the Hardware Instruction

**File:** `llvm/lib/Target/RISCV/RISCVInstrInfo.td`

Add this near the other custom or R-type instructions. This defines the exact opcode and register format for our datapath decoder.

```tablegen
// Add this near the other custom or R-type instructions
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def MYADD : RVInstR<0b0000000, 0b000, OPC_CUSTOM_0,
                    (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                    "myadd", "$rd, $rs1, $rs2">;

```

### 2. Define the LLVM IR Intrinsic

**File:** `llvm/include/llvm/IR/IntrinsicsRISCV.td`

Create a black-box function in the IR so the compiler knows it takes two inputs and returns one output.

```tablegen
// Define a custom intrinsic that takes two integers and returns one
let TargetPrefix = "riscv" in {
  def int_riscv_myadd : Intrinsic<[llvm_anyint_ty],
                                   [LLVMMatchType<0>, LLVMMatchType<0>],
                                   [IntrNoMem]>;
}

```

### 3. Pattern Matching (Instruction Selection)

**File:** `llvm/lib/Target/RISCV/RISCVInstrInfo.td`

Scroll down to the pattern matching section (or place this at the bottom).

*⚠️ **Important Fix:** We must wrap the intrinsic and registers in `XLenVT` (X-Length Value Type). If you just use `GPR`, TableGen will crash during the build because it cannot infer if the register is 32-bit or 64-bit.*

```tablegen
// Pattern: If you see the myadd intrinsic, emit the MYADD physical instruction
def : Pat<(XLenVT (int_riscv_myadd (XLenVT GPR:$rs1), (XLenVT GPR:$rs2))),
          (MYADD GPR:$rs1, GPR:$rs2)>;

```

---

## Phase 3: Build the Custom Compiler

Make sure you are in the root `llvm-project` directory. We will use Ninja to build only the RISC-V targets to save time.

*(Note: The `ninja` command will take some time depending on your CPU).*

```bash
# 1. Create and enter the isolated build directory
mkdir build
cd build

# 2. Configure the build system (We keep Clang enabled so we can still compile C files using inline assembly)
cmake -G Ninja ../llvm \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  -DCMAKE_BUILD_TYPE=Release

# 3. Compile the toolchain
ninja

```

---

## Phase 4: Verification & Assembly Generation

Since we bypassed the Clang frontend builtin, you can invoke your custom instruction directly using **inline assembly** in your C code.

**Create `test_add.c`:**

```c
// test_add.c
int main() {
    int a = 15;
    int b = 25;
    int result;
        
    // Call our custom hardware instruction directly using inline assembly
    asm volatile (
        "myadd %0, %1, %2"
        : "=r" (result) // Output operand
        : "r" (a), "r" (b) // Input operands
    );

    // Memory-Mapped IO to inspect the result in simulation
    volatile int *debug_memory_port = (volatile int *)0x00002000;
    *debug_memory_port = result;

    // Infinite trap to prevent executing garbage memory
    while (1) {}
    return 0;
}

```

### Generate the Object File & Assembly

From inside your `build` directory, use your **newly built compiler** to compile the C code.

* `nostdlib` / `ffreestanding`: Strips OS libraries (required for bare-metal CPU simulation).
* `fuse-ld=lld`: Forces the use of LLVM’s universal linker instead of the default system linker.

**1. Compile to Object Code (.elf):**

```bash
./bin/clang -O2 --target=riscv32 -march=rv32i -nostdlib -ffreestanding -fuse-ld=lld ./test_add.c -o test_add.elf     

```

**2. Verify the Generated Assembly:**

```bash
./bin/llvm-objdump -d test_add.elf

```

If the backend setup was successful, the LLVM assembler will recognize the `myadd` string from your inline assembly block and match it perfectly to the hardware registers!