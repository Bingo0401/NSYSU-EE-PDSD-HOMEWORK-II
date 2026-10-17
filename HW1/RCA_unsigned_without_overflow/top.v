`timescale 1ns/1ps

module adder(A, B, M, sum, c_out);
input [15:0] A, B;
input M;
output [15:0] sum;
output c_out;
wire [15:0] B_selected;
wire [2:0] C_block;
wire [3:0] C_msb;

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

four_bit_rca Block0(.A(A[3:0]), .B(B_selected[3:0]),
    .Cin(M), .S(sum[3:0]), .Cout(C_block[0]), .C_msb(C_msb[0]));
four_bit_rca Block1(.A(A[7:4]), .B(B_selected[7:4]),
    .Cin(C_block[0]), .S(sum[7:4]), .Cout(C_block[1]), .C_msb(C_msb[1]));
four_bit_rca Block2(.A(A[11:8]), .B(B_selected[11:8]),
    .Cin(C_block[1]), .S(sum[11:8]), .Cout(C_block[2]), .C_msb(C_msb[2]));
four_bit_rca Block3(.A(A[15:12]), .B(B_selected[15:12]),
    .Cin(C_block[2]), .S(sum[15:12]), .Cout(c_out), .C_msb(C_msb[3]));
endmodule

module full_adder(A, B, Cin, Cout, S);
input A, B, Cin;
output Cout, S;

wire axb;
wire ab;
wire cin_axb;

xor #5 X1(axb, A, B);
xor #5 X2(S, axb, Cin);

and #2 A1(ab, A, B);
and #2 A2(cin_axb, Cin, axb);
or  #2 O1(Cout, ab, cin_axb);

endmodule


//using four bits adder as basic building block
module four_bit_rca(A, B, Cin, S, Cout, C_msb);
input [3:0] A, B;
input Cin;
output [3:0] S;
output Cout, C_msb;
wire [1:0] C;

full_adder FA0(A[0], B[0], Cin, C[0], S[0]);
full_adder FA1(A[1], B[1], C[0], C[1], S[1]);
full_adder FA2(A[2], B[2], C[1], C_msb, S[2]);
full_adder FA3(A[3], B[3], C_msb, Cout, S[3]);
endmodule


//coded by Bingo