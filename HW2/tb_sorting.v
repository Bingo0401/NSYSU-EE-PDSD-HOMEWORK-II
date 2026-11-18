`timescale 1ns/1ps

//coded by Bingo
module tb;

reg  [7:0] a0, a1, a2;
wire [7:0] max, med, min;
reg  [7:0] exp_max, exp_med, exp_min;

// Unit Under Test
sorting UUT (
    .a0(a0), .a1(a1), .a2(a2),
    .max(max), .med(med), .min(min)
);

parameter integer HOLD_NS = 5;
parameter integer SETTLE_NS = 5;

integer errors = 0;
integer total_tests = 0;
integer all_errors = 0;
integer all_total_tests = 0;
integer bit_index;

// Reference model: insertion sort the three complete input values.
task automatic calculate_expected_value;
    reg [7:0] values [0:2];
    reg [7:0] key;
    integer i, j;
    begin
        values[0] = a0;
        values[1] = a1;
        values[2] = a2;
        for (i = 1; i < 3; i = i + 1) begin
            key = values[i];
            j = i - 1;
            while ((j >= 0) && (values[j] > key)) begin
                values[j + 1] = values[j];
                j = j - 1;
            end
            values[j + 1] = key;
        end
        exp_min = values[0];
        exp_med = values[1];
        exp_max = values[2];
    end
endtask

task automatic run_case;
    input [8*80-1:0] desc;
    input [7:0] in0, in1, in2;
    input verbose;
    begin
        a0 = in0;
        a1 = in1;
        a2 = in2;
        calculate_expected_value();
        #(SETTLE_NS);

        // Case inequality also detects unknown or high-impedance outputs.
        if ((max !== exp_max) || (med !== exp_med) || (min !== exp_min)) begin
            errors = errors + 1;
            if (verbose)
                $display("| %10d | FAIL | %b | %b | %b | %b | %b | %b | %b | %b | %b | %0s",
                         $time, a0, a1, a2, max, med, min, exp_max, exp_med, exp_min, desc);
            else
                $display("FAIL: inputs=%b %b %b | max=%b med=%b min=%b | expected max=%b med=%b min=%b | %0s",
                         a0, a1, a2, max, med, min, exp_max, exp_med, exp_min, desc);
        end else if (verbose) begin
            $display("| %10d | PASS | %b | %b | %b | %b | %b | %b | %b | %b | %b | %0s",
                     $time, a0, a1, a2, max, med, min, exp_max, exp_med, exp_min, desc);
        end

        #(HOLD_NS);
        total_tests = total_tests + 1;
    end
endtask

task automatic run_all_cases;
    integer i0, i1, i2;
    begin
        errors = 0;
        total_tests = 0;

        // Each input has eight valid one-hot values: 8^3 = 512 cases.
        for (i0 = 0; i0 < 8; i0 = i0 + 1)
            for (i1 = 0; i1 < 8; i1 = i1 + 1)
                for (i2 = 0; i2 < 8; i2 = i2 + 1)
                    run_case("Exhaustive one-hot sorting sweep",
                             8'b00000001 << i0, 8'b00000001 << i1,
                             8'b00000001 << i2, 1'b0);

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
    //$dumpfile("tb_sorting.vcd");
    //$dumpvars(0, tb);
    $fsdbDumpfile("tb_sorting.fsdb");
    $fsdbDumpvars(0, tb);

    $display("This is a very awesome testbench designed by Bingo");
    $display("beginning test...............");
    $display("Inputs settle for %0dns, then hold for %0dns per case.",
             SETTLE_NS, HOLD_NS);
    $display("[ALL CASES]--------------------------------------------------");
    run_all_cases();

    $display("[SELECTED CASES]---------------------------------------------");
    $display("|   Time(ns) | TEST |    a0    |    a1    |    a2    |   max    |   med    |   min    | EXP_MAX  | EXP_MED  | EXP_MIN  | Description");
    errors = 0;
    total_tests = 0;

    // All six orderings of three distinct values, including both limits.
    run_case("Ascending: a0 < a1 < a2", 8'h01, 8'h10, 8'h80, 1'b1);
    run_case("Order: a0 < a2 < a1", 8'h01, 8'h80, 8'h10, 1'b1);
    run_case("Order: a1 < a0 < a2", 8'h10, 8'h01, 8'h80, 1'b1);
    run_case("Order: a2 < a0 < a1", 8'h10, 8'h80, 8'h01, 1'b1);
    run_case("Order: a1 < a2 < a0", 8'h80, 8'h01, 8'h10, 1'b1);
    run_case("Descending: a2 < a1 < a0", 8'h80, 8'h10, 8'h01, 1'b1);

    // Every one-hot value with all three inputs equal.
    for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
        run_case("All three inputs equal", 8'b00000001 << bit_index,
                 8'b00000001 << bit_index, 8'b00000001 << bit_index, 1'b1);

    // A repeated minimum or maximum in every possible pair of positions.
    run_case("Repeated minimum: a0 = a1", 8'h01, 8'h01, 8'h80, 1'b1);
    run_case("Repeated minimum: a0 = a2", 8'h01, 8'h80, 8'h01, 1'b1);
    run_case("Repeated minimum: a1 = a2", 8'h80, 8'h01, 8'h01, 1'b1);
    run_case("Repeated maximum: a0 = a1", 8'h80, 8'h80, 8'h01, 1'b1);
    run_case("Repeated maximum: a0 = a2", 8'h80, 8'h01, 8'h80, 1'b1);
    run_case("Repeated maximum: a1 = a2", 8'h01, 8'h80, 8'h80, 1'b1);

    if (errors == 0)
        $display("SELECTED SUMMARY: PASS (%0d tests)", total_tests);
    else
        $display("SELECTED SUMMARY: FAIL (%0d errors out of %0d tests)",
                 errors, total_tests);

    if ((all_errors + errors) != 0) begin
        $display("SORTING SUMMARY: FAIL (%0d errors out of %0d tests)",
                 all_errors + errors, all_total_tests + total_tests);
    end else begin
        $display("SORTING SUMMARY: PASS (%0d tests)", all_total_tests + total_tests);
    end
    $finish;
end

endmodule

//coded by Bingo
