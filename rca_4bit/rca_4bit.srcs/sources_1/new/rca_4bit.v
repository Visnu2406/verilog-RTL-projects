`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NC State
// Engineer: Visnu Muthuraman
// 
// Create Date: 02/10/2026 08:45:38 PM
// Design Name: Ripple-Carry Adder (4-bit)
// Module Name: rca_4bit
// Project Name: Lab 2 (ECE-310)
// Target Devices: Basys-3 (Artix 7 family)
// Tool Versions: Vivado (2025.1)
// Description: This will simulate a Ripple-Carry Adder using a full-adder
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module full_adder_struct(
    output S, Cout,                 // outputs S, Cout (Sum & Carry Out)
    input A, B, Cin               // inputs A, B, Cin (4-bit A, B, Carry-in)
    );
    
    wire xor1, and2, and3;   // internal wires
    
    xor g1(xor1, A, B);           // First XOR Gate (G1)
    and g2(and2, A, B);          // First AND Gate (G2)
    xor g3(S, xor1, Cin);       // Second XOR Gate, S (G3, Sum)
    and g4(and3, xor1, Cin);   // Second AND Gate
    or g5(Cout, and3, and2);  // First OR ouput (G5, Cout) 
endmodule


module rca_4bit(
    output [3:0] S,
    output Cout,
    input  [3:0] A, B
);
    wire cin1, cin2, cin3;

    full_adder_struct f0(S[0], cin1, A[0], B[0], 1'b0);
    full_adder_struct f1(S[1], cin2, A[1], B[1], cin1);
    full_adder_struct f2(S[2], cin3, A[2], B[2], cin2);
    full_adder_struct f3(S[3], Cout, A[3], B[3], cin3);

endmodule


module rca_4bit_tb;
    reg  [3:0] A, B;     // Inputs to the adder
    wire [3:0] S;        // Sum output
    wire Cout;           // Carry-out

    rca_4bit dut (S, Cout, A, B);
    initial begin
        A = 4'b0000;
        B = 4'b0000;
        #10;
        $display("A: %b B: %b S: %b Cout: %b ", A, B, S, Cout);
        
        A = 4'b1111;
        B = 4'b1111;
        #10;
        $display("A: %b B: %b S: %b Cout: %b ", A, B, S, Cout);
        
        A = 4'b0100;
        B = 4'b0011;
        #10;
        $display("A: %b B: %b S: %b Cout: %b ", A, B, S, Cout);
        
        A = 4'b1111;
        B = 4'b0001;
        #10;
        $display("A: %b B: %b S: %b Cout: %b ", A, B, S, Cout);
    end
endmodule



