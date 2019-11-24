`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2018 12:22:34 AM
// Design Name: 
// Module Name: LCDDriver
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

//0 : 15  0 : 18    19      20            21          30            31 
//data    cntnum  start   reg_or_data   reset     writeStream     SetCnt
module LCDDriver #
    (
        parameter FALSE = 1'b0,
        parameter TRUE = 1'b1,
        parameter ISREG = 1'b0,
        parameter ISDATA = 1'b1
    )
    (
        input wire [31:0]data,
        input wire clk,                 //Colok signal
        output logic Finish,            //Whether the module is working
        output logic Busy,              //Whether the module is busy
        output logic cs,                //Chip selected
        output logic wr,                //Write in reg/gram, 0 EN 
        output logic rd,                //Read out reg/gram, 0 EN
        output logic rs,                //Write/Read reg for 0, data for 1
        output logic rst,               //Hardware reset
        output logic [15:0] db            //16bit data TFT PIN
    );
        (*mark_debug = "true"*)logic [18:0]StreamWriteCnt;
        (*mark_debug = "true"*)logic [18:0]StreamWriteCntLim;  
        logic [0:0]IsStream;    
        IsStreamlogic[3:0] state;   
        localparam SETCNTNUM = 4;  
        localparam STREAMWRITE = 5; 
        always_ff@(posedge clk)begin
          case(state)
            4'd0:           //wait start  // cs up
            begin
              if(data[19] == TRUE)begin    
                state <= state + 4'b1;
                IsStream <= '0;
              end
              else if(data[31] == 1)begin
                state <= SETCNTNUM;
                IsStream <= '0;
              end
              else if(data[30] == 1)begin
                state <= STREAMWRITE;
                IsStream <= 1;
              end
              else begin
                state <= state;
                IsStream <= '0;
              end
            end
            4'd1:begin      //cs down    
              state <=  4'd2;
            end
            4'd2:begin      //wr down
              state <= state + 1'b1;
            end 
            4'd3:begin      //finish
              state <= 4'd0;
            end
//            3'd4:begin      //finish
//              state <= 3'd0;
//            end
            SETCNTNUM:begin
              StreamWriteCntLim <= data[18:0];
              state <= 4'b0;  
            end
            STREAMWRITE:begin
              state <= 4'd6;
            end
            4'd6:begin       //cs high
              state <= 4'd7;
            end
            4'd7:begin       //cs down
              state <= 4'd8;  
            end
            4'd8:begin       //wr down
              state <= 4'd9;  
            end
            4'd9:begin       //wr down
              StreamWriteCnt <= StreamWriteCnt + 1;
              if(StreamWriteCnt < StreamWriteCntLim)begin
                state <= 4'd6;
              end 
              else begin
                state <= 4'd10;
                StreamWriteCnt <= 0; 
              end
            end
            4'd10:begin       //stream finish
              state <= 4'b0;  
            end
            default:begin state <= 3'd0;end
            endcase
        end
        
        assign Finish = ((state == 4'd3) | (state == SETCNTNUM) | (state == 4'd10))? TRUE : FALSE;  
        assign rs = (data[20] == ISREG)? 1'b0 : 1'b1;
        assign cs = (state == 4'd0 | state == 4'd6)? 1'b1: 1'b0;
        assign wr = ((state == 4'd2) | (state == 4'd3) | (state == 4'd8) | (state == 4'd9))? 1'b0 : 1'b1;
        assign rd = 1'b1;
        assign rst = data[21];
        assign db = data[15:0];
        assign Busy = ~(state == 4'b0);
endmodule
