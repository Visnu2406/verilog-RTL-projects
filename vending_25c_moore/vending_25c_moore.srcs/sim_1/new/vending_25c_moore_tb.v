`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 12:43:02 AM
// Design Name: 
// Module Name: vending_25c_moore_tb
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



module vending_25c_moore_tb;

    reg clock;
    reg reset_n;
    reg D;
    reg Q;

    wire [1:0] DQ;   // 2-bit coin input so waveform shows binary value
    wire P;
    wire C;

    // Combine D and Q into a 2-bit vector
    assign DQ = {D, Q};

    // Instantiate DUT
    vending_25c_moore dut (
        .clock(clock),
        .reset_n(reset_n),
        .DQ(DQ),
        .P(P),
        .C(C)
    );

    // Clock generation (10 ns period)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin

        // ================================
        // Testcase 1: Best-case scenario
        // ================================
        reset_n = 0; D = 0; Q = 0; #10;
        reset_n = 1; #10;

        D = 1; Q = 0; #10;   // DQ = 10 -> +10c -> S1
        D = 1; Q = 0; #10;   // DQ = 10 -> +10c -> S2
        D = 0; Q = 1; #10;   // DQ = 01 -> +25c -> S4 (vend + change)

        D = 0; Q = 0; #20;   // Wait

        // ================================
        // Testcase 2: Only dimes (overpay)
        // ================================
        reset_n = 0; D = 0; Q = 0; #10;
        reset_n = 1; #10;

        D = 1; Q = 0; #10;   // +10 -> S1
        D = 1; Q = 0; #10;   // +10 -> S2
        D = 1; Q = 0; #10;   // +10 -> S4 (vend + change)

        D = 0; Q = 0; #20;

        // ================================
        // Testcase 3: Invalid inputs
        // ================================
        reset_n = 0; D = 0; Q = 0; #10;
        reset_n = 1; #10;

        D = 1; Q = 0; #10;   // +10 -> S1
        D = 1; Q = 1; #10;   // 11 invalid -> stay
        D = 0; Q = 0; #10;   // 00 invalid -> stay
        D = 0; Q = 1; #10;   // +25 -> S4 (vend + change)

        D = 0; Q = 0; #20;

        // ================================
        // Testcase 4: Mixed coins
        // ================================
        reset_n = 0; D = 0; Q = 0; #10;
        reset_n = 1; #10;

        D = 1; Q = 0; #10;   // +10 -> S1
        D = 1; Q = 0; #10;   // +10 -> S2
        D = 0; Q = 1; #10;   // +25 -> S4 (vend + change)

        D = 0; Q = 0; #20;

        $finish;

    end

endmodule
