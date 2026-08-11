`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NC State University
// Engineer: Visnu Muthuraman
// 
// Create Date: 04/05/2026
// Design Name: 
// Module Name: BCDadd_1d, BCDadd_4d
// Project Name: Lab7
// Target Devices: 
// Tool Versions: 
// Description: Single-digit and 4-digit BCD adders with carry-in and carry-out
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BCDadd_1d(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output reg [3:0] Sum,
    output reg       Cout
);

    reg [4:0] bin_sum;  
    reg [4:0] corr_sum; 

    always @(*) begin
        bin_sum  = A + B + Cin;
        corr_sum = bin_sum + 5'd6; 

        if (bin_sum > 5'd9) begin
            Sum  = corr_sum[3:0]; 
            Cout = 1'b1;          
        end else begin
            Sum  = bin_sum[3:0];  
            Cout = 1'b0;
        end
    end

endmodule


module BCDadd_4d(
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] Sum,
    output  [3:0] Cout
);

    wire c1, c2, c3, c4; // carries chained from digit to digit (LSD to MSD)

    BCDadd_1d digit0 (.A(A[3:0]),   .B(B[3:0]),   .Cin(Cin), .Sum(Sum[3:0]),   .Cout(c1));
    BCDadd_1d digit1 (.A(A[7:4]),   .B(B[7:4]),   .Cin(c1),  .Sum(Sum[7:4]),   .Cout(c2));
    BCDadd_1d digit2 (.A(A[11:8]),  .B(B[11:8]),  .Cin(c2),  .Sum(Sum[11:8]),  .Cout(c3));
    BCDadd_1d digit3 (.A(A[15:12]), .B(B[15:12]), .Cin(c3),  .Sum(Sum[15:12]), .Cout(c4));

    assign Cout = {3'b000, c4}; 

endmodule
