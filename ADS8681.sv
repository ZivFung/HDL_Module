`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2018 02:29:24 PM
// Design Name: 
// Module Name: ADS8681
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


module ADS8681#(
  parameter Reg_File = "ADS8681_Register.dat",
  parameter BITS = 16, 
  parameter INIT_BIT_CNT = 32,
  parameter INIT_REG_CNT = 2,
  parameter SAMPLE_BIT_CNT = 16 
)(
  input wire clk,                   //66.7MHz
  input wire Rst,
  input wire Start,
  input wire SDO_1,SDO_2,
  input wire RVS,
  output logic Busy,
  output logic SDI,
  output logic CS,
  output logic SCLK,
  output logic [BITS - 1:0]ADS8681_Data,
  output logic OutputEn
    );
  reg [31:0]ADS8681_Reg[INIT_REG_CNT-1:0];initial $readmemh(Reg_File,ADS8681_Reg);
  logic Initialized; 
  logic InitializedStart;
  logic [1:0]InitializeState;
  
  always_ff@(posedge clk)begin
    if(Rst)Initialized <= 0;
    else if(InitializeState == 2)Initialized <= 1;
  end
  
  always_ff@(posedge clk)begin
    if(Rst)InitializedStart <= 0;
    else begin
      if(~Initialized)InitializedStart <= 1; 
      else InitializedStart <= 0;
    end
  end
  
  always_ff@(posedge clk)begin
    if(Rst)InitializeState <= 0;
    else begin
      case(InitializeState)
        0:begin
          if(InitializedStart)InitializeState <= 1;
        end
        1:begin
          if(InitializeFinish)InitializeState <= 2;
        end
        2:begin
          InitializeState <= 3;
        end
        3:begin
          InitializeState <= 0;
        end
      endcase
    end
  end
  logic SingleInitCo;
  logic [5:0]InitBitsCnt;
  wire [$clog2(INIT_REG_CNT)-1:0]RegCnt;
  logic InitializeFinish;
  always_ff@(posedge clk)begin
    if(Rst)InitBitsCnt <= 0;
    else begin
      if(InitBitsCnt > 0 & InitBitsCnt < INIT_BIT_CNT + 1)begin
        InitBitsCnt <= InitBitsCnt + 1;
      end
      else if(InitBitsCnt == INIT_BIT_CNT + 1)InitBitsCnt <= 0;
      else if((InitializeState==1) & RVS)begin
        InitBitsCnt <= 1;
      end
      else InitBitsCnt <= InitBitsCnt;
    end
  end
  
  assign SingleInitCo = InitBitsCnt == INIT_BIT_CNT + 1;
  Counter #(INIT_REG_CNT)InitializeRegCnt(clk,Rst,SingleInitCo,RegCnt,InitializeFinish);
  
  always_ff@(negedge clk)begin
    if(Rst)SDI <= 0;
    else begin
      if(InitializeState==1 & InitBitsCnt > 0 & InitBitsCnt < INIT_BIT_CNT + 1)begin
        SDI <= ADS8681_Reg[RegCnt][INIT_BIT_CNT-InitBitsCnt];
      end
    end
  end
  
  logic [$clog2(SAMPLE_BIT_CNT + 1) - 1 : 0]SampleCnt;
  logic SampleCntCo;
  always_ff@(posedge clk)begin
    if(Rst)SampleCnt <= 0;
    else if(Initialized) begin
      if(Start & RVS)SampleCnt <= 1;
      else if(SampleCnt < SAMPLE_BIT_CNT + 1 & SampleCnt > 0)SampleCnt <= SampleCnt + 1;
      else SampleCnt <= 0;
    end
  end
  assign SampleCntCo = SampleCnt == (SAMPLE_BIT_CNT + 1);
  logic DataWrEn;
  always_ff@(posedge clk)begin
    DataWrEn <= SampleCntCo;
  end
  
  always@(posedge clk)begin
    if(Rst)OutputEn <= 0;
    else begin
      OutputEn <= DataWrEn;  
    end
  end
  
  logic [INIT_BIT_CNT - 1 : 0] shifter;
  always_ff@(posedge clk)begin
    if(Rst)shifter <=0;
    else begin
      if(SampleCnt > 1)begin
        shifter <= {shifter[INIT_BIT_CNT-3:0],SDO_2,SDO_1};
      end
      else if(Start) shifter <= 0;
    end
  end
  
  always_ff@(posedge clk)begin
    if(Rst)ADS8681_Data <= 0;
    else begin
      if(DataWrEn)ADS8681_Data <= shifter[INIT_BIT_CNT-1:INIT_BIT_CNT-SAMPLE_BIT_CNT];
    end
  end
  
  assign CS = (~Initialized)?((InitializeState==1)?((InitBitsCnt > 0)?0:1):1):(SampleCnt > 0)?0:1;
  assign SCLK = (clk & (InitBitsCnt > 1)) | (clk & (SampleCnt > 1));
  
  
endmodule

