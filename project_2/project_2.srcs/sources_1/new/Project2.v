`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2026 07:45:35 PM
// Design Name: 
// Module Name: Project2
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


module project2(
    input reset_n,			
    input clock,				
    input signed [7:0] d_in,		
    input [1:0] op, 			
    input capture,			
    output signed [9:0] result,		
    output valid			
);

    // wires connecting datapath to control
    wire signed [7:0] reg8A, reg8B, reg8C, reg8D;

    // datapath
    datapath d (
        .clock(clock), 
        .reset_n(reset_n), 
        .d_in(d_in), 
        .op(op), 
        .capture(capture), 
        .result(result),
        .reg8A(reg8A),
        .reg8B(reg8B),
        .reg8C(reg8C),
        .reg8D(reg8D)
    );

    // control
    control c (
        .clock(clock), 
        .reset_n(reset_n), 
        .reg8A(reg8A),
        .reg8B(reg8B),
        .reg8C(reg8C),
        .reg8D(reg8D),
        .valid(valid)
    );

endmodule


module control(
    input clock,
    input reset_n,

    input signed [7:0] reg8A,
    input signed [7:0] reg8B,
    input signed [7:0] reg8C,
    input signed [7:0] reg8D,

    output valid
);

    // one state bit only
    wire state;
    wire next_state;

    // check if registers are filled
    wire A_filled, B_filled, C_filled, D_filled;

    assign A_filled = (reg8A != 8'd0);
    assign B_filled = (reg8B != 8'd0);
    assign C_filled = (reg8C != 8'd0);
    assign D_filled = (reg8D != 8'd0);

    // all inputs received
    wire all_filled;
    assign all_filled = A_filled & B_filled & C_filled & D_filled;

    // next state logic
    assign next_state = all_filled ? 1'b1 : state;

    // single DFF
    DFF state_reg (
        .clock(clock),
        .reset_n(reset_n),
        .D(next_state),
        .Q(state)
    );

    assign valid = state;

endmodule


module datapath(
    input clock,
    input reset_n,
    input [1:0] op,
    input signed [7:0] d_in,
    input capture,

    output signed [9:0] result,

    // register outputs
    output signed [7:0] reg8A,
    output signed [7:0] reg8B,
    output signed [7:0] reg8C,
    output signed [7:0] reg8D
);

    wire signed [7:0] A_next, B_next, C_next, D_next;

    // capture logic
    assign A_next = (op == 2'b00 && capture) ? d_in : reg8A;
    assign B_next = (op == 2'b01 && capture) ? d_in : reg8B;
    assign C_next = (op == 2'b10 && capture) ? d_in : reg8C;
    assign D_next = (op == 2'b11 && capture) ? d_in : reg8D;

    // registers
    DFF A(.clock(clock), .reset_n(reset_n), .D(A_next), .Q(reg8A));
    DFF B(.clock(clock), .reset_n(reset_n), .D(B_next), .Q(reg8B));
    DFF C(.clock(clock), .reset_n(reset_n), .D(C_next), .Q(reg8C));
    DFF D(.clock(clock), .reset_n(reset_n), .D(D_next), .Q(reg8D));

    // computation
    wire signed [8:0] A_minus_B;
    wire signed [8:0] C_minus_D;

    assign A_minus_B = reg8A - reg8B;
    assign C_minus_D = reg8C - reg8D;

    assign result = A_minus_B + C_minus_D;

endmodule


module DFF(
    input clock,
    input reset_n,
    input signed [7:0] D,
    output reg signed [7:0] Q
);

    always @(posedge clock) begin
        if (!reset_n)
            Q <= 8'sd0;
        else
            Q <= D;
    end

endmodule