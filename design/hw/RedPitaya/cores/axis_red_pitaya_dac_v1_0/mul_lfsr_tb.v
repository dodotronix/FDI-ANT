`timescale 1ns / 1ps

/*-----------------------------------------------------------------------------
 * TODO LICENCE
 * created by: dodotronix | BUT | BRNO 2019
 *
 * Basic multiple lfsr generator test bench
-----------------------------------------------------------------------------*/

module mul_lfsr_tb();

  reg clk;
  reg srst;
  reg en;
  wire flag_o;
  wire sig_o;

  mul_lfsr DUT (
    .clk(clk),
    .srst(srst),
    .en(en),
    .sel_div_i(8'b00000100),
    .rep_i(3'b011),
    .order_i(8'b00000000),
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
    #1000

    $finish;
  end

endmodule
