`timescale 1ns/1ps

module adder(A, B, M, sum, c_out, overflow);
input [15:0] A, B;
input M;
output [15:0] sum;
output c_out;
output overflow;
wire [15:0] B_selected;
wire [2:0] C_block;
wire [3:0] C_msb;
wire [3:0] PG, GG;
wire [3:0] local_cout;

//mode select logic
//tried using mux but it didnt do anthing better
xor #5 XOR0(B_selected[0], B[0], M);
xor #5 XOR1(B_selected[1], B[1], M);
xor #5 XOR2(B_selected[2], B[2], M);
xor #5 XOR3(B_selected[3], B[3], M);
xor #5 XOR4(B_selected[4], B[4], M);
xor #5 XOR5(B_selected[5], B[5], M);
xor #5 XOR6(B_selected[6], B[6], M);
xor #5 XOR7(B_selected[7], B[7], M);
xor #5 XOR8(B_selected[8], B[8], M);
xor #5 XOR9(B_selected[9], B[9], M);
xor #5 XOR10(B_selected[10], B[10], M);
xor #5 XOR11(B_selected[11], B[11], M);
xor #5 XOR12(B_selected[12], B[12], M);
xor #5 XOR13(B_selected[13], B[13], M);
xor #5 XOR14(B_selected[14], B[14], M);
xor #5 XOR15(B_selected[15], B[15], M);


//combining 4 4-bit adders 
//tsmc only has 6 input and gates, sad :(
four_bit_cla Block0(.A(A[3:0]), .B(B_selected[3:0]),
    .Cin(M), .S(sum[3:0]), .Cout(local_cout[0]), .C_msb(C_msb[0]), .PG(PG[0]), .GG(GG[0]));
four_bit_cla Block1(.A(A[7:4]), .B(B_selected[7:4]),
    .Cin(C_block[0]), .S(sum[7:4]), .Cout(local_cout[1]), .C_msb(C_msb[1]), .PG(PG[1]), .GG(GG[1]));
four_bit_cla Block2(.A(A[11:8]), .B(B_selected[11:8]),
    .Cin(C_block[1]), .S(sum[11:8]), .Cout(local_cout[2]), .C_msb(C_msb[2]), .PG(PG[2]), .GG(GG[2]));
four_bit_cla Block3(.A(A[15:12]), .B(B_selected[15:12]),
    .Cin(C_block[2]), .S(sum[15:12]), .Cout(local_cout[3]), .C_msb(C_msb[3]), .PG(PG[3]), .GG(GG[3]));

four_bit_carry_lookahead_generator Block_CLAG(M, PG, GG, {c_out, C_block});

//overflow logic
xor #5 XORV(overflow, C_msb[3], c_out);
endmodule


//no_Cout_adder (designed by Bingo)
module no_Cout_adder(A, B, Cin, S, P, G);
input A, B, Cin;
output S, P, G;
xor #5 X1(P, A, B);
xor #5 X2(S, P, Cin);
and #2 A1(G, A, B);
endmodule

module four_bit_carry_lookahead_generator(Cin, P, G, C);
input Cin;
input [3:0] P, G;
output [3:0] C;
wire [0:0] t0;
wire [1:0] t1;
wire [2:0] t2;
wire [3:0] t3;

and #2 A01(t0[0], P[0], Cin);
or  #2 O0(C[0], G[0], t0[0]);
and #2 A11(t1[0], P[1], G[0]);
and #2 A12(t1[1], P[1], P[0], Cin);
or  #2 O1(C[1], G[1], t1[0], t1[1]);
and #2 A21(t2[0], P[2], G[1]);
and #2 A22(t2[1], P[2], P[1], G[0]);
and #2 A23(t2[2], P[2], P[1], P[0], Cin);
or  #2 O2(C[2], G[2], t2[0], t2[1], t2[2]);
and #2 A31(t3[0], P[3], G[2]);
and #2 A32(t3[1], P[3], P[2], G[1]);
and #2 A33(t3[2], P[3], P[2], P[1], G[0]);
and #2 A34(t3[3], P[3], P[2], P[1], P[0], Cin);
or  #2 O3(C[3], G[3], t3[0], t3[1], t3[2], t3[3]);
endmodule


//using four bits adder as basic building block
//PG and GG are the carry lookahead information of the block
module four_bit_cla(A, B, Cin, S, Cout, C_msb, PG, GG);
input [3:0] A, B;
input Cin;
output [3:0] S;
output Cout, C_msb, PG, GG;
wire [3:0] P, G;
wire [1:0] C;
wire [2:0] T;

no_Cout_adder FA0(A[0], B[0], Cin, S[0], P[0], G[0]);
no_Cout_adder FA1(A[1], B[1], C[0], S[1], P[1], G[1]);
no_Cout_adder FA2(A[2], B[2], C[1], S[2], P[2], G[2]);
no_Cout_adder FA3(A[3], B[3], C_msb, S[3], P[3], G[3]);
four_bit_carry_lookahead_generator CLAG(Cin, P, G, {Cout, C_msb, C});

and #2 GP(PG, P[3], P[2], P[1], P[0]);
and #2 G0(T[0], P[3], G[2]);
and #2 G1(T[1], P[3], P[2], G[1]);
and #2 G2(T[2], P[3], P[2], P[1], G[0]);
or  #2 GG0(GG, G[3], T[0], T[1], T[2]);
endmodule


//coded by Bingo