`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
//
// Create Date: 03/31/2026
// Design Name: PISO_8bit
// Assign Name: ECE 310 Lab 6
// Description: 8-bit Parallel In Serial Out Shift Register
//
//////////////////////////////////////////////////////////////////////////////////
module PISO_8bit (
    input        clk,
    input        rst,
    input        load,
    input        shift,
    input  [7:0] parallel_in,
    output       serial_out
);
    reg [7:0] shift_reg;

    assign serial_out = shift_reg[0];

    always @(posedge clk) begin
        if (rst)
            shift_reg <= 8'b0;
        else if (load && !shift)
            shift_reg <= parallel_in;
        else if (shift && !load)
            shift_reg <= {1'b0, shift_reg[7:1]};
    end

endmodule
