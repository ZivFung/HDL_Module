`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2015 03:18:45 PM
// Design Name: 
// Module Name: counter
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

module counterM
#(
    parameter M = 60
)
(
    input clk,
    input rst,
    input en,
    output reg [Log2(M - 1) : 0] cnt,
    output co
);
    initial cnt = 0;

    function integer Log2(input integer x);
        for(Log2 = 0; x > 1; x = x >> 1) 
            Log2 = Log2 + 1;
    endfunction
    
    assign co = en & (cnt == M - 1);
    
    always@(posedge clk)
    begin
        if(rst)
            cnt <= 1'b0;
        else if(en)
        begin
            if(cnt < M - 1)
                cnt <= cnt + 1'b1;
            else
                cnt <= 1'b0;
        end
    end
endmodule

