//===============================================================================//
//            PLEASE DO NOT modify basic I/O name or top module name!            // 
//===============================================================================//




/*
module sorting (a0, a1, a2, max, med, min);

input    [7:0]   a0, a1, a2;

output   [7:0]   max,med,min;

//====================================================================
//======================= enter your code here =======================

wire [7:0] local_min, local_max, local_med;
wire a0_le_a1, local_max_le_a2, local_min_le_local_med;

// The comparator's greater output means >=. Swap inputs to obtain <=.
comparator_8bit u_cmp_a0_a1 (
    .a(a1), .b(a0), .greater(a0_le_a1), .less()
);

mux_2to1 u_mux_local_min (
    .a(a0), .b(a1), .sel(a0_le_a1), .c(local_min)
);
mux_2to1 u_mux_local_max (
    .a(a1), .b(a0), .sel(a0_le_a1), .c(local_max)
);

comparator_8bit u_cmp_local_max_a2 (
    .a(a2), .b(local_max), .greater(local_max_le_a2), .less()
);

mux_2to1 u_mux_max (
    .a(a2), .b(local_max), .sel(local_max_le_a2), .c(max)
);
mux_2to1 u_mux_local_med (
    .a(local_max), .b(a2), .sel(local_max_le_a2), .c(local_med)
);

comparator_8bit u_cmp_local_min_local_med (
    .a(local_med), .b(local_min), .greater(local_min_le_local_med), .less()
);

mux_2to1 u_mux_min (
    .a(local_min), .b(local_med), .sel(local_min_le_local_med), .c(min)
);
mux_2to1 u_mux_med (
    .a(local_med), .b(local_min), .sel(local_min_le_local_med), .c(med)
);

//====================================================================

endmodule


//===============================================================================================
//========================================Building Blocks========================================
//===============================================================================================

//sourced from Github Repo:https://github.com/Bingo0401/verilog_modules

// Unsigned 8-bit magnitude comparison.
module comparator_8bit(
    input [7:0] a,
    input [7:0] b,
    output greater,
//    output equal,
    output less
);
//    assign greater = a > b;
    assign greater = (a > b || a == b);
//    assign equal = a == b;
    assign less = a < b;
endmodule



module mux_2to1(a, b, sel, c);
    input [7:0] a, b;
    input sel;
    output [7:0] c;
    wire [7:0] g0, g1;


    assign c = g0|g1;
    assign g0 = a & {8{sel}};
    assign g1 = b & {8{!sel}};
endmodule


*/










module sorting (a0, a1, a2, max, med, min);

input    [7:0]   a0, a1, a2;

output   [7:0]   max,med,min;

//====================================================================
//======================= enter your code here =======================

wire [7:0] local_min, local_max, local_med;


assign local_min = (a0 <= a1) ? a0 : a1;
assign local_max = (a0 <= a1) ? a1 : a0;

assign max = (local_max <= a2) ? a2 : local_max;
assign local_med = (local_max <= a2) ? local_max : a2;


assign min = (local_min <= local_med) ? local_min : local_med;
assign med = (local_min <= local_med) ? local_med : local_min;

//====================================================================

endmodule


//coded by Bingo
