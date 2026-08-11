`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project: 4-bit Kogge-Stone Adder (KSA)
// Description: Fast 4-bit adder using Kogge-Stone prefix method.
// Author: Visnu Muthuraman
//////////////////////////////////////////////////////////////////////////////////

module ksa_4bit_df(
    input  [3:0] A,      // 4-bit input A
    input  [3:0] B,      // 4-bit input B
    output [3:0] S,      // 4-bit sum
    output Cout          // Carry-out
    );

    // Internal propagate and generate signals for each layer
    wire [3:0] P0, G0, P1, G1, P2, G2;
    wire [3:0] C;         // Internal carries

    // Layer 0: initial propagate and generate
    assign P0 = A ^ B;
    assign G0 = A & B;

    // Layer 1: first stage prefix (neighbors)
    assign P1[0] = P0[0];
    assign G1[0] = G0[0];

    assign P1[1] = P0[1] & P0[0];
    assign G1[1] = G0[1] | (P0[1] & G0[0]);

    assign P1[2] = P0[2] & P0[1];
    assign G1[2] = G0[2] | (P0[2] & G0[1]);

    assign P1[3] = P0[3] & P0[2];
    assign G1[3] = G0[3] | (P0[3] & G0[2]);

    // Layer 2: second stage prefix (skip-one)
    assign P2[0] = P1[0];
    assign G2[0] = G1[0];

    assign P2[1] = P1[1];
    assign G2[1] = G1[1];

    assign P2[2] = P1[2] & P1[0];
    assign G2[2] = G1[2] | (P1[2] & G1[0]);

    assign P2[3] = P1[3] & P1[1];
    assign G2[3] = G1[3] | (P1[3] & G1[1]);

    // Carries
    assign C[0] = 1'b0;   // Initial carry-in = 0
    assign C[1] = G2[0]; 
    assign C[2] = G2[1];  
    assign C[3] = G2[2];
    assign Cout = G2[3];

    // Sum
    assign S = P0 ^ C;

endmodule


