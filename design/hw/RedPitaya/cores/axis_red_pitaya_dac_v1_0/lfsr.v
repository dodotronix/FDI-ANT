`timescale 1ns / 1ps
/*------------------------------------------------------------------------------
 * TODO LICENCE
 * created by: dodotronix | BUT | BRNO 2019
 *
 * Basic lfsr generator
------------------------------------------------------------------------------*/

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
  localparam BIT_SET = 1'b1;

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


  // edge-detector
  always @ (posedge clk)
  begin
    en_last_r <= en;
    if(~en_last_r & en) begin
      pos <= BIT_SET;
    end
    else begin
      if(div_clk_r) begin
        if(rep_cnt_r == rep_i) begin
          if((result_r == LFSR_CLEAR) && busy_r) begin
            pos <= BIT_CLEAR;
          end
        end
      end
    end
  end
      
  //Clock enabling (prescaler)
  always @ (posedge clk)
  begin
    if(cnt_r == sel_div_i) begin
      div_clk_r <= 1'b1;
      cnt_r <= CNT_CLEAR;
    end
    else begin
      cnt_r <= cnt_r + 1;
      div_clk_r <= BIT_CLEAR;
    end
  end

  //lfsr counter
  always @ (posedge clk)
  begin
    if(srst) begin
      busy_r <= BIT_CLEAR;
      result_r <= LFSR_CLEAR;
      rep_cnt_r <= REP_CNT_CLEAR;
    end
    else begin
      if(pos) begin
        if(div_clk_r) begin
          busy_r <= BIT_SET;
          result_r <= {result_r[width_p-2:0], feedback_r};

          if((result_r == LFSR_CLEAR) && busy_r) begin
            if(rep_cnt_r == rep_i) begin
              busy_r <= BIT_CLEAR;
              rep_cnt_r <= REP_CNT_CLEAR;
            end
            else begin
              rep_cnt_r <= rep_cnt_r + 1;
            end
          end
        end
      end
    end
  end

  //lfsr feedback
  always @*
  begin
    feedback_r <= ^~(result_r & mask_p);
  end

  assign sig_o = result_r[width_p-1]; 
  assign flag_o = busy_r; 

endmodule
