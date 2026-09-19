// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module lcu4(
  input  [3:0] g,
  input  [3:0] p,
  input        cin,
  output       c1,
  output       c2,
  output       c3,
  output       cout,
  output       gout,
  output       pout
);

  wire t1_0;
  wire t2_0, t2_1;
  wire t3_0, t3_1, t3_2;
  wire t4_0, t4_1, t4_2;
  wire t5_0;

  and #(2) (t1_0, p[0], cin);
  or  #(2) (c1, g[0], t1_0);

  and #(2) (t2_0, p[1], g[0]);
  and #(2) (t2_1, p[1], p[0], cin);
  or  #(2) (c2, g[1], t2_0, t2_1);

  and #(2) (t3_0, p[2], g[1]);
  and #(2) (t3_1, p[2], p[1], g[0]);
  and #(2) (t3_2, p[2], p[1], p[0], cin);
  or  #(2) (c3, g[2], t3_0, t3_1, t3_2);

  and #(2) (t4_0, p[3], g[2]);
  and #(2) (t4_1, p[3], p[2], g[1]);
  and #(2) (t4_2, p[3], p[2], p[1], g[0]);
  or  #(2) (gout, g[3], t4_0, t4_1, t4_2);
  and #(2) (pout, p[3], p[2], p[1], p[0]);

  and #(2) (t5_0, pout, cin);
  or  #(2) (cout, gout, t5_0);

endmodule

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.

  wire [15:0] gblk, pblk;
  wire [15:0] bc;
  wire [3:0]  G1, P1;
  wire [3:0]  gc;

  assign gc[0] = cin;

  lcu4 L2 (
    .g   (G1),  .p (P1), .cin (cin),
    .c1  (gc[1]), .c2 (gc[2]), .c3 (gc[3]),
    .cout(cout), .gout(), .pout()
  );

  genvar j;
  generate
    for (j = 0; j < 4; j = j + 1) begin : gen_lcu1
      assign bc[4*j] = gc[j];
      lcu4 L1 (
        .g   (gblk[4*j+3 : 4*j]),
        .p   (pblk[4*j+3 : 4*j]),
        .cin (gc[j]),
        .c1  (bc[4*j+1]),
        .c2  (bc[4*j+2]),
        .c3  (bc[4*j+3]),
        .cout(),
        .gout(G1[j]),
        .pout(P1[j])
      );
    end
  endgenerate

  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : gen_blk
      cla4 BLK (
        .a   (a[4*k+3 : 4*k]),
        .b   (b[4*k+3 : 4*k]),
        .cin (bc[k]),
        .sum (sum[4*k+3 : 4*k]),
        .cout(),
        .gblk(gblk[k]),
        .pblk(pblk[k])
      );
    end
  endgenerate


endmodule
