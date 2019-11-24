// This file was automatically generated by FIRDesigner software whose author is loywong.
// The file including:
//   ◆  a 13 taps FIR low pass filter module based on Kaiser window (beta=7.000)
//         and it's normalized (to half Freq_sample) cut off frequency is 0.500.
//   ◆  the CSD multipliers which were invoked by the filter module.
// The original coefficients are:
//     0.000000000000000
//     0.003813791456755
//     0.000000000000000
//    -0.044784569577449
//     0.000000000000000
//     0.290749904641556
//     0.500000000000000
//     0.290749904641556
//     0.000000000000000
//    -0.044784569577449
//     0.000000000000000
//     0.003813791456755
//     0.000000000000000

// CSD Multiplier for Coefficient 0.003813791456755
module FIR_Kaiser_13Taps_LP_0d500_CSDMult_p003813791456755
(
    input [11:0] in,
    output [11:0] out
);
    wire [11:0] shiftSign = (in[11] == 1'b0)? 12'b0 : - 12'b1;
    assign out = + {shiftSign[11:4], in[11:8]} - {shiftSign[11:1], in[11:11]};
endmodule

// CSD Multiplier for Coefficient 0.044784569577449
module FIR_Kaiser_13Taps_LP_0d500_CSDMult_p044784569577449
(
    input [11:0] in,
    output [11:0] out
);
    wire [11:0] shiftSign = (in[11] == 1'b0)? 12'b0 : - 12'b1;
    assign out = ({shiftSign[11:8], in[11:4]} - {shiftSign[11:6], in[11:6]}) - ({shiftSign[11:3], in[11:9]} + {shiftSign[11:1], in[11:11]});
endmodule

// CSD Multiplier for Coefficient 0.290749904641556
module FIR_Kaiser_13Taps_LP_0d500_CSDMult_p290749904641556
(
    input [11:0] in,
    output [11:0] out
);
    wire [11:0] shiftSign = (in[11] == 1'b0)? 12'b0 : - 12'b1;
    assign out = ({shiftSign[11:10], in[11:2]} + {shiftSign[11:7], in[11:5]}) + ({shiftSign[11:5], in[11:7]} + {shiftSign[11:3], in[11:9]} - {shiftSign[11:1], in[11:11]});
endmodule

// CSD Multiplier for Coefficient 0.500000000000000
module FIR_Kaiser_13Taps_LP_0d500_CSDMult_p500000000000000
(
    input [11:0] in,
    output [11:0] out
);
    wire [11:0] shiftSign = (in[11] == 1'b0)? 12'b0 : - 12'b1;
    assign out = + {shiftSign[11:11], in[11:1]};
endmodule


module FIR_Kaiser_13Taps_LP_0d500
(
    input Clock,
    input ClkEn,
    input AsyncRst,
    input signed [11:0] In,
    output reg signed [11:0] Out
);

    reg signed [11:0] delay[11:0];
    wire signed [11:0] prod_0p003813791456755;
    wire signed [11:0] prod_0p044784569577449;
    wire signed [11:0] prod_0p290749904641556;
    wire signed [11:0] prod_0p500000000000000;

    FIR_Kaiser_13Taps_LP_0d500_CSDMult_p003813791456755 mult0p003813791456755(In, prod_0p003813791456755);
    FIR_Kaiser_13Taps_LP_0d500_CSDMult_p044784569577449 mult0p044784569577449(In, prod_0p044784569577449);
    FIR_Kaiser_13Taps_LP_0d500_CSDMult_p290749904641556 mult0p290749904641556(In, prod_0p290749904641556);
    FIR_Kaiser_13Taps_LP_0d500_CSDMult_p500000000000000 mult0p500000000000000(In, prod_0p500000000000000);

    always@(posedge Clock or posedge AsyncRst)
    begin
        if(AsyncRst)
        begin
            delay[0] <= 1'b0;
            delay[1] <= 1'b0;
            delay[2] <= 1'b0;
            delay[3] <= 1'b0;
            delay[4] <= 1'b0;
            delay[5] <= 1'b0;
            delay[6] <= 1'b0;
            delay[7] <= 1'b0;
            delay[8] <= 1'b0;
            delay[9] <= 1'b0;
            delay[10] <= 1'b0;
            delay[11] <= 1'b0;
        end
        else if(ClkEn)
        begin
            Out <= delay[0];
            delay[0] <= delay[1] + prod_0p003813791456755;
            delay[1] <= delay[2];
            delay[2] <= delay[3] - prod_0p044784569577449;
            delay[3] <= delay[4];
            delay[4] <= delay[5] + prod_0p290749904641556;
            delay[5] <= delay[6] + prod_0p500000000000000;
            delay[6] <= delay[7] + prod_0p290749904641556;
            delay[7] <= delay[8];
            delay[8] <= delay[9] - prod_0p044784569577449;
            delay[9] <= delay[10];
            delay[10] <= delay[11] + prod_0p003813791456755;
            delay[11] <= 1'b0;
        end
    end

endmodule
