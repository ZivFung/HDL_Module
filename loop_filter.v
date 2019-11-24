module loop_filter
#(  parameter ACC = 1,
    parameter WIDTH = 24,
    parameter FW = 16
    )
( input clk,
  input rst,
  input en,
  input R, 
  input V, 
  output wire [WIDTH - 1 : 0] out
);
    reg signed[WIDTH + FW - 1:0]sum;
    initial begin
        sum <=0;
    end
    wire signed [WIDTH + FW - 1:0] acc = ACC * (2.0 ** FW);
    always@(posedge clk) begin
      if(rst)sum <= 0;
      else if(en)begin
        if(R & ~V)
            sum <= sum + acc;
        else if(~R & V)
            sum <= sum - acc;
      end
      else begin
        sum <= sum;
      end
    end
    assign out = sum >>> FW;
endmodule

