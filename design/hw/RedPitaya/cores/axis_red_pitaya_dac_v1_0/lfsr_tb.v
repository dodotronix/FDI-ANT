`timescale 1ns / 1ps

/*-----------------------------------------------------------------------------
 * TODO LICENCE
 * created by: dodotronix | BUT | BRNO 2019
 *
 * Basic lfsr generator test bench
-----------------------------------------------------------------------------*/

module lfsr_tb();

  reg clk;
  reg srst;
  reg en;
  wire flag_o;
  wire sig_o;
  reg flag_old = 1'b0;

  lfsr #(.width_p(3), .mask_p(3'b110)) DUT (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(8'b00000101),
    .rep_i(3'b011),
    .flag_o(flag_o),
    .sig_o(sig_o)
  );

  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk; // generate a clock
  end

  initial begin
    en <= 1'b0;
    srst <= 1'b1;
    #100;
    en <= 1'b1;
    srst <= 1'b0;
  end

  always @ (posedge clk)
  begin
    flag_old <= flag_o;
    if(~flag_o & flag_old) begin
      $display("simulation end");
      $finish;
    end
  end

endmodule
