`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Visnu Muthuraman
// Design Name: 8-bit Circular Shifter
// Module Name: shifter_8bit_df
//////////////////////////////////////////////////////////////////////////////////


module shifter_8bit_df (
    input clock,
    input [7:0] d_in,
    input [2:0] op,          
    input capture_n,         // active-low capture
    output [7:0] q
);

    wire [7:0] d_out;        
    wire [7:0] d_cap;        

    // 8:1 mux
    assign d_out =
        (op == 3'd0) ? (d_in << 1) :
        (op == 3'd1) ? (d_in << 2) :
        (op == 3'd2) ? (d_in >> 1) :
        (op == 3'd3) ? (d_in >> 2) :
        (op == 3'd4) ? {d_in[6:0], d_in[7]} :
        (op == 3'd5) ? {d_in[0], d_in[7:1]} :
        (op == 3'd6) ? d_in :
        8'b00000000;         // default loads 0s

    // 2:1 active-low mux
    assign d_cap = (capture_n == 1'b0) ? d_out : q;

    // 8-bit register
    reg8 reg_instance (.clock(clock), .d(d_cap), .q(q));

endmodule


// 8-bit register built from 8 DFFs
module reg8 (
    input clock,
    input [7:0] d,
    output [7:0] q
);

    dff dff0 (.clock(clock), .d(d[0]), .q(q[0]));
    dff dff1 (.clock(clock), .d(d[1]), .q(q[1]));
    dff dff2 (.clock(clock), .d(d[2]), .q(q[2]));
    dff dff3 (.clock(clock), .d(d[3]), .q(q[3]));
    dff dff4 (.clock(clock), .d(d[4]), .q(q[4]));
    dff dff5 (.clock(clock), .d(d[5]), .q(q[5]));
    dff dff6 (.clock(clock), .d(d[6]), .q(q[6]));
    dff dff7 (.clock(clock), .d(d[7]), .q(q[7]));

endmodule



module dff(
    input clock,
    input d,
    output reg q
);

always @(posedge clock) q <= d;  // rising-edge triggered

endmodule
