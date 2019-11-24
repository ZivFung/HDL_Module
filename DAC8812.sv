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

module DAC8812 #(
    parameter HBDIV = 1, // half bit divider
    parameter BITS = 18  // 16 for 8811, 12 for 7811
)(
    input wire clk, rst, start,
    input wire [BITS - 1 : 0] data,
    output logic busy = '0,
    output logic sck, sdo, cs_n,ldac
);
    logic hbr_co, hbc_co,ldacw_co,ldacw_en;
    logic ldac_en,ldac_co;
    logic [$clog2(BITS * 2 + 1) - 1 : 0] hbc_cnt;
    Counter #(HBDIV) hbRateCnt(clk, rst, busy, , hbr_co);
    Counter #(BITS * 2 + 1) hbCnt(clk, rst, hbr_co, hbc_cnt, hbc_co);
    Counter #(2) ldacwCnt(clk, rst, ldacw_en, , ldacw_co);
    Counter #(2) ldacCnt(clk, rst, ldac_en, , ldac_co);
    always_ff@(posedge clk)
    begin
        if(start) busy <= 1'b1;
        else if(hbc_co) begin busy <= 1'b0;ldacw_en=1'b1;  end
        else if(ldacw_co) begin ldacw_en=1'b0; ldac_en=1'b1;end
        else if(ldac_co) ldac_en=1'b0;
        
    end
    logic [BITS - 1 : 0] shifter = '0;
    always_ff@(posedge clk)
    begin
        if(rst) shifter <= '0;
        else if(start) shifter <= data;
        else if(hbr_co & hbc_cnt[0])begin shifter <= shifter << 1;end
    end
    always_ff@(posedge clk)
    begin
        sck  <= busy & hbc_cnt[0];
        cs_n <= ~busy;
        sdo  <= shifter[BITS - 1];
        ldac <= ~(ldac_en&~ldac_co);
    end
endmodule

