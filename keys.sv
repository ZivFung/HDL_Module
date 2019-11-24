`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2015 03:18:45 PM
// Design Name: Romeo
// Module Name: keys
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

module keysprocess
#(
    parameter W = 1
)(
    input wire clk,
    input wire [W - 1 : 0] keyin,
    output logic [W - 1 : 0] keyout
);
    logic [19 : 0] cnt10ms; 
    always_ff@(posedge clk)
    begin
        if(cnt10ms < 20'd999999)
            cnt10ms <= cnt10ms + 20'b1;
        else
            cnt10ms <= 20'b0;
    end
    
    logic [W - 1 : 0] keysmp;
    always_ff@(posedge clk)
    begin
        if(cnt10ms == 20'd999999)
            keysmp <= keyin;
    end
    
    logic [W - 1 : 0] keydly;
    always_ff@(posedge clk)
    begin
        keydly <= keysmp;
    end
    
    assign keyout = keysmp & ~keydly;

endmodule
