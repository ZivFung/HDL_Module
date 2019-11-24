`default_nettype none
module Counter #(parameter M = 100)(
    input wire clk, rst, en,
    output logic [$clog2(M) - 1 : 0] cnt,
    output logic co
);
    initial begin cnt <= '0; end
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(en) begin
            if(cnt < M - 1) cnt <= cnt + 1'b1;
            else cnt <= '0;
        end
    end
    assign co = en & (cnt == M - 1);
endmodule


module AD7980 #(
    parameter HBDIV = 1, // half bit divider
    parameter BITS=16,
    parameter TEN_CNT=4,
    parameter CS_H_CNT=80
)(
input wire clk,
input wire sdo,
input wire rst,
input wire start,
output logic cnv_n,
output logic sck,
output logic busy='0,
output logic [15:0]addata
);

//wire div_en;

logic hbr_co,hbc_co,csh_co,csh_en,hbr_en,ten_en,ten_co;
initial hbr_en=1'b0;
logic [$clog2(BITS * 2 + 1) - 1 : 0] hbc_cnt;
Counter #(HBDIV)hbrCnt(clk,rst,busy,,hbr_co);
Counter #(CS_H_CNT)csCnt(clk, rst, csh_en,, csh_co);
Counter #(TEN_CNT)tenCnt(clk, rst, ten_en,, ten_co);
Counter #(BITS * 2 + 1) hbCnt(clk, rst, hbr_co, hbc_cnt, hbc_co);
always_ff@(posedge clk) begin
  if(start)begin csh_en<=1'b1;hbr_en<=1'b1;end
  else if(csh_co) begin busy<=1'b1; csh_en<=1'b0; ten_en=1'b1;end
  else if(ten_co) begin  ten_en=1'b0; end
  else if(hbc_co) begin busy<=1'b0;hbr_en<=1'b0;end
  else busy<=busy;
end
    
   
    logic [BITS - 1 : 0] shifter = '0;
    logic [3:0]data_cnt;
    initial data_cnt=BITS - 1;   
    reg[1:0]sck_sample;initial sck_sample=0;
    always_ff@(posedge clk)
      begin
        sck_sample<={sck_sample[0],sck};
      end
      wire sck_rise=sck_sample==2'b01;
    always_ff@(posedge clk)
    begin
        if(rst) shifter <= '0;
        //else if(start) shifter <= data;
        else if(busy & hbc_cnt[0] & (~ten_en)&sck_rise) begin shifter[data_cnt] <= sdo;
        data_cnt<=data_cnt-1;
        end
        else if(hbc_co)begin addata<=shifter; data_cnt<=BITS - 1; end
        else shifter<=shifter;     
    end
    
    always_ff@(posedge clk)
    begin
        sck <= busy & hbc_cnt[0]&~ten_en;
        cnv_n <= ~busy&~ten_en;
    end
endmodule
