`timescale 1ns/1ps
module DDS
#( parameter PHASE_W = 24,
 parameter DATA_W = 10,
  parameter TABLE_AW = 8,
   parameter MEM_FILE ="sin256x10.dat"//
)( input [PHASE_W - 1 : 0] FreqWord,
   input [PHASE_W - 1 : 0] PhaseShift,
   input Clock, input ClkEn,input rst,
   output reg signed [DATA_W - 1 : 0] Out = 0
) ;//??ad??????????
   reg signed [DATA_W - 1 : 0] sinTable[2 ** TABLE_AW - 1 : 0]; // Sine table ROM
   reg [PHASE_W - 1 : 0] phase; // Phase Accumulater
   wire [PHASE_W - 1 : 0] addr = phase + PhaseShift; // Phase Shift??????
   initial begin
      #50 phase = 0;
      $readmemh(MEM_FILE, sinTable); // Initialize the ROM ?????
   end
   always@(posedge Clock) begin
      if(rst)   phase <= 0;
      else if(ClkEn) phase <= phase + FreqWord;
   end
   always@(posedge Clock) begin
      Out <= sinTable[addr[PHASE_W - 1 : PHASE_W - TABLE_AW]]; // Look up the table??
   end
endmodule

module PLL #(
	parameter DW = 16,
	parameter PW = 32,
	parameter AW = 12,
	parameter BASE_FREQ = 42950,
	parameter MEM_FILE = "sin256x10.dat"
)
(
	input wire clk,
	input wire rst,
	input wire Vref,  //Vref
	output wire signed[DW-1:0]sin
);
  wire V,R;
 	wire out_en;
 	wire signed[2*PW-1:0]PIDFreq;
 	wire signed[PW-1:0]VCOFreq;
	dual_ff_pfd pfd
	(
		.clk(clk), 
		.vco_in(~sin[DW-1]),
		.ref_in(Vref),
		.R(R), 
		.V(V)
	);
	FreqErr
	#(.WIDTH(2*PW),.STEP(32),.GAIN_W(34))err
	(
		.clk(clk),
		.rst(rst),
		.en(1),
		.R(R), 
		.V(V), 
		.out_en(out_en),
		.out(FreqErr)
	);
	PID #(2*PW, 60, 0.0000001, 0.148, 0.78e-6, 1.0,0.0007,BASE_FREQ)
	thePID( clk, rst, 1,out_en,(2*PW)'(FreqErr), PIDFreq);
	assign VCOFreq = PIDFreq >>> 32;
	DDS
	#(
		.PHASE_W(32),
		.DATA_W(16),
		.TABLE_AW(12),
		.MEM_FILE(MEM_FILE)
	)VCO( 
		.FreqWord(VCOFreq),
		.PhaseShift(32'b0),
		.Clock(clk),
		.ClkEn(1),
		.rst(rst),
		.Out(sin)
	);
endmodule
