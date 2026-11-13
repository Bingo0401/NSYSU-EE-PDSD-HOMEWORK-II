//===============================================================================//
//            PLEASE DO NOT modify basic I/O name or top module name!            // 
//===============================================================================//

module voting (a0, a1, a2, a3, a4, out, count);

input    [2:0]   a0, a1, a2, a3, a4;

output   [2:0]   out, count;

// Sum the votes for each one-hot value using the 5-bit counter.
wire [2:0] votes_100, votes_010, votes_001;
wire select_100, select_010;

count_five u_count_100 (
    .in0(a0[2]),
    .in1(a1[2]),
    .in2(a2[2]),
    .in3(a3[2]),
    .in4(a4[2]),
    .out(votes_100)
);

count_five u_count_010 (
    .in0(a0[1]),
    .in1(a1[1]),
    .in2(a2[1]),
    .in3(a3[1]),
    .in4(a4[1]),
    .out(votes_010)
);

count_five u_count_001 (
    .in0(a0[0]),
    .in1(a1[0]),
    .in2(a2[0]),
    .in3(a3[0]),
    .in4(a4[0]),
    .out(votes_001)
);

// Comparators and multiplexers select the winner and its vote total.
// Tie priority: 100, then 010, then 001.
wire cmp_100_ge_010, cmp_100_lt_010;
wire cmp_100_ge_001, cmp_100_lt_001;
wire cmp_010_ge_001, cmp_010_lt_001;

comparator_3bit u_cmp_100_010 (
    .a(votes_100),
    .b(votes_010),
    .greater(cmp_100_ge_010),
    .less(cmp_100_lt_010)
);

comparator_3bit u_cmp_100_001 (
    .a(votes_100),
    .b(votes_001),
    .greater(cmp_100_ge_001),
    .less(cmp_100_lt_001)
);

comparator_3bit u_cmp_010_001 (
    .a(votes_010),
    .b(votes_001),
    .greater(cmp_010_ge_001),
    .less(cmp_010_lt_001)
);

//and gate
assign select_100 = cmp_100_ge_010 && cmp_100_ge_001;
assign select_010 = (~cmp_100_ge_010) && cmp_010_ge_001;

//mux? 
assign out = select_100 ? 3'b100 : (select_010 ? 3'b010 : 3'b001);
assign count = select_100 ? votes_100 : (select_010 ? votes_010 : votes_001);

endmodule




//===============================================================================================
//========================================Building Blocks========================================
//===============================================================================================

//sourced from Github Repo:https://github.com/Bingo0401/verilog_modules


//=====================module 1=====================
//count five
//takes five bits and return a three bit output of how many bits are 1
module count_five (
    input  wire in0, in1, in2, in3, in4,
    output wire [2:0] out
);

    assign out = {2'b00, in0} + {2'b00, in1} +
                 {2'b00, in2} + {2'b00, in3} +
                 {2'b00, in4};

endmodule


//=====================module 2=====================
// Unsigned 3-bit magnitude comparator.
module comparator_3bit(
    input [2:0] a,
    input [2:0] b,
    output greater,
//    output equal,
    output less
);
//    assign greater = a > b;
    assign greater = (a > b || a == b);
//    assign equal = a == b;
    assign less = a < b;
endmodule


//=========================================================================================================
//========================================One Module Implementation========================================
//=========================================================================================================

/*
version made without submodules

module voting (a0, a1, a2, a3, a4, out, count);

input    [2:0]   a0, a1, a2, a3, a4;

output   [2:0]   out, count;


wire [2:0] votes_100, votes_010, votes_001;
wire select_100, select_010;

assign votes_100 = {2'b00, a0[2]} + {2'b00, a1[2]} +
                   {2'b00, a2[2]} + {2'b00, a3[2]} + {2'b00, a4[2]};
assign votes_010 = {2'b00, a0[1]} + {2'b00, a1[1]} +
                   {2'b00, a2[1]} + {2'b00, a3[1]} + {2'b00, a4[1]};
assign votes_001 = {2'b00, a0[0]} + {2'b00, a1[0]} +
                   {2'b00, a2[0]} + {2'b00, a3[0]} + {2'b00, a4[0]};

assign select_100 = (votes_100 >= votes_010) && (votes_100 >= votes_001);
assign select_010 = (votes_010 >= votes_001);
assign out = select_100 ? 3'b100 : (select_010 ? 3'b010 : 3'b001);
assign count = select_100 ? votes_100 : (select_010 ? votes_010 : votes_001);

endmodule

*/
//coded by Bingo
