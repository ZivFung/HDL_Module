module OrthDDS #(
    parameter PW = 32, DW = 12, AW = 12
)(
    input wire clk, rst, en,
    input wire signed [PW - 1 : 0] freq, phase,
    output logic signed [DW - 1 : 0] sin, cos
);
    localparam LEN = 2 ** AW;
    localparam real PI = 3.1415926535897932;
    logic signed [DW-1 : 0]sine[LEN];
    initial begin
        for(int i = 0; i < LEN; i++)begin
            sine[i] = $sin(2.0 * PI * i / LEN) * (2.0 ** (DW - 1) - 1.0);
        end
    end
    logic [PW-1 : 0]phaseAcc,phSum0,phSum1;
    always_ff@(posedge clk)begin
      if(rst)phaseAcc <= '0;
      else if(en)phaseAcc <= phaseAcc + freq;
    end
    always_ff@(posedge clk)begin
      if(rst)begin
        phSum0 <= '0;
        phSum1 <= PW'(1) <<< (PW-2);
      end
      else if(en)begin
        phSum0 <= phaseAcc + phase;
        phSum1 <= phaseAcc + phase + PW'(1) <<< (PW-2);
      end
    end
    always_ff@(posedge clk)begin
      if(rst)sin <= '0;
      else if(en) sin <= sine[phSum0[PW-1 -:AW]];
    end
    always_ff@(posedge clk)begin
      if(rst)cos <= '0;
      else if(en) cos <= sine[phSum1[PW-1 -:AW]];
    end
endmodule
