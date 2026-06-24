_start:
    # 1. Initialize Pointers (Using supported LUI and ADDI)
    lui a0, 0x00001        # a0 = 0x1000 (Input Sensor Data Base Address)
    lui a1, 0x00002        # a1 = 0x2000 (Output Network Buffer Address)

    # 2. Setup Configuration Register Data
    lui a4, 0xABCDE        # a4 = 0xABCDE000
    addi a4, a4, 0x123     # a4 = 0xABCDE123

    # --- CUSTOM INST 1: MASKI ---
    # Extract bottom 8 bits from the config register
    maski a3, a4, 8        # a3 = 0x00000023

    # --- CUSTOM INST 2: BSWAP ---
    # Swap byte order for network header formatting
    bswap a3, a3           # a3 = 0x23000000

    # Store Header to Memory (Using supported SW)
    sw a3, 0(a1)           # mem[0x2000] = 0x23000000
    addi a1, a1, 4         # Advance output pointer

    # 3. Setup Loop Bounds
    # We will process 3 words (12 bytes of data)
    addi a2, a0, 12        # a2 = End Address (0x100C)

    # 4. Main Processing Loop
loop:
    # Exit condition: If Input Pointer == End Address, branch to end
    # (Using supported BEQ)
    beq a0, a2, end_loop   

    # Load Raw Sensor Data (Using supported LW)
    lw a3, 0(a0)

    # --- CUSTOM INST 3: CABS ---
    # Get absolute value of raw data (Zero branch penalty!)
    cabs a3, a3

    # --- CUSTOM INST 4: BITREV ---
    # Scramble data in a single cycle
    bitrev a3, a3

    # --- CUSTOM INST 5: SW.BSWAP ---
    # Store to network buffer with swapped bytes
    sw.bswap a3, 0(a1)

    # Advance Pointers
    addi a0, a0, 4
    addi a1, a1, 4

    # Unconditional jump back to start of loop 
    # (Using pure JAL, saving x0 so it doesn't corrupt the return address)
    jal x0, loop

end_loop:
    # Trap the CPU in an infinite loop to cleanly finish the simulation
halt:
    beq x0, x0, halt