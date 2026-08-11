`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
//
// Create Date: 03/31/2026
// Design Name: SIPO_8bit
// Assign Name: ECE 310 Lab 6
// Description: 8-bit Serial In Parallel Out Shift Register
//
//////////////////////////////////////////////////////////////////////////////////
module SIPO_8bit (
    input        clk,
    input        rst,
    input        shift,
    input        serial_in,
    output [7:0] parallel_out
);
    reg [7:0] shift_reg;

    assign parallel_out = shift_reg;

    always @(posedge clk) begin
        if (rst)
            shift_reg <= 8'b0;
        else if (shift)
            shift_reg <= {serial_in, shift_reg[7:1]};
    end

endmodule
