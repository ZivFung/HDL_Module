module FreqErr
#(parameter WIDTH = 24,
  parameter STEP = 1,
  parameter GAIN_W = 2
    )
( input clk,
  input en, 
  input rst,
  input R, 
  input V, 
  output reg out_en,
  output reg [WIDTH - 1 : 0] out
);
  initial out = 0;
  initial out_en = 0;
  reg signed[WIDTH - 1:0]err_cnt;initial err_cnt = 0;
  localparam Superior = 1 * (2.0 ** (WIDTH - 1)-1);
  localparam Inferior = 1 * (-(2.0 ** (WIDTH - 1)));
  always@(posedge clk)begin
    if(rst)err_cnt <= 0;
    if(en)begin
      if(R & ~V)begin
        if(err_cnt == Superior)out <= err_cnt;
        else err_cnt <= err_cnt + STEP;
        out_en <= 0;
      end
      else if(~R & V)begin
        if(err_cnt == Inferior)out <= err_cnt;
        else err_cnt <= err_cnt - STEP;
        out_en <= 0;
      end
      else begin
        if(err_cnt ^ 0)begin
        out <= err_cnt <<< GAIN_W;
        out_en <= 1;
        end
        else out_en  <= 0;
        err_cnt = 0;
      end
    
    end
    else err_cnt <= err_cnt;
  end
endmodule





