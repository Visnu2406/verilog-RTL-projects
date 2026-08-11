`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Visnu Muthuraman
// 
// Create Date: 04/13/2026 06:35:39 AM
// Design Name: 
// Module Name: mult_seq_8x8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Sequential 8x8 unsigned multiplier using shift-and-add method.
//              Produces a 16-bit product over 8 clock cycles.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module mult_seq_8x8(
    input  wire clock,
    input  wire start,
    input  wire [7:0]  multiplier,
    input  wire [7:0]  multiplicand,
    output reg  [15:0] product
    );
    
    reg [7:0]  mult_reg;     // shifts right each cycle
    reg [15:0] mcand_reg;    // shifts left each cycle, 16-bit for alignment
    reg [3:0]  cycle_count;
    
    always @(posedge clock) begin
        if (start) begin
            // Load inputs and reset product
            product <= 16'b0;
            mult_reg <= multiplier;
            mcand_reg <= {8'b0, multiplicand};
            cycle_count <= 4'd1;
        end
        else if (cycle_count >= 4'd1 && cycle_count <= 4'd8) begin
            // If current multiplier bit is 1, add shifted multiplicand
            if (mult_reg[0])
                product <= product + mcand_reg;
            mult_reg <= mult_reg  >> 1;
            mcand_reg <= mcand_reg << 1;
            cycle_count <= cycle_count + 4'd1;
        end
    end
    
endmodule
