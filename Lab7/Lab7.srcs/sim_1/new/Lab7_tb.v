`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NC State University
// Engineer:
//
// Create Date: 04/05/2026
// Design Name:
// Module Name: Lab7_tb
// Project Name: Lab7
// Target Devices:
// Tool Versions:
// Description: Testbench for BCDadd_1d and BCDadd_4d
//
// Dependencies: Lab7.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module Lab7_tb;

    // BCDadd_1d signals
    reg  [3:0] A1, B1;
    reg        Cin1;
    wire [3:0] Sum1;
    wire       Cout1;

    BCDadd_1d uut1 (
        .A(A1), .B(B1), .Cin(Cin1),
        .Sum(Sum1), .Cout(Cout1)
    );

    // BCDadd_4d signals
    reg  [15:0] A4, B4;
    reg         Cin4;
    wire [15:0] Sum4;
    wire  [3:0] Cout4;

    BCDadd_4d uut4 (
        .A(A4), .B(B4), .Cin(Cin4),
        .Sum(Sum4), .Cout(Cout4)
    );

    task test_1d;
        input [3:0] a, b;
        input       cin;
        input [3:0] exp_sum;
        input       exp_cout;
        begin
            A1 = a; B1 = b; Cin1 = cin;
            #10;
            $display("1d | A=%0d B=%0d Cin=%b | Sum=%0d Cout=%b | Exp Sum=%0d Cout=%b | %s",
                a, b, cin, Sum1, Cout1, exp_sum, exp_cout,
                (Sum1 === exp_sum && Cout1 === exp_cout) ? "PASS" : "FAIL");
        end
    endtask

    task test_4d;
        input [15:0] a, b;
        input        cin;
        input [15:0] exp_sum;
        input  [3:0] exp_cout;
        begin
            A4 = a; B4 = b; Cin4 = cin;
            #10;
            $display("4d | A=%04h B=%04h Cin=%b | Sum=%04h Cout=%h | Exp Sum=%04h Cout=%h | %s",
                a, b, cin, Sum4, Cout4, exp_sum, exp_cout,
                (Sum4 === exp_sum && Cout4 === exp_cout) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        // initialize all inputs
        A1 = 0; B1 = 0; Cin1 = 0;
        A4 = 0; B4 = 0; Cin4 = 0;
        #10;

        $display("===== BCDadd_1d Exhaustive Test =====");

        // no carry-in
        test_1d(4'd3, 4'd5, 0, 4'd8,  1'b0); // 3+5=8
        test_1d(4'd0, 4'd0, 0, 4'd0,  1'b0); // 0+0=0
        test_1d(4'd4, 4'd4, 0, 4'd8,  1'b0); // 4+4=8
        test_1d(4'd1, 4'd9, 0, 4'd0,  1'b1); // 1+9=10, corrected
        test_1d(4'd5, 4'd5, 0, 4'd0,  1'b1); // 5+5=10, corrected
        test_1d(4'd6, 4'd4, 0, 4'd0,  1'b1); // 6+4=10, corrected
        test_1d(4'd6, 4'd6, 0, 4'd2,  1'b1); // 6+6=12, corrected
        test_1d(4'd7, 4'd8, 0, 4'd5,  1'b1); // 7+8=15, corrected
        test_1d(4'd9, 4'd9, 0, 4'd8,  1'b1); // 9+9=18, corrected
        test_1d(4'd9, 4'd1, 0, 4'd0,  1'b1); // 9+1=10, corrected

        // with carry-in
        test_1d(4'd3, 4'd5, 1, 4'd9,  1'b0); // 3+5+1=9
        test_1d(4'd4, 4'd5, 1, 4'd0,  1'b1); // 4+5+1=10, corrected
        test_1d(4'd7, 4'd8, 1, 4'd6,  1'b1); // 7+8+1=16, corrected
        test_1d(4'd9, 4'd9, 1, 4'd9,  1'b1); // 9+9+1=19, corrected
        test_1d(4'd0, 4'd0, 1, 4'd1,  1'b0); // 0+0+1=1
        test_1d(4'd0, 4'd9, 1, 4'd0,  1'b1); // 0+9+1=10, corrected

        $display("");
        $display("===== BCDadd_4d Selective Test =====");

        test_4d(16'h0123, 16'h7654, 0, 16'h7777, 4'h0); // 0123+7654=7777
        test_4d(16'h3210, 16'h7654, 0, 16'h0864, 4'h1); // 3210+7654=10864
        test_4d(16'h9999, 16'h9999, 0, 16'h9998, 4'h1); // 9999+9999=19998
        test_4d(16'h0000, 16'h0000, 0, 16'h0000, 4'h0); // 0+0=0
        test_4d(16'h0001, 16'h0009, 0, 16'h0010, 4'h0); // 0001+0009=0010
        test_4d(16'h5555, 16'h4444, 0, 16'h9999, 4'h0); // 5555+4444=9999
        test_4d(16'h5555, 16'h5555, 0, 16'h1110, 4'h1); // 5555+5555=11110
        test_4d(16'h0000, 16'h0000, 1, 16'h0001, 4'h0); // 0+0+cin=1
        test_4d(16'h9999, 16'h9999, 1, 16'h9999, 4'h1); // 9999+9999+cin=19999

        $display("");
        $finish;
    end

endmodule
