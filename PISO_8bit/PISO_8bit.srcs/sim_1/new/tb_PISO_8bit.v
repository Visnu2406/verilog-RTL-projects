`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
//
// Create Date: 03/31/2026
// Design Name: PISO_8bit_tb
// Assign Name: ECE 310 Lab 6
// Description: A testbench for a
//              Parallel In Serial Out Shift Register
//
//////////////////////////////////////////////////////////////////////////////////
module PISO_8bit_tb;
    reg [7:0] parallel_in;
    reg clk, rst, shift, load;
    wire serial_out;

    PISO_8bit dut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift(shift),
        .parallel_in(parallel_in),
        .serial_out(serial_out)
    );

    // Clock generation (period = 10 ns)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 0; shift = 0; load = 0; parallel_in = 8'b0;
        #10;

        // Reset
        rst = 1; #10; rst = 0;
        #10;

        // --- Test 1: 0xA5 = 10100101, no delay ---
        parallel_in = 8'b10100101;
        load = 1; #10; load = 0;
        #10;
        shift = 1;
        repeat(8) #10;
        shift = 0;
        #20;

        // --- Test 2: 0x3C = 00111100, no delay ---
        parallel_in = 8'b00111100;
        load = 1; #10; load = 0;
        #10;
        shift = 1;
        repeat(8) #10;
        shift = 0;
        #20;

        // --- Test 3: 0xA5 with delay between load and shift ---
        rst = 1; #10; rst = 0;
        parallel_in = 8'b10100101;
        load = 1; #10; load = 0;
        #30;
        shift = 1;
        repeat(8) #10;
        shift = 0;
        #20;

        // --- Test 4: 0x3C with delay between load and shift ---
        parallel_in = 8'b00111100;
        load = 1; #10; load = 0;
        #50;
        shift = 1;
        repeat(8) #10;
        shift = 0;
        #20;

        $stop;
    end
endmodule
