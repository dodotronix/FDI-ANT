`timescale 1ns / 1ps
/*-----------------------------------------------------------------------------
 * TODO LICENCE
 * created by: dodotronix | BUT | BRNO 2019
 *
 * Basic lfsr generator
-----------------------------------------------------------------------------*/

module lfsr # 
(
  parameter width_p = 3,
  parameter mask_p = 3'b110
)
(
  input clk,
  input srst,
  input en,
  input [7:0] sel_div_i,
  input [2:0] rep_i,
  output flag_o,
  output sig_o
);

  localparam BIT_CLEAR = 1'b0;

  //edge detector setup
  reg en_last_r = BIT_CLEAR; 

  //prescaler setup
  localparam CNT_CLEAR = {{7{BIT_CLEAR}}, 1'b1}; //start from number 1
  reg [7:0] cnt_r = CNT_CLEAR;
  reg div_clk_r = BIT_CLEAR;

  // lfsr setup
  localparam LFSR_CLEAR = {{width_p-1{BIT_CLEAR}}, 1'b1}; 
  reg [width_p - 1 : 0] result_r = LFSR_CLEAR;
  reg feedback_r = BIT_CLEAR;
  reg busy_r = BIT_CLEAR;
  reg pos;

  //sequence repetition counter setup
  localparam REP_CNT_CLEAR = 3'b001;
  reg [2:0] rep_cnt_r = REP_CNT_CLEAR;
  
  //edge detector (rising edge)
  always @ (posedge clk)
  begin
    en_last_r <= en;
    if(~en_last_r && en) begin
      pos <= 1'b1;
    end
  end

  //prescaler
  always @ (posedge clk)
  begin
    if(srst == 1) begin
      cnt_r <= CNT_CLEAR;
    end
    else begin
      if(cnt_r == sel_div_i) begin
        div_clk_r <= ~div_clk_r;
        cnt_r <= CNT_CLEAR;
      end
      else begin
        cnt_r <= cnt_r + 1;
      end
    end
  end

  //lfsr counter
  always @ (posedge div_clk_r)
  begin
    if(srst == 1) begin
      result_r <= LFSR_CLEAR;
      rep_cnt_r <= REP_CNT_CLEAR;
      busy_r <= BIT_CLEAR;
    end
    else begin
      if(pos == 1) begin
        busy_r <= 1'b1;
        feedback_r = ^~(result_r & mask_p);
        result_r <= {result_r[width_p-2:0], feedback_r};

        if(result_r == LFSR_CLEAR && (busy_r == 1)) begin
          rep_cnt_r <= rep_cnt_r + 1;

          if(rep_cnt_r == rep_i) begin
            busy_r <= BIT_CLEAR;
            pos <= 1'b0;
            rep_cnt_r <= REP_CNT_CLEAR;
          end

        end
      end
    end
  end

  assign sig_o = result_r[width_p-1]; 
  assign flag_o = busy_r; 

endmodule
