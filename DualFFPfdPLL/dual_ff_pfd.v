module dual_ff_pfd
( input clk, 
  input vco_in,//
  input ref_in,
  output reg R = 0, 
  output reg V = 0
);
    always@(posedge ref_in or posedge (R & V)) begin
        if(R & V) begin
          R <= 1'b0;
        end
        else begin
          R <= 1;
        end
    end
    always@(posedge vco_in or posedge (R & V)) begin
        if(R & V) begin
          V <= 1'b0; 
        end
        else begin
          V <= 1;
        end
    end
endmodule

