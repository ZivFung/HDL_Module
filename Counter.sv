
`timescale 1ns/100ps
`default_nettype none

module Counter #(
    parameter M = 100
)(
    input wire clk, rst, en,
    output logic [$clog2(M) - 1 : 0] cnt,
    output logic co
);
    assign co = en & (cnt == M - 1);
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(en) begin
            if(cnt < M - 1) cnt <= cnt + 1'b1;
            else cnt <= '0;
        end
    end
endmodule
