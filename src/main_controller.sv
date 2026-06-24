`include "../include/opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    input  logic [2:0] func3,      // NEW: Needed to decode custom sub-types
    output logic [2:0] alu_op,     // EXPANDED: 3 bits to prevent collisions
    output logic       reg_write,
    output logic       alu_src,    
    output logic [2:0] result_src, 
    output logic       mem_write,  
    output logic       branch,     
    output logic       jump,       
    output logic       mem_bswap   // NEW: Signal to flip bytes before memory
);

    always_comb begin
        // Default values
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 3'b000;
        result_src = 2'b00;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        mem_bswap  = 1'b0;

        case (opcode)
            `OPC_ARI_RTYPE: begin
                reg_write  = 1'b1; alu_src = 1'b0; result_src = 2'b00; alu_op = 3'b010;
            end
            `OPC_ARI_ITYPE: begin
                reg_write  = 1'b1; alu_src = 1'b1; result_src = 2'b00; alu_op = 3'b011;
            end
            `OPC_LOAD: begin
                reg_write  = 1'b1; alu_src = 1'b1; result_src = 2'b01; alu_op = 3'b000;
            end
            `OPC_STORE: begin
                alu_src    = 1'b1; mem_write  = 1'b1; alu_op = 3'b000;
            end
            `OPC_BRANCH: begin
                alu_src    = 1'b0; branch     = 1'b1; alu_op = 3'b001;
            end
            `OPC_JAL: begin
                reg_write  = 1'b1; jump       = 1'b1; result_src = 2'b10;
            end
            `OPC_LUI: begin
                reg_write  = 1'b1; result_src = 2'b11;
            end

            // --- THE NEW CUSTOM DECODE LOGIC ---
            `OPC_CUSTOM_0: begin
                if (func3 == 3'b000) begin 
                    // Custom R-Type (BITREV, CABS, BSWAP)
                    reg_write  = 1'b1; result_src = 2'b00; alu_src = 1'b0; alu_op = 3'b100;
                end 
                else if (func3 == 3'b001) begin 
                    // Custom I-Type (MASKI)
                    reg_write  = 1'b1; result_src = 2'b00; alu_src = 1'b1; alu_op = 3'b101;
                end 
                else if (func3 == 3'b010) begin 
                    // Custom S-Type (SW.BSWAP)
                    mem_write  = 1'b1; alu_src = 1'b1; alu_op = 3'b000; // ALU calculates Address
                    mem_bswap  = 1'b1; // Trigger hardware to swap rs2
                end
            end
            default: ;
        endcase
    end
endmodule