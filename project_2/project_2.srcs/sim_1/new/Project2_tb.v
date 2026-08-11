`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 01:02:53 PM
// Design Name: 
// Module Name: Project2_tb
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

module project2_tb;

    reg reset_n;
    reg clock;
    reg signed [7:0] d_in;
    reg [1:0] op;
    reg capture;

    wire signed [9:0] result;
    wire valid;

    // Instantiate DUT
    project2 uut (
        .reset_n(reset_n),
        .clock(clock),
        .d_in(d_in),
        .op(op),
        .capture(capture),
        .result(result),
        .valid(valid)
    );

    // Clock generation (10ns period)
    always begin
        #5 clock = ~clock;
    end

    initial begin
        // Initialize signals
        clock = 0;
        reset_n = 0;
        capture = 0;
        d_in = 0;
        op = 0;

        // Apply reset
        #10;
        reset_n = 1;

        //--------------------------------------------------
        // Test Case 1: A=10, B=5, C=7, D=2
        //--------------------------------------------------
        #10;
        d_in = 8'sd10;
        op = 2'b00;   // A
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd5;
        op = 2'b01;   // B
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd7;
        op = 2'b10;   // C
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd2;
        op = 2'b11;   // D
        capture = 1;
        #10;
        capture = 0;

        #20;
        $display("Test 1 Result = %d, Valid = %b", result, valid);

        //--------------------------------------------------
        // Reset before next test
        //--------------------------------------------------
        reset_n = 0;
        #10;
        reset_n = 1;

        //--------------------------------------------------
        // Test Case 2: A=20, B=8, C=15, D=5
        //--------------------------------------------------
        #10;
        d_in = 8'sd20;
        op = 2'b00;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd8;
        op = 2'b01;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd15;
        op = 2'b10;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd5;
        op = 2'b11;
        capture = 1;
        #10;
        capture = 0;

        #20;
        $display("Test 2 Result = %d, Valid = %b", result, valid);

        //--------------------------------------------------
        // Reset before next test
        //--------------------------------------------------
        reset_n = 0;
        #10;
        reset_n = 1;

        //--------------------------------------------------
        // Test Case 3: A=25, B=10, C=5, D=2
        //--------------------------------------------------
        #10;
        d_in = 8'sd25;
        op = 2'b00;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd10;
        op = 2'b01;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd5;
        op = 2'b10;
        capture = 1;
        #10;
        capture = 0;

        #10;
        d_in = 8'sd2;
        op = 2'b11;
        capture = 1;
        #10;
        capture = 0;

        #20;
        $display("Test 3 Result = %d, Valid = %b", result, valid);

        //--------------------------------------------------
        // End simulation
        //--------------------------------------------------
        #20;
        $finish;
    end

endmodule
