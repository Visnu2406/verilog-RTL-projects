`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
//
// Create Date: 03/31/2026
// Design Name: lab6
// Assign Name: ECE 310 Lab 6
// Description: 8-bit PISO and SIPO shift registers
//
//////////////////////////////////////////////////////////////////////////////////

// 8-bit Parallel-Input Serial-Output register
// load=1,shift=0: load parallel_in; shift=1,load=0: shift right, 0 fills MSB
// load=shift (both or neither): no change
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


// 8-bit Serial-Input Parallel-Output register
// shift=1: shift right, serial_in enters MSB; shift=0: hold value
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
