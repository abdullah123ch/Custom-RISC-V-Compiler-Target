/*
 * Program Counter (PC) Register
 * Updates the instruction address on the rising edge of the clock.
 */
module pc
#(
    parameter WIDTH = 32
)
(
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] pc_next,
    output logic [WIDTH-1:0] pc_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h0000_0000; // Reset to start of memory
        end
        else begin
            pc_out <= pc_next;
        end
    end

endmodule