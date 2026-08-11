`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// School: NC State
// Engineer: Visnu Muthuraman
// Project Name: Dadda Multiplier (8x8)
//////////////////////////////////////////////////////////////////////////////////


// Half Adder
module HA(
    input a, b,
    output s, c
);
    xor (s, a, b);
    and (c, a, b);
endmodule



// Full Adder
module FA(
    input a, b, cin,
    output s, cout
);
    wire xor1, and1, and2;

    xor (xor1, a, b);
    xor (s, xor1, cin);

    and (and1, a, b);
    and (and2, xor1, cin);
    or  (cout, and1, and2);
endmodule



// Dadda 8x8 Multiplier
module Dadda8x8(
    input [7:0] a, b,
    output [15:0] prod
);

    // Partial Products
    wire PP[7:0][7:0];

    genvar i, j;
    generate
        for (i = 0; i < 8; i=i+1) begin
            for (j = 0; j < 8; j=j+1) begin
                and (PP[i][j], a[i], b[j]);
            end
        end
    endgenerate


    // Sum / Carry Wires
    wire [8:1] hs, hc;
    wire [48:1] fs, fc;


    // First layer (Height <= 8)
    HA  h1 (.a(PP[6][0]), .b(PP[5][1]), .s(hs[1]),  .c(hc[1]));
    FA  f1 (.a(PP[7][0]), .b(PP[6][1]), .cin(PP[5][2]), .s(fs[1]), .cout(fc[1]));
    HA  h2 (.a(PP[4][3]), .b(PP[3][4]), .s(hs[2]),  .c(hc[2]));
    FA  f2 (.a(PP[7][1]), .b(PP[6][2]), .cin(PP[5][3]), .s(fs[2]), .cout(fc[2]));
    HA  h3 (.a(PP[4][4]), .b(PP[3][5]), .s(hs[3]),  .c(hc[3]));
    FA  f3 (.a(PP[7][2]), .b(PP[6][3]), .cin(PP[5][4]), .s(fs[3]), .cout(fc[3]));

    // Second layer (Height <= 6)
    HA  h4 (.a(PP[4][0]), .b(PP[3][1]), .s(hs[4]),  .c(hc[4]));
    FA  f4 (.a(PP[5][0]), .b(PP[4][1]), .cin(PP[3][2]), .s(fs[4]), .cout(fc[4]));
    HA  h5 (.a(PP[2][3]), .b(PP[1][4]), .s(hs[5]),  .c(hc[5]));
    FA  f5 (.a(PP[4][2]), .b(PP[3][3]), .cin(PP[2][4]), .s(fs[5]), .cout(fc[5]));
    FA  f6 (.a(PP[1][5]), .b(PP[0][6]), .cin(hs[1]), .s(fs[6]), .cout(fc[6]));
    FA  f7 (.a(PP[2][5]), .b(PP[1][6]), .cin(PP[0][7]), .s(fs[7]), .cout(fc[7]));
    FA  f8 (.a(hc[1]), .b(hs[2]), .cin(fs[1]), .s(fs[8]), .cout(fc[8]));
    FA  f9 (.a(PP[2][6]), .b(PP[1][7]), .cin(hc[2]), .s(fs[9]), .cout(fc[9]));
    FA f10 (.a(hs[3]), .b(fc[1]), .cin(fs[2]), .s(fs[10]), .cout(fc[10]));
    FA f11 (.a(PP[4][5]), .b(PP[3][6]), .cin(PP[2][7]), .s(fs[11]), .cout(fc[11]));
    FA f12 (.a(hc[3]), .b(fc[2]), .cin(fs[3]), .s(fs[12]), .cout(fc[12]));
    FA f13 (.a(PP[7][3]), .b(PP[6][4]), .cin(PP[5][5]), .s(fs[13]), .cout(fc[13]));
    FA f14 (.a(PP[4][6]), .b(PP[3][7]), .cin(fc[3]), .s(fs[14]), .cout(fc[14]));
    FA f15 (.a(PP[7][4]), .b(PP[6][5]), .cin(PP[5][6]), .s(fs[15]), .cout(fc[15]));


    // Third layer (Height <= 4)
    HA  h6 (.a(PP[3][0]), .b(PP[2][1]), .s(hs[6]),  .c(hc[6]));
    FA f16 (.a(PP[2][2]), .b(PP[1][3]), .cin(PP[0][4]), .s(fs[16]), .cout(fc[16]));
    FA f17 (.a(PP[0][5]), .b(hc[4]), .cin(hs[5]), .s(fs[17]), .cout(fc[17]));
    FA f18 (.a(hc[5]), .b(fc[4]), .cin(fs[5]), .s(fs[18]), .cout(fc[18]));
    FA f19 (.a(fc[5]), .b(fc[6]), .cin(fs[7]), .s(fs[19]), .cout(fc[19]));
    FA f20 (.a(fc[7]), .b(fc[8]), .cin(fs[9]), .s(fs[20]), .cout(fc[20]));
    FA f21 (.a(fc[9]), .b(fc[10]), .cin(fs[11]), .s(fs[21]), .cout(fc[21]));
    FA f22 (.a(fc[11]), .b(fc[12]), .cin(fs[13]), .s(fs[22]), .cout(fc[22]));
    FA f23 (.a(PP[4][7]), .b(fc[13]), .cin(fc[14]), .s(fs[23]), .cout(fc[23]));
    FA f24 (.a(PP[7][5]), .b(PP[6][6]), .cin(PP[5][7]), .s(fs[24]), .cout(fc[24]));


    // Fourth layer (Height <= 3)
    HA  h7 (.a(PP[2][0]), .b(PP[1][1]), .s(hs[7]),  .c(hc[7]));
    FA f25 (.a(PP[1][2]), .b(PP[0][3]), .cin(hs[6]), .s(fs[25]), .cout(fc[25]));
    FA f26 (.a(hs[4]), .b(hc[6]), .cin(fs[16]), .s(fs[26]), .cout(fc[26]));
    FA f27 (.a(fs[4]), .b(fc[16]), .cin(fs[17]), .s(fs[27]), .cout(fc[27]));
    FA f28 (.a(fs[6]), .b(fc[17]), .cin(fs[18]), .s(fs[28]), .cout(fc[28]));
    FA f29 (.a(fs[8]), .b(fc[18]), .cin(fs[19]), .s(fs[29]), .cout(fc[29]));
    FA f30 (.a(fs[10]), .b(fc[19]), .cin(fs[20]), .s(fs[30]), .cout(fc[30]));
    FA f31 (.a(fs[12]), .b(fc[20]), .cin(fs[21]), .s(fs[31]), .cout(fc[31]));
    FA f32 (.a(fs[14]), .b(fc[21]), .cin(fs[22]), .s(fs[32]), .cout(fc[32]));
    FA f33 (.a(fs[15]), .b(fc[22]), .cin(fs[23]), .s(fs[33]), .cout(fc[33]));
    FA f34 (.a(fc[15]), .b(fc[23]), .cin(fs[24]), .s(fs[34]), .cout(fc[34]));
    FA f35 (.a(PP[7][6]), .b(PP[6][7]), .cin(fc[24]), .s(fs[35]), .cout(fc[35]));


    // Fifth layer (Height <= 2), Implemented an RCA
    HA  h8 (.a(PP[1][0]), .b(PP[0][1]), .s(hs[8]), .c(hc[8]));
    FA f36 (.a(PP[0][2]), .b(hs[7]), .cin(hc[8]), .s(fs[36]), .cout(fc[36]));
    FA f37 (.a(hc[7]), .b(fs[25]), .cin(fc[36]), .s(fs[37]), .cout(fc[37]));
    FA f38 (.a(fc[25]), .b(fs[26]), .cin(fc[37]), .s(fs[38]), .cout(fc[38]));
    FA f39 (.a(fc[26]), .b(fs[27]), .cin(fc[38]), .s(fs[39]), .cout(fc[39]));
    FA f40 (.a(fc[27]), .b(fs[28]), .cin(fc[39]), .s(fs[40]), .cout(fc[40]));
    FA f41 (.a(fc[28]), .b(fs[29]), .cin(fc[40]), .s(fs[41]), .cout(fc[41]));
    FA f42 (.a(fc[29]), .b(fs[30]), .cin(fc[41]), .s(fs[42]), .cout(fc[42]));
    FA f43 (.a(fc[30]), .b(fs[31]), .cin(fc[42]), .s(fs[43]), .cout(fc[43]));
    FA f44 (.a(fc[31]), .b(fs[32]), .cin(fc[43]), .s(fs[44]), .cout(fc[44]));
    FA f45 (.a(fc[32]), .b(fs[33]), .cin(fc[44]), .s(fs[45]), .cout(fc[45]));
    FA f46 (.a(fc[33]), .b(fs[34]), .cin(fc[45]), .s(fs[46]), .cout(fc[46]));
    FA f47 (.a(fc[34]), .b(fs[35]), .cin(fc[46]), .s(fs[47]), .cout(fc[47]));
    FA f48 (.a(PP[7][7]), .b(fc[35]), .cin(fc[47]), .s(fs[48]), .cout(fc[48]));


    // Final Product (16-bits)
    buf (prod[0], PP[0][0]);
    buf (prod[1], hs[8]);
    buf (prod[2], fs[36]);
    buf (prod[3], fs[37]);
    buf (prod[4], fs[38]);
    buf (prod[5], fs[39]);
    buf (prod[6], fs[40]);
    buf (prod[7], fs[41]);
    buf (prod[8], fs[42]);
    buf (prod[9], fs[43]);
    buf (prod[10], fs[44]);
    buf (prod[11], fs[45]);
    buf (prod[12], fs[46]);
    buf (prod[13], fs[47]);
    buf (prod[14], fs[48]);
    buf (prod[15], fc[48]);

endmodule




