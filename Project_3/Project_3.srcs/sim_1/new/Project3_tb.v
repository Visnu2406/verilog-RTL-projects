`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 09:52:07 PM
// Design Name: 
// Module Name: Project3_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for Serial BCD ALU
//
// Test cases:
//   TC1:  3627 + 1287 = 04914  (basic addition)
//   TC2:  9999 + 0001 = 10000  (addition overflow into 5th digit)
//   TC3:  6370 - 4590 = 01780  (basic subtraction)
//   TC4:  5000 - 5000 = 00000  (subtraction to zero)
//   TC5:  6700 - 0000 = 06700  (A upper byte = 0x67, embedded header)
//   TC6:  0670 + 0067 = 00737  (0x67 in B lower byte)
//   TC7:  6700 + 0670 = 07370  (0x67 in both operands)
//   TC8:  6767 - 6767 = 00000  (0x67 everywhere)
// 
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
module Project3_tb();

reg  clock, reset, din;
wire result;

Project3 dut (
    .clock  (clock),
    .reset  (reset),
    .din    (din),
    .result (result)
);

initial clock = 0;
always #5 clock = ~clock;

integer i, j, passes, total;
reg [40:0] pkt;
reg [27:0] cap;

// send a 41-bit packet MSB first, driving din on negedge
task send_packet;
    input        op;
    input [15:0] A, B;
    begin
        pkt = {8'h67, op, A, B};
        for (i = 40; i >= 0; i = i - 1) begin
            @(negedge clock);
            din = pkt[i];
        end
    end
endtask

// capture 28-bit output packet
// PISO is loaded on the COMPUTE posedge; result drives piso[27] that same cycle.
// We wait for piso_load then sample 28 bits starting next posedge (TRANSMIT begins).
task capture_output;
    begin
        cap = 28'b0;
        @(posedge dut.ctrl.piso_load);
        for (j = 27; j >= 0; j = j - 1) begin
            @(posedge clock); #1;
            cap[j] = result;
        end
    end
endtask

// run one test: send packet, capture output, check result
task run_test;
    input        op;
    input [15:0] A, B;
    input [19:0] expected_bcd;
    begin
        total = total + 1;
        fork
            send_packet(op, A, B);
            capture_output;
        join
        if (cap[19:0] === expected_bcd && cap[27:20] === 8'hA5) begin
            $display("  PASS  header=%02X  result=%05X", cap[27:20], cap[19:0]);
            passes = passes + 1;
        end else begin
            $display("  FAIL  got header=%02X result=%05X  expected header=A5 result=%05X",
                     cap[27:20], cap[19:0], expected_bcd);
        end
        repeat(5) @(posedge clock);
    end
endtask

initial begin
    $dumpfile("Project3_tb.vcd");
    $dumpvars(0, Project3_tb);

    passes = 0;
    total  = 0;
    din    = 0;
    reset  = 1;
    repeat(2) @(posedge clock); #1;
    reset  = 0;

    // basic tests
    $display("---- TC1: 3627 + 1287 = 04914 ----");
    run_test(1'b0, 16'h3627, 16'h1287, 20'h04914);

    $display("---- TC2: 9999 + 0001 = 10000 ----");
    run_test(1'b0, 16'h9999, 16'h0001, 20'h10000);

    $display("---- TC3: 6370 - 4590 = 01780 ----");
    run_test(1'b1, 16'h6370, 16'h4590, 20'h01780);

    $display("---- TC4: 5000 - 5000 = 00000 ----");
    run_test(1'b1, 16'h5000, 16'h5000, 20'h00000);

    // embedded header tests (0x67 inside operands)
    $display("---- TC5: 6700 - 0000 = 06700 (A upper byte = 0x67) ----");
    run_test(1'b1, 16'h6700, 16'h0000, 20'h06700);

    $display("---- TC6: 0670 + 0067 = 00737 (0x67 in B low byte) ----");
    run_test(1'b0, 16'h0670, 16'h0067, 20'h00737);

    $display("---- TC7: 6700 + 0670 = 07370 (0x67 in both operands) ----");
    run_test(1'b0, 16'h6700, 16'h0670, 20'h07370);

    $display("---- TC8: 6767 - 6767 = 00000 (0x67 everywhere) ----");
    run_test(1'b1, 16'h6767, 16'h6767, 20'h00000);

    $display("=====================================");
    $display("  %0d / %0d test cases PASSED", passes, total);
    $display("=====================================");
    $finish;
end

endmodule
