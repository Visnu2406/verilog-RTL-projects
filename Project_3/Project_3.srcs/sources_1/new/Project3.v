`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 09:52:07 PM
// Design Name: 
// Module Name: Project3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Serial BCD ALU - receives a 41-bit serial packet, computes
//              4-digit BCD addition or subtraction, transmits 28-bit result
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Project3(
    input  wire clock,
    input  wire reset,
    input  wire din,
    output wire result
);
    wire [40:0] sipo_data;
    wire [19:0] alu_result;
    wire        piso_load, piso_shift;
    wire [27:0] piso_data;
    wire        op;
    wire [15:0] A, B;

    SIPO sipo (
        .clock    (clock),
        .reset    (reset),
        .din      (din),
        .data_out (sipo_data)
    );

    Controller ctrl (
        .clock      (clock),
        .reset      (reset),
        .sipo_data  (sipo_data),
        .alu_result (alu_result),
        .piso_load  (piso_load),
        .piso_shift (piso_shift),
        .piso_data  (piso_data),
        .op         (op),
        .A          (A),
        .B          (B)
    );

    BCD_ALU alu (
        .op     (op),
        .A      (A),
        .B      (B),
        .result (alu_result)
    );

    PISO piso (
        .clock      (clock),
        .reset      (reset),
        .load       (piso_load),
        .shift      (piso_shift),
        .data_in    (piso_data),
        .serial_out (result)
    );
endmodule


// SIPO shift register - 41 bits wide
// Shifts din in MSB first on every rising clock edge
module SIPO(
    input  wire        clock,
    input  wire        reset,
    input  wire        din,
    output reg  [40:0] data_out
);
    always @(posedge clock) begin
        if (reset)
            data_out <= 41'b0;
        else
            data_out <= {data_out[39:0], din};
    end
endmodule


// PISO shift register - 28 bits wide
// Loads parallel data when load=1, shifts out MSB first when shift=1
module PISO(
    input  wire        clock,
    input  wire        reset,
    input  wire        load,
    input  wire        shift,
    input  wire [27:0] data_in,
    output wire        serial_out
);
    reg [27:0] reg_data;

    always @(posedge clock) begin
        if (reset)
            reg_data <= 28'b0;
        else if (load)
            reg_data <= data_in;
        else if (shift)
            reg_data <= {reg_data[26:0], 1'b0};
    end

    assign serial_out = reg_data[27];
endmodule


// 4-bit BCD digit adder
// Adds a + b + cin, corrects to valid BCD with +6 if result > 9
module BCD_adder_4bit(
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] raw;
    wire       needs_adjust;
    wire [4:0] adjusted;

    assign raw          = {1'b0, a} + {1'b0, b} + {4'b0, cin};
    assign needs_adjust = (raw > 5'd9);
    assign adjusted     = raw + (needs_adjust ? 5'd6 : 5'd0);

    assign sum  = adjusted[3:0];
    assign cout = adjusted[4] | needs_adjust;
endmodule


// BCD ALU - 4-digit addition and subtraction
// op=0: A+B, op=1: A-B via 10's complement
module BCD_ALU(
    input  wire        op,
    input  wire [15:0] A,
    input  wire [15:0] B,
    output wire [19:0] result
);
    wire [15:0] B_use;
    wire        c0, c1, c2, c3;
    wire [3:0]  s0, s1, s2, s3;

    // 9's complement each digit of B when subtracting
    assign B_use[3:0]   = op ? (4'd9 - B[3:0])   : B[3:0];
    assign B_use[7:4]   = op ? (4'd9 - B[7:4])   : B[7:4];
    assign B_use[11:8]  = op ? (4'd9 - B[11:8])  : B[11:8];
    assign B_use[15:12] = op ? (4'd9 - B[15:12]) : B[15:12];

    // cin=op adds the +1 to complete the 10's complement
    BCD_adder_4bit digit0 (.a(A[3:0]),   .b(B_use[3:0]),   .cin(op), .sum(s0), .cout(c0));
    BCD_adder_4bit digit1 (.a(A[7:4]),   .b(B_use[7:4]),   .cin(c0), .sum(s1), .cout(c1));
    BCD_adder_4bit digit2 (.a(A[11:8]),  .b(B_use[11:8]),  .cin(c1), .sum(s2), .cout(c2));
    BCD_adder_4bit digit3 (.a(A[15:12]), .b(B_use[15:12]), .cin(c2), .sum(s3), .cout(c3));

    // subtraction discards the final carry, addition keeps it as digit 4
    assign result = {(op ? 4'b0 : {3'b0, c3}), s3, s2, s1, s0};
endmodule


// Controller FSM
// IDLE     - checks header when not in lockout window
// COMPUTE  - latch fields, load PISO (1 cycle)
// TRANSMIT - shift out 28 bits, then back to IDLE
//
// Lockout window: after each detection we block the header check for 41
// clocks. This prevents 0x67 appearing inside A or B from causing a
// false trigger. The window is checked as lockout <= 1 (not lockout == 0)
// because the last bit of the next packet arrives when lockout still equals 1.
module Controller(
    input  wire        clock,
    input  wire        reset,
    input  wire [40:0] sipo_data,
    input  wire [19:0] alu_result,
    output reg         piso_load,
    output reg         piso_shift,
    output reg  [27:0] piso_data,
    output reg         op,
    output reg  [15:0] A,
    output reg  [15:0] B
);
    localparam IDLE     = 2'd0;
    localparam COMPUTE  = 2'd1;
    localparam TRANSMIT = 2'd2;

    reg [1:0] state;
    reg [5:0] lockout;
    reg [4:0] tx_count;

    wire header_valid = (sipo_data[40:33] == 8'h67);
    // allow detection when lockout has wound down to 1 or 0
    wire can_detect   = (lockout <= 6'd1);

    always @(posedge clock) begin
        if (reset) begin
            state      <= IDLE;
            piso_load  <= 0;
            piso_shift <= 0;
            piso_data  <= 28'b0;
            tx_count   <= 5'd0;
            lockout    <= 6'd0;
            op         <= 0;
            A          <= 16'b0;
            B          <= 16'b0;
        end else begin
            piso_load  <= 0;
            piso_shift <= 0;

            if (lockout != 6'd0)
                lockout <= lockout - 6'd1;

            case (state)
                IDLE: begin
                    if (header_valid && can_detect) begin
                        op      <= sipo_data[32];
                        A       <= sipo_data[31:16];
                        B       <= sipo_data[15:0];
                        lockout <= 6'd41;
                        state   <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    piso_data <= {8'hA5, alu_result};
                    piso_load <= 1;
                    tx_count  <= 5'd27;
                    state     <= TRANSMIT;
                end

                TRANSMIT: begin
                    piso_shift <= 1;
                    if (tx_count == 5'd0)
                        state <= IDLE;
                    else
                        tx_count <= tx_count - 5'd1;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
