`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 04/13/2026 06:35:39 AM
// Design Name: mult_seq_8x8_tb
// Assign Name: ECE 310 Lab 8
// Description: A verilog implementation of a
//              8x8 multiplier testbench
// 
//////////////////////////////////////////////////////////////////////////////////
module mult_seq_8x8_tb;
    reg clock;
    reg start;
    reg [7:0] multiplier;
    reg [7:0] multiplicand;
    wire [15:0] product;
    
    mult_seq_8x8 dut(clock, start, multiplier, multiplicand, product);
    
    initial clock = 0;
    always #5 clock = ~clock;
    
    initial begin
        start = 0;
        multiplier   = 8'd0;
        multiplicand = 8'd0;
        #20;
        
        // Test vector 1: 13 * 11 = 143
        multiplier   = 8'd13;
        multiplicand = 8'd11;
        #10; start = 1; #10; start = 0;
        #100;
        $display("Test Vector 1: %d * %d = %d", multiplier, multiplicand, product);
        #20;
        
        // Test vector 2: 200 * 150 = 30000
        multiplier   = 8'd200;
        multiplicand = 8'd150;
        #10; start = 1; #10; start = 0;
        #100;
        $display("Test Vector 2: %d * %d = %d", multiplier, multiplicand, product);
        
        $finish;
    end
endmodule
