/*
 * Instruction Memory (IROM)
 * Provides the 32-bit machine code at the given PC address.
 */
module instr_mem
(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] memory [1024]; // 1024 words of memory

    // // Load machine code from a hex file (created during assembly)
    initial begin
        $readmemh("../sw/program.hex", memory);
    end

    // Asynchronous read: Instruction is available immediately
    // Note: PC is byte-addressed, but memory is word-aligned (addr >> 2)
    assign instr = memory[addr[11:2]];

endmodule