`timescale 1ns/1ps

module tb;
reg [15:0] A, B;
reg M; //
wire [15:0] SUM;
wire C_out;
localparam SETTLE_NS = 32;
localparam HOLD_NS = 10;
reg [63:0] errors, total;
integer i, j, k;
integer seed;
reg [15:0] random_a, random_b;
reg random_m;

adder UUT(.A(A), .B(B), .M(M), .sum(SUM), .c_out(C_out));

task automatic run_case;
    input [8*80-1:0] desc;
    input [15:0] a_in, b_in;
    input m_in;
    input verbose;
    reg [16:0] expected;
    reg expected_c;
    //reg expected_v;
    //integer signed_a, signed_b, signed_result;
    begin
        A = a_in;
        B = b_in;
        M = m_in;
        #(SETTLE_NS);
        //signed_a = a_in[15] ? a_in - 65536 : a_in;
        //signed_b = b_in[15] ? b_in - 65536 : b_in;
        if (m_in == 0) begin
            expected = {1'b0, a_in} + {1'b0, b_in};
            expected_c = expected[16];
            //signed_result = signed_a + signed_b;
        end else begin
            expected = {1'b0, a_in} - {1'b0, b_in};
            expected_c = (a_in >= b_in);
            //signed_result = signed_a - signed_b;
        end
        //expected_v = (signed_result > 32767) || (signed_result < -32768);
        total = total + 1;
        if ((SUM !== expected[15:0]) || (C_out !== expected_c)) begin
            errors = errors + 1;
            if (verbose)
                $display("| %10d | FAIL | %1b | %4h | %4h | %4h |   %1b   | %4h    |   %1b   | %0s",
                         $time, M, A, B, SUM, C_out, expected[15:0], expected_c, desc);
            else
                $display("FAIL: M=%1b A=%4h B=%4h SUM=%4h C_out=%1b EXP_SUM=%4h EXP_C=%1b | %0s",
                         M, A, B, SUM, C_out, expected[15:0], expected_c, desc);
        end else if (verbose)
            $display("| %10d | PASS | %1b | %4h | %4h | %4h |   %1b   | %4h    |   %1b   | %0s",
                     $time, M, A, B, SUM, C_out, expected[15:0], expected_c, desc);
        #(HOLD_NS);
    end
endtask

task automatic run_random_cases;
    begin
        for (k = 0; k < 4; k = k + 1)
            for (i = 0; i < 16; i = i + 1)
                for (j = 0; j < 16; j = j + 1) begin
                    run_case("Block addition sweep", (i << (4*k)) | ((1 << (4*k))-1),
                             (j << (4*k)) | 1, 0, 0);
                    run_case("Block subtraction sweep", i << (4*k),
                             (j << (4*k)) | 1, 1, 0);
                end
        for (i = 0; i < 10000; i = i + 1) begin
            random_a = $random(seed);
            random_b = $random(seed);
            random_m = $random(seed);
            run_case("Random full-width operands", random_a, random_b, random_m, 0);
        end
        $display("RANDOM SUMMARY: %0d checks, %0d errors", total, errors);
    end
endtask

initial begin
    errors = 0;
    total = 0;
    seed = 133015012;

    //WaveForm File
    //$fsdbDumpfile("tb.fsdb");
    //$fsdbDumpvars(0, tb);
    //$dumpfile("tb.vcd");
    //$dumpvars(0, tb);

    $display("This is a very awesome testbench designed by Bingo");
    $display("beginning test...............");

    $display("Each case is held for %0dns for clear waveform time frames.", HOLD_NS, "\n");
    $display("Testing...................");
    $display("[RANDOM CASES]-------------------------------------------------------------------------------------------");
    run_random_cases();

    $display("[SELECTED CASES]-------------------------------------------------------------------------------------------");
    $display("|   Time(ns) | TEST | M |  A   |  B   | SUM  | C_out | EXP_SUM | EXP_C | Description");

    run_case("ADD basic", 16'h1234, 16'h4321, 0, 1);
    run_case("ADD zero", 16'h0000, 16'h0000, 0, 1);
    run_case("ADD carry out", 16'hffff, 16'h0001, 0, 1);
    run_case("ADD max plus max", 16'hffff, 16'hffff, 0, 1);
    run_case("ADD positive signed overflow", 16'h7fff, 16'h0001, 0, 1);
    run_case("ADD negative signed overflow", 16'h8000, 16'h8000, 0, 1);
    run_case("SUB basic", 16'h4321, 16'h1234, 1, 1);
    run_case("SUB borrow", 16'h0000, 16'h0001, 1, 1);
    run_case("SUB unsigned underflow edge", 16'h0000, 16'hffff, 1, 1);
    run_case("SUB negative signed overflow", 16'h8000, 16'h0001, 1, 1);
    run_case("SUB positive signed overflow", 16'h7fff, 16'hffff, 1, 1);
    run_case("ADD identity", 16'ha5a5, 16'h0000, 0, 1);
    run_case("SUB identity", 16'ha5a5, 16'h0000, 1, 1);
    run_case("SUB self", 16'h5c5c, 16'h5c5c, 1, 1);
    run_case("ADD alternating bits", 16'h5555, 16'haaaa, 0, 1);
    run_case("SUB alternating bits", 16'haaaa, 16'h5555, 1, 1);

    for (i = 4; i <= 12; i = i + 4) begin
        run_case("ADD across block boundary", (1 << i)-1, 16'h0001, 0, 1);
        run_case("SUB across block boundary", (1 << i), 16'h0001, 1, 1);
    end
    run_case("Carry propagation baseline", 16'hffff, 16'h0000, 0, 1);
    run_case("Carry propagation transition", 16'hffff, 16'h0001, 0, 1);
    run_case("Mode transition add", 16'h5aa5, 16'h1234, 0, 1);
    run_case("Mode transition subtract", 16'h5aa5, 16'h1234, 1, 1);

    $display("SUMMARY: %0d checks, %0d errors", total, errors);
    if (errors != 0)
        $display("RESULT: FAIL");
    else
        $display("RESULT: PASS");
    $finish;
end
endmodule
//coded by Bingo
