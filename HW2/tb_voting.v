`timescale 1ns/1ps

//coded by Bingo
module tb;

reg  [2:0] a0, a1, a2, a3, a4;
wire [2:0] out, count;
reg  [2:0] exp_out, exp_count;

// Unit Under Test
voting UUT (
    .a0(a0), .a1(a1), .a2(a2), .a3(a3), .a4(a4),
    .out(out), .count(count)
);

parameter integer HOLD_NS = 5;
parameter integer SETTLE_NS = 5;

integer errors = 0;
integer total_tests = 0;
integer all_errors = 0;
integer all_total_tests = 0;

// Reference model: count complete one-hot votes independently of the UUT.
// When totals tie, use the priority example for the homework pdf: 100 > 010 > 001.
task automatic calculate_expected_value;
    integer votes [0:2];
    integer i;
    reg [14:0] inputs;
    reg [2:0] vote;
    begin
        votes[0] = 0;
        votes[1] = 0;
        votes[2] = 0;
        inputs = {a4, a3, a2, a1, a0};
        for (i = 0; i < 5; i = i + 1) begin
            vote = inputs[i * 3 +: 3];
            //[starting_bit +: width] select input 
            case (vote)
                3'b001: votes[0] = votes[0] + 1;
                3'b010: votes[1] = votes[1] + 1;
                3'b100: votes[2] = votes[2] + 1;
            endcase
        end

        exp_out = 3'b100;
        exp_count = votes[2];
        for (i = 1; i >= 0; i = i - 1) begin
            if (votes[i] > exp_count) begin
                exp_out = 3'b001 << i;
                exp_count = votes[i];
            end
        end
    end
endtask

task automatic run_case;
    input [8*80-1:0] desc;
    input [2:0] in0, in1, in2, in3, in4;
    input verbose;
    begin
        a0 = in0;
        a1 = in1;
        a2 = in2;
        a3 = in3;
        a4 = in4;
        calculate_expected_value();
        #(SETTLE_NS);

        if ((out !== exp_out) || (count !== exp_count)) begin
            errors = errors + 1;
            if (verbose)
                $display("| %10d | FAIL | %b | %b | %b | %b | %b | %b |   %0d   |   %b   |     %0d     | %0s",
                         $time, a0, a1, a2, a3, a4, out, count, exp_out, exp_count, desc);
            else
                $display("FAIL: inputs=%b %b %b %b %b | out=%b count=%0d | expected out=%b count=%0d | %0s",
                         a0, a1, a2, a3, a4, out, count, exp_out, exp_count, desc);
        end else if (verbose) begin
            $display("| %10d | PASS | %b | %b | %b | %b | %b | %b |   %0d   |   %b   |     %0d     | %0s",
                     $time, a0, a1, a2, a3, a4, out, count, exp_out, exp_count, desc);
        end

        #(HOLD_NS);
        total_tests = total_tests + 1;
    end
endtask

task automatic run_all_cases;
    integer i0, i1, i2, i3, i4;
    begin
        errors = 0;
        total_tests = 0;

        // Each voter independently chooses 001, 010, or 100: 3^5 = 243
        // I dont consider this to be a exhausetive testbench
        for (i0 = 0; i0 < 3; i0 = i0 + 1)
            for (i1 = 0; i1 < 3; i1 = i1 + 1)
                for (i2 = 0; i2 < 3; i2 = i2 + 1)
                    for (i3 = 0; i3 < 3; i3 = i3 + 1)
                        for (i4 = 0; i4 < 3; i4 = i4 + 1)
                            run_case("Exhaustive one-hot vote sweep",
                                     3'b001 << i0, 3'b001 << i1,
                                     3'b001 << i2, 3'b001 << i3,
                                     3'b001 << i4, 1'b0);

        all_errors = errors;
        all_total_tests = total_tests;
        if (all_errors == 0)
            $display("ALL SUMMARY: PASS (%0d tests)", all_total_tests);
        else
            $display("ALL SUMMARY: FAIL (%0d errors out of %0d tests)",
                     all_errors, all_total_tests);
    end
endtask

initial begin

    //waveforms

    //$dumpfile("tb_voting.vcd");
    //$dumpvars(0, tb);

    $fsdbDumpfile("tb_voting.fsdb");
    $fsdbDumpvars(0, tb);

    $display("This is a very awesome testbench designed by Bingo");
    $display("beginning test...............");
    $display("Inputs settle for %0dns, then hold for %0dns per case.",
             SETTLE_NS, HOLD_NS);
    $display("[ALL CASES]--------------------------------------------------");
    run_all_cases();

    $display("[SELECTED CASES]---------------------------------------------");
    $display("|   Time(ns) | TEST | a0  | a1  | a2  | a3  | a4  | out | count | EXP_OUT | EXP_COUNT | Description");
    errors = 0;
    total_tests = 0;

    // Unanimous votes for each candidate.
    run_case("Unanimous 100 (5 votes)", 3'b100, 3'b100, 3'b100, 3'b100, 3'b100, 1'b1);
    run_case("Unanimous 010 (5 votes)", 3'b010, 3'b010, 3'b010, 3'b010, 3'b010, 1'b1);
    run_case("Unanimous 001 (5 votes)", 3'b001, 3'b001, 3'b001, 3'b001, 3'b001, 1'b1);

    // A 3-1-1 majority for each candidate.
    run_case("Majority 100 (3-1-1)", 3'b100, 3'b100, 3'b100, 3'b010, 3'b001, 1'b1);
    run_case("Majority 010 (3-1-1)", 3'b010, 3'b100, 3'b010, 3'b001, 3'b010, 1'b1);
    run_case("Majority 001 (3-1-1)", 3'b001, 3'b010, 3'b001, 3'b100, 3'b001, 1'b1);

    // All three possible 2-2-1 ties.
    run_case("Tie 100 vs 010: priority 100", 3'b100, 3'b010, 3'b100, 3'b010, 3'b001, 1'b1);
    run_case("Tie 100 vs 001: priority 100", 3'b001, 3'b100, 3'b010, 3'b001, 3'b100, 1'b1);
    run_case("Tie 010 vs 001: priority 010", 3'b010, 3'b001, 3'b100, 3'b010, 3'b001, 1'b1);

    if (errors == 0)
        $display("SELECTED SUMMARY: PASS (%0d tests)", total_tests);
    else
        $display("SELECTED SUMMARY: FAIL (%0d errors out of %0d tests)",
                 errors, total_tests);

    if ((all_errors + errors) != 0) begin
        $display("VOTING SUMMARY: FAIL (%0d errors out of %0d tests)",
               all_errors + errors, all_total_tests + total_tests);
    end else begin
        $display("VOTING SUMMARY: PASS (%0d tests)", all_total_tests + total_tests);
    end
    $finish;
end

endmodule

//coded by Bingo
