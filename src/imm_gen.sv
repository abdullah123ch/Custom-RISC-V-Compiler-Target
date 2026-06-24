`include "../include/opcode.vh"

module imm_gen (
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

    logic [6:0] op;
    logic [2:0] func3; // For custom instruction decoding
    assign op = instruction[6:0];
    assign func3 = instruction[14:12]; // For custom instruction decoding
    
    always_comb begin
        case (op)
            // I-type (Arithmetic Imm, Loads, JALR)
            `OPC_ARI_ITYPE, `OPC_LOAD, `OPC_JALR: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type (Stores)
            `OPC_STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type (Branches)
            `OPC_BRANCH: begin
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // U-type (LUI, AUIPC)
            `OPC_LUI, `OPC_AUIPC: begin
                immediate = {instruction[31:12], 12'b0};
            end

            // J-type (Jump and Link)
            `OPC_JAL: begin
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            `OPC_CUSTOM_0: begin
                if (func3 == 3'b001) begin
                    // MASKI (Custom I-Type): bits [31:20]
                    immediate = {{20{instruction[31]}}, instruction[31:20]}; 
                end
                else if (func3 == 3'b010) begin
                    // SW.BSWAP (Custom S-Type): bits [31:25] and [11:7]
                    immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                end
            end

            default: immediate = 32'b0;
        endcase
    end
endmodule