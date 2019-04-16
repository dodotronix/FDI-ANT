`timescale 1ns / 1ps

/*-----------------------------------------------------------------------------
 * TODO LICENCE
 * created by: dodotronix | BUT | BRNO 2019
 *
 * Basic lfsr generator
 *
// TODO code style
-----------------------------------------------------------------------------*/

module mul_lfsr 
(
  input clk,
  input srst,
  input en,
  input [7:0] sel_div_i,
  input [2:0] rep_i,
  input [3:0] order_i,
  output flag_o,
  output sig_o
);

  wire [15:0] mux_sigs;

  lfsr #(.width_p(6), .mask_p(6'b110000)) inst_lfsr0  (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[0]),
    .sig_o(mux_sigs[1])
  );

  lfsr #(.width_p(7), .mask_p(7'b1100000)) inst_lfsr1 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[2]),
    .sig_o(mux_sigs[3])
  );

  lfsr #(.width_p(8), .mask_p(8'b10111000)) inst_lfsr2 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[4]),
    .sig_o(mux_sigs[5])
  );

  lfsr #(.width_p(9), .mask_p(9'b100010000)) inst_lfsr3 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[6]),
    .sig_o(mux_sigs[7])
  );

  lfsr #(.width_p(10), .mask_p(10'b1001000000)) inst_lfsr4 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[8]),
    .sig_o(mux_sigs[9])
  );

  lfsr #(.width_p(11), .mask_p(11'b10100000000)) inst_lfsr5 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[10]),
    .sig_o(mux_sigs[11])
  );

  lfsr #(.width_p(12), .mask_p(12'b100000101001)) inst_lfsr6 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[12]),
    .sig_o(mux_sigs[13])
  );

  lfsr #(.width_p(13), .mask_p(13'b1000000001101)) inst_lfsr7 (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(sel_div_i),
    .rep_i(rep_i),
    .flag_o(mux_sigs[14]),
    .sig_o(mux_sigs[15])
  );

  assign flag_o = mux_sigs[2*order_i];
  assign sig_o = mux_sigs[2*order_i + 1];

endmodule
