`include "../include/opcode.vh"

module alu_controller (
    input  logic [2:0] alu_op,   // EXPANDED: 3 bits
    input  logic [2:0] func3,
    input  logic [6:0] func7,
    output logic [3:0] alu_operation
);

    always_comb begin
        case (alu_op)
            3'b000: alu_operation = 4'b0010; // Load/Store ADD
            3'b001: alu_operation = 4'b0110; // Branch SUB
            
            3'b010, 3'b011: begin // Standard R-type and I-type
                case (func3)
                    `FNC_ADD_SUB: alu_operation = (alu_op == 3'b010 && func7 == `FNC7_1) ? 4'b0110 : 4'b0010;
                    `FNC_SLL:     alu_operation = 4'b0100;
                    `FNC_SLT:     alu_operation = 4'b1000;
                    `FNC_SLTU:    alu_operation = 4'b1001;
                    `FNC_XOR:     alu_operation = 4'b0011;
                    `FNC_SRL_SRA: alu_operation = (func7 == `FNC7_1) ? 4'b0111 : 4'b0101;
                    `FNC_OR:      alu_operation = 4'b0001;
                    `FNC_AND:     alu_operation = 4'b0000;
                    default:      alu_operation = 4'b0000;
                endcase
            end

            // Custom R-Types
            3'b100: begin 
                if      (func7 == `FNC7_BITREV) alu_operation = 4'b1010;
                else if (func7 == `FNC7_CABS)   alu_operation = 4'b1011;
                else if (func7 == 7'b0000100)   alu_operation = 4'b1100; // BSWAP
                else                            alu_operation = 4'b0000;
            end

            // Custom I-Types
            3'b101: begin 
                if (func3 == 3'b001) alu_operation = 4'b1101; // MASKI
                else                 alu_operation = 4'b0000;
            end

            default: alu_operation = 4'b0000;
        endcase
    end
endmodule