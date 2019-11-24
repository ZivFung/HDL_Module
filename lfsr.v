module lfsr
#
( parameter W = 8,
  parameter POLY = 9'h11D)
( input clk,   
  input arst,
  input en,
  output out
 );
  reg [W-1:0] sreg;
  assign out = sreg[0];
  initial 
    begin
      sreg=1;
    end
  always@(posedge clk )
    begin
      if(arst) sreg <= 1'b1;
        else begin
          if(en) 
            begin
              if(out) sreg <= (sreg >> 1) ^ (POLY >> 1);            
              else sreg <= sreg >> 1;
            end
        end      
    end
endmodule
