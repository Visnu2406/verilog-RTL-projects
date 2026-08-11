`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 08:51:31 PM
// Design Name: 
// Module Name: Dadda_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module Dadda8x8_tb;

    reg [7:0] a, b;
    wire [15:0] prod;

    // Instantiate the Dadda 8x8 multiplier
    Dadda8x8 dut (
        .a(a),
        .b(b),
        .prod(prod)
    );

    initial begin
        // 1) Zero * non-zero
        a = 8'b00000000; b = 8'b01010101;  // 0 * 85
        #10 $display("A: %b B: %b PROD: %b", a, b, prod);

        // 2) One * mid-size
        a = 8'b00000001; b = 8'b00110011;  // 1 * 51
        #10 $display("A: %b B: %b PROD: %b", a, b, prod);

        // 3) Small odd numbers
        a = 8'b00000111; b = 8'b00001001;  // 7 * 9
        #10 $display("A: %b B: %b PROD: %b", a, b, prod);

        // 4) Power-of-two * small number
        a = 8'b01000000; b = 8'b00000110;  // 64 * 6
        #10 $display("A: %b B: %b PROD: %b", a, b, prod);

        // 5) Large numbers
        a = 8'b11101010; b = 8'b10110101;  // 234 * 181
        #10 $display("A: %b B: %b PROD: %b", a, b, prod);

        $finish;
    end
endmodule

