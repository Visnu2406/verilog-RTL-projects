`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2026 09:27:07 PM
// Design Name: 
// Module Name: rca_4bit_tb
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


`timescale 1ns/1ps

module rca_4bit_tb;

    reg  [3:0] A, B;     // Inputs to the adder
    wire [3:0] S;        // Sum output
    wire Cout;           // Carry-out

    // Instantiate the Unit Under Test (UUT)
    rca_4bit uut (
        .S(S),
        .Cout(Cout),
        .A(A),
        .B(B)
    );

    initial begin
        $display("   A     B   | Cout   S ");
        $display("-------------------------");
        $monitor("%4b + %4b |   %b    %4b", A, B, Cout, S);

        // Base case
        A = 4'b0000; B = 4'b0000; #10;   // 0 + 0

        // Normal addition
        A = 4'b0011; B = 4'b0100; #10;   // 3 + 4 = 7

        // Carry ripple inside
        A = 4'b0111; B = 4'b0001; #10;   // 7 + 1 = 8

        // Overflow case
        A = 4'b1111; B = 4'b0001; #10;   // 15 + 1 = 16

        $stop;  // End simulation
    end

endmodule

