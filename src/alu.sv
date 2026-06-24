module alu (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  logic [3:0]  alu_operation,

    output logic [31:0] result,
    output logic        zero
);

    always_comb begin
        unique case (alu_operation)

            4'b0000: result = operand_a & operand_b;                      // AND
            4'b0001: result = operand_a | operand_b;                      // OR
            4'b0010: result = operand_a + operand_b;                      // ADD
            4'b0011: result = operand_a ^ operand_b;                      // XOR
            4'b0100: result = operand_a << operand_b[4:0];                // SLL
            4'b0101: result = operand_a >> operand_b[4:0];                // SRL
            4'b0110: result = operand_a - operand_b;                      // SUB
            4'b0111: result = $signed(operand_a) >>> operand_b[4:0];      // SRA
            4'b1000: result = ($signed(operand_a) < $signed(operand_b)) 
                                ? 32'd1 : 32'd0;                          // SLT
            4'b1001: result = (operand_a < operand_b) 
                                ? 32'd1 : 32'd0;                          // SLTU
            // Custom Instructions
            4'b1010: result = {<<{operand_a}};                            // BITREV
            4'b1011: result = operand_a[31] ? (~operand_a + 1'b1) : operand_a; // CABS
            4'b1100: result = {operand_a[7:0], operand_a[15:8], operand_a[23:16], operand_a[31:24]}; // BSWAP
            
            // MASKI: rd = rs1 & ((1 << imm) - 1)
            4'b1101: result = operand_a & ((32'h0000_0001 << operand_b[4:0]) - 32'd1);
            default: result = 32'd0;

        endcase
    end

    // Zero flag
    assign zero = (result == 32'd0);

endmodule