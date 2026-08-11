// ============================================================================
// Module:  fp_multiplier_tb
// Project: Ray-Sphere Intersection Accelerator (RTU)
// ============================================================================
//
// DESCRIPTION:
//   Testbench for the 2-stage pipelined Q16.16 fixed-point multiplier.
//
//   Test coverage:
//     1.  Basic positive x positive
//     2.  Positive x negative
//     3.  Negative x negative (double negative -> positive)
//     4.  Multiply by zero
//     5.  Multiply by 1.0 (identity)
//     6.  Multiply by -1.0
//     7.  Fractional values (< 1.0)
//     8.  Small fractions (Q truncation tolerance check)
//     9.  Large values near overflow boundary
//     10. Pipeline throughput -- back-to-back valid_in with no gaps
//     11. valid_in de-asserted mid-stream (bubble test)
//     12. Reset mid-operation
//
//   Q16.16 encoding:
//     real -> Q16.16 : $rtoi(real_val * 65536.0)
//     Q16.16 -> real : $itor(q_val)  / 65536.0
//
// ============================================================================
`timescale 1ns/1ps

module fp_multiplier_tb;

    // -----------------------------------------------------------------------
    // DUT signals
    // -----------------------------------------------------------------------
    reg                clk;
    reg                rst_n;
    reg  signed [31:0] a;
    reg  signed [31:0] b;
    reg                valid_in;

    wire               valid_out;
    wire signed [31:0] product;
    wire signed [63:0] product_full;

    // -----------------------------------------------------------------------
    // Instantiate DUT
    // -----------------------------------------------------------------------
    fp_multiplier dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .a            (a),
        .b            (b),
        .valid_in     (valid_in),
        .valid_out    (valid_out),
        .product      (product),
        .product_full (product_full)
    );

    // -----------------------------------------------------------------------
    // Clock: 10 ns period (100 MHz)
    // -----------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -----------------------------------------------------------------------
    // Q16.16 encode / decode helpers
    // -----------------------------------------------------------------------
    function signed [31:0] to_q16;
        input real val;
        begin
            to_q16 = $rtoi(val * 65536.0);
        end
    endfunction

    function real from_q16;
        input signed [31:0] val;
        begin
            from_q16 = $itor(val) / 65536.0;
        end
    endfunction

    // -----------------------------------------------------------------------
    // Test tracking
    // -----------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    // Check result against expected value within tolerance
    task check_result;
        input real      expected;
        input real      tolerance;
        input [127:0]   test_name;
        real got;
        real err;
        begin
            got = from_q16(product);
            err = got - expected;
            if (err < 0.0) err = -err;
            if (err <= tolerance) begin
                $display("  PASS  [%0s]  expected=%.5f  got=%.5f",
                          test_name, expected, got);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL  [%0s]  expected=%.5f  got=%.5f  err=%.6f",
                          test_name, expected, got, err);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Drive one input pair, then advance 2 clock edges so the result is ready
    task apply_and_wait;
        input real val_a;
        input real val_b;
        begin
            @(negedge clk);
            a        = to_q16(val_a);
            b        = to_q16(val_b);
            valid_in = 1'b1;
            @(negedge clk);   // cycle 1: Stage 1 captures inputs
            valid_in = 1'b0;
            a        = 32'b0;
            b        = 32'b0;
            @(negedge clk);   // cycle 2: Stage 2 produces result
        end
    endtask

    // -----------------------------------------------------------------------
    // Stimulus
    // -----------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Reset for 3 cycles
        rst_n    = 1'b0;
        a        = 32'b0;
        b        = 32'b0;
        valid_in = 1'b0;
        repeat(3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        $display("==============================================");
        $display(" fp_multiplier testbench  (2-stage pipeline)");
        $display("==============================================");

        // ------------------------------------------------------------------
        // TEST 1: 2.0 x 3.0 = 6.0
        // ------------------------------------------------------------------
        $display("\n--- Test 1: 2.0 x 3.0 ---");
        apply_and_wait(2.0, 3.0);
        check_result(6.0, 0.0001, "2.0x3.0");

        // ------------------------------------------------------------------
        // TEST 2: 1.5 x -2.0 = -3.0
        // ------------------------------------------------------------------
        $display("\n--- Test 2: 1.5 x -2.0 ---");
        apply_and_wait(1.5, -2.0);
        check_result(-3.0, 0.0001, "1.5x-2.0");

        // ------------------------------------------------------------------
        // TEST 3: -4.0 x -2.5 = 10.0
        // ------------------------------------------------------------------
        $display("\n--- Test 3: -4.0 x -2.5 ---");
        apply_and_wait(-4.0, -2.5);
        check_result(10.0, 0.0001, "-4.0x-2.5");

        // ------------------------------------------------------------------
        // TEST 4: 99.0 x 0.0 = 0.0
        // ------------------------------------------------------------------
        $display("\n--- Test 4: 99.0 x 0.0 ---");
        apply_and_wait(99.0, 0.0);
        check_result(0.0, 0.0001, "99.0x0.0");

        // ------------------------------------------------------------------
        // TEST 5: 7.25 x 1.0 = 7.25  (identity)
        // ------------------------------------------------------------------
        $display("\n--- Test 5: 7.25 x 1.0 (identity) ---");
        apply_and_wait(7.25, 1.0);
        check_result(7.25, 0.0001, "7.25x1.0");

        // ------------------------------------------------------------------
        // TEST 6: 7.25 x -1.0 = -7.25
        // ------------------------------------------------------------------
        $display("\n--- Test 6: 7.25 x -1.0 ---");
        apply_and_wait(7.25, -1.0);
        check_result(-7.25, 0.0001, "7.25x-1.0");

        // ------------------------------------------------------------------
        // TEST 7: 0.5 x 0.5 = 0.25
        // ------------------------------------------------------------------
        $display("\n--- Test 7: 0.5 x 0.5 (fractional) ---");
        apply_and_wait(0.5, 0.5);
        check_result(0.25, 0.0001, "0.5x0.5");

        // ------------------------------------------------------------------
        // TEST 8: 0.1 x 0.3 ~ 0.03  (wider tolerance for Q truncation)
        // ------------------------------------------------------------------
        $display("\n--- Test 8: 0.1 x 0.3 (small fractions) ---");
        apply_and_wait(0.1, 0.3);
        check_result(0.03, 0.0002, "0.1x0.3");

        // ------------------------------------------------------------------
        // TEST 9: 100.0 x 100.0 = 10000.0
        // ------------------------------------------------------------------
        $display("\n--- Test 9: 100.0 x 100.0 (large values) ---");
        apply_and_wait(100.0, 100.0);
        check_result(10000.0, 0.01, "100x100");

        // ------------------------------------------------------------------
        // TEST 10: Back-to-back throughput
        //   Inputs : (1,2), (3,4), (5,6)
        //   Outputs: 2.0,   12.0,  30.0
        // ------------------------------------------------------------------
        $display("\n--- Test 10: Back-to-back pipeline throughput ---");
        begin
            // Cycle 0: load pair 0
            @(negedge clk);
            a = to_q16(1.0); b = to_q16(2.0); valid_in = 1'b1;
            // Cycle 1: Stage 1 of pair 0; load pair 1
            @(negedge clk);
            a = to_q16(3.0); b = to_q16(4.0); valid_in = 1'b1;
            // Cycle 2: pair 0 result ready; Stage 1 of pair 1; load pair 2
            @(negedge clk);
            check_result(2.0, 0.0001, "thru[0] 1x2");
            a = to_q16(5.0); b = to_q16(6.0); valid_in = 1'b1;
            // Cycle 3: pair 1 result ready
            @(negedge clk);
            check_result(12.0, 0.0001, "thru[1] 3x4");
            valid_in = 1'b0; a = 32'b0; b = 32'b0;
            // Cycle 4: pair 2 result ready
            @(negedge clk);
            check_result(30.0, 0.0001, "thru[2] 5x6");
        end

        // ------------------------------------------------------------------
        // TEST 11: Bubble -- valid_in low for one cycle between two ops
        // ------------------------------------------------------------------
        $display("\n--- Test 11: Bubble (valid_in gap) ---");
        begin
            // Op A
            @(negedge clk);
            a = to_q16(2.0); b = to_q16(3.0); valid_in = 1'b1;
            @(negedge clk);
            a = 32'b0; b = 32'b0; valid_in = 1'b0;  // bubble
            @(negedge clk);  // Op A result arrives
            check_result(6.0, 0.0001, "bubble_opA");

            // Op B
            @(negedge clk);
            a = to_q16(4.0); b = to_q16(5.0); valid_in = 1'b1;
            @(negedge clk);
            a = 32'b0; b = 32'b0; valid_in = 1'b0;
            @(negedge clk);  // bubble drains -- valid_out must be 0
            if (valid_out !== 1'b0) begin
                $display("  FAIL  [bubble_valid]  valid_out should be 0 during bubble, got %b",
                          valid_out);
                fail_count = fail_count + 1;
            end else begin
                $display("  PASS  [bubble_valid]  valid_out correctly 0 during bubble");
                pass_count = pass_count + 1;
            end
            @(negedge clk);  // Op B result arrives
            check_result(20.0, 0.0001, "bubble_opB");
        end

        // ------------------------------------------------------------------
        // TEST 12: Reset mid-operation
        // ------------------------------------------------------------------
        $display("\n--- Test 12: Reset mid-operation ---");
        begin
            @(negedge clk);
            a = to_q16(99.0); b = to_q16(99.0); valid_in = 1'b1;
            @(negedge clk);        // Stage 1 has latched inputs
            rst_n    = 1'b0;       // assert reset
            valid_in = 1'b0;
            @(negedge clk);        // reset clears Stage 2 registers
            rst_n = 1'b1;
            @(negedge clk);        // first clean cycle post-reset

            if (valid_out !== 1'b0) begin
                $display("  FAIL  [reset_valid]   valid_out should be 0 after reset, got %b",
                          valid_out);
                fail_count = fail_count + 1;
            end else begin
                $display("  PASS  [reset_valid]   valid_out correctly 0 after reset");
                pass_count = pass_count + 1;
            end

            if (product !== 32'b0) begin
                $display("  FAIL  [reset_product] product should be 0 after reset, got 0x%0h",
                          product);
                fail_count = fail_count + 1;
            end else begin
                $display("  PASS  [reset_product] product correctly 0 after reset");
                pass_count = pass_count + 1;
            end
        end

        // ------------------------------------------------------------------
        // Summary
        // ------------------------------------------------------------------
        $display("\n==============================================");
        $display(" Results:  %0d passed,  %0d failed", pass_count, fail_count);
        $display("==============================================");
        if (fail_count == 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" SOME TESTS FAILED -- check output above");

        $finish;
    end

    // -----------------------------------------------------------------------
    // Watchdog -- kills sim if it hangs
    // -----------------------------------------------------------------------
    initial begin
        #50000;
        $display("TIMEOUT: simulation exceeded time limit");
        $finish;
    end

endmodule
