`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 11:26:39 PM
// Design Name: 
// Module Name: shifter_tb
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

module shifter_tb;

    reg clock;
    reg [7:0] d_in;
    reg [2:0] op;
    reg capture_n;
    wire [7:0] q;

    // Instantiate DUT
    shifter_8bit_df uut (
        .clock(clock),
        .d_in(d_in),
        .op(op),
        .capture_n(capture_n),
        .q(q)
    );

    // Clock generation (10 time unit period)
    always #5 clock = ~clock;

    initial begin
        clock = 0;
        capture_n = 0;

        // ===============================
        // Test 1: Shift left by 1
        // ===============================
        d_in = 8'b10101010;
        op = 3'd0;
        #10;

        // ===============================
        // Test 2: Shift right by 2
        // ===============================
        d_in = 8'b11001100;
        op = 3'd3;
        #10;

        // ===============================
        // Test 3: Rotate left by 1
        // ===============================
        d_in = 8'b10000001;
        op = 3'd4;
        #10;

        // ===============================
        // Test 4: Rotate right by 1
        // ===============================
        d_in = 8'b10000001;
        op = 3'd5;
        #10;

        $stop;
    end

endmodule
