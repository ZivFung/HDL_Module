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

module ADS7883 #(
    parameter HBDIV = 1, // half bit divider
    parameter BITS = 16  
)(
    input wire clk, rst, start,
    output logic busy = '0,
    output logic sck,cs_n,
    input wire sdo,
    output logic [11:0]addata
);
    logic hbr_co, hbc_co;
    logic [$clog2(BITS * 2 + 1) - 1 : 0] hbc_cnt;
    Counter #(HBDIV) hbRateCnt(clk, rst, busy, , hbr_co);
    Counter #(BITS * 2 + 1) hbCnt(clk, rst, hbr_co, hbc_cnt, hbc_co);
    always_ff@(posedge clk)
    begin
        if(start) busy <= 1'b1;
        else if(hbc_co) busy <= 1'b0;
    end
    logic [BITS-1: 0] shifter = '0;
    logic [3:0]data_cnt;
    initial data_cnt=BITS-1;   
    always_ff@(posedge clk)
    begin
        if(rst) shifter <= '0;
//        else if(start) shifter <= data;
        else if(hbr_co & hbc_cnt[0]) begin shifter[data_cnt] <= sdo;
        data_cnt<=data_cnt-1;end
        else if(hbc_co)begin addata<=shifter[13:2]; data_cnt<=BITS - 1; end
        else shifter<=shifter;   
    end
    always_ff@(posedge clk)
    begin
        sck <= busy & hbc_cnt[0];
        cs_n <= ~busy;
    end
endmodule
