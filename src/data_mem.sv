/*
 * Data Memory
 * Synchronous write for 'sw' and asynchronous read for 'lw'.
 */
module data_mem
(
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    // FIX 1: Expand array to 4096 words so Index 1024 and 2048 actually exist
    logic [31:0] memory [4096] = '{default: '0};

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            // FIX 2: Expand the address slice to 12 bits (13 down to 2) 
            // so the CPU can actually reach those higher addresses!
            memory[addr[13:2]] <= write_data;
        end
    end

    // Asynchronous Read
    // FIX 2: Expand the address slice here as well
    assign read_data = memory[addr[13:2]];

endmodule