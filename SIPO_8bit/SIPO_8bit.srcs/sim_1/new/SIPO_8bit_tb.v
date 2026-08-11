`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
//
// Create Date: 03/31/2026
// Design Name: SIPO_8bit_tb
// Assign Name: ECE 310 Lab 6
// Description: A testbench for a
//              Serial In Parallel Out Shift Register
//
//////////////////////////////////////////////////////////////////////////////////
module SIPO_8bit_tb;
    reg serial_in;
    reg clk, rst, shift;
    wire [7:0] parallel_out;

    SIPO_8bit dut (
        .clk(clk),
        .rst(rst),
        .shift(shift),
        .serial_in(serial_in),
        .parallel_out(parallel_out)
    );

    // Clock generation (period = 10 ns)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 0; shift = 0; serial_in = 0;
        #10;

        // Reset
        rst = 1; #10; rst = 0;
        #10;

        // --- Test 1: 0xA5 = 10100101, no delay ---
        // send LSB first: 1,0,1,0,0,1,0,1
        serial_in = 1; shift = 1; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        shift = 0; #20;

        // --- Test 2: 0x3C = 00111100, no delay ---
        // send LSB first: 0,0,1,1,1,1,0,0
        shift = 1;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 1; #10;
        serial_in = 1; #10;
        serial_in = 1; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        shift = 0; #20;

        // --- Test 3: 0xA5 with 2-cycle delay between each bit ---
        rst = 1; #10; rst = 0; #10;
        serial_in = 1; shift = 1; #10; shift = 0; #20;
        serial_in = 0; shift = 1; #10; shift = 0; #20;
        serial_in = 1; shift = 1; #10; shift = 0; #20;
        serial_in = 0; shift = 1; #10; shift = 0; #20;
        serial_in = 0; shift = 1; #10; shift = 0; #20;
        serial_in = 1; shift = 1; #10; shift = 0; #20;
        serial_in = 0; shift = 1; #10; shift = 0; #20;
        serial_in = 1; shift = 1; #10; shift = 0; #20;
        #20;

        // --- Test 4: 0x3C with 3-cycle delay between each bit ---
        serial_in = 0; shift = 1; #10; shift = 0; #30;
        serial_in = 0; shift = 1; #10; shift = 0; #30;
        serial_in = 1; shift = 1; #10; shift = 0; #30;
        serial_in = 1; shift = 1; #10; shift = 0; #30;
        serial_in = 1; shift = 1; #10; shift = 0; #30;
        serial_in = 1; shift = 1; #10; shift = 0; #30;
        serial_in = 0; shift = 1; #10; shift = 0; #30;
        serial_in = 0; shift = 1; #10; shift = 0; #30;
        #20;

        $stop;
    end
endmodule
