`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2019 09:16:00 AM
// Design Name: 
// Module Name: lfsr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lfsr # 
(
  parameter width_p = 3,
  parameter mask_p = 3'b110
)
(
  input clk,
  input srst,
  input en,
  output flag_o, //?
  output sig_o
  //TODO add input signal for repetition setup
);

  reg [width_p - 1 : 0] result_r = {{width_p-1{1'b0}}, 1'b1};
  reg feedback_r = 1'b0;
  reg busy_r = 1'b0;

  always @ (posedge clk)
  begin
    if(srst == 1) begin
      result_r <= {width_p-1{1'b0}};
    end
    else begin
      if(busy_r == 1) begin
        feedback_r <= ^~(result_r & mask_p);
        result_r <= {result_r[width_p-1:0], feedback_r};
      end
      if(en & ~busy_r) begin
        busy_r <= 1'b1;
      end
    end
  end

  assign sig_o = result_r[width_p-1]; 
  assign flag_o = busy_r; 

endmodule
