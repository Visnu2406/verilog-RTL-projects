`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2026 01:30:48 PM
// Design Name: 
// Module Name: ksa_4bit_df_tb
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


module ksa_4bit_df_tb();
    reg [3:0] A, B;
    wire [3:0] S;
    wire Cout;
    
    ksa_4bit_df dut(.A(A), .B(B), .S(S), .Cout(Cout));
    
    initial begin
        // Test 1: Base example (in pdf)
        A = 4'b1010; B= 4'b1101;
        #10;
        $display("%b  %b  |  %b    %b", A, B, S, Cout);
        
        // Test 2: No carry case
        A = 4'b0011; B = 4'b0100;
        #10;
        $display("%b  %b  |  %b    %b", A, B, S, Cout);
        
        // Test 3: Overflow case (final carry-out)
        A = 4'b1111; B = 4'b0001;
        #10;
        $display("%b  %b  |  %b    %b", A, B, S, Cout);
        
        // Test 4: Single carry generation
        A = 4'b0001; B = 4'b0001; 
        #10;
        $display("%b  %b  |  %b    %b", A, B, S, Cout);
        
        $finish;     
    end
    
endmodule
