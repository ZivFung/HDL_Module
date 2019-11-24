module OrthDDS #(
    parameter PW = 32, DW = 12, AW = 12
)(
    input wire clk, rst, en,
    input wire signed [PW - 1 : 0] freq, phase,
    output logic signed [DW - 1 : 0] sin, cos
);
    localparam LEN = 2**AW;
    logic signed [DW-1 : 0] sine[LEN];
    logic signed [DW-1 : 0] cosi[LEN];
    initial begin
        $readmemh("./sin16b16k.dat", sine);
        $readmemh("./cos16b16k.dat", cosi);
    end
    logic [PW-1 : 0] phaseAcc, phSum;
    always_ff@(posedge clk) begin
        if(rst) phaseAcc <= '0;
        else if(en) phaseAcc <= phaseAcc + freq;
    end
    always_ff@(posedge clk) begin
        if(rst) phSum <= '0;
        else if(en) phSum <= phaseAcc + phase;
    end
    always_ff@(posedge clk) begin
        if(rst) sin <= '0;
        else if(en) sin <= sine[phSum[PW-1 -: AW]];
    end
    always_ff@(posedge clk) begin
        if(rst) cos <= '0;
        else if(en) cos <= cosi[phSum[PW-1 -: AW]];
    end
endmodule

module CicDownSampler2 #( parameter W = 10, R = 4, M = 1, N = 2 )(
    input wire clk, rst, eni, eno,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    localparam real GAIN = (real'(R) * M)**(N);
    localparam DW = W + $ceil($ln(GAIN)/$ln(2.0));
    logic signed [DW-1:0] intgs_data[N+1];
    assign intgs_data[0] = in;
    generate
        for(genvar k = 0; k < N; k++) begin : Intgs
            Integrator #(DW) theIntg(
                clk, rst, eni, intgs_data[k], intgs_data[k+1]);
        end
    endgenerate
    logic signed [DW-1:0] combs_data[N+1];
    InterpDeci #(DW) theDeci(
        clk, rst, eni, eno, intgs_data[N], combs_data[0]);
    generate
        for(genvar k = 0; k < N; k++) begin : Combs
            Comb #(DW, M) theComb(
                clk, rst, eno, combs_data[k], combs_data[k+1]);
        end
    endgenerate
    // Q1.(DW-1)
    wire signed [DW-1:0] attn = (1.0 / GAIN * 2**(DW-1));
    always_ff@(posedge clk) begin
        if(rst) out <= '0;
        else if(eno) out <= ((2*DW)'(combs_data[N]) * (2*DW)'(attn)) >>> (DW-1);
    end
endmodule

module PI #(
    parameter W = 32, FW = 16,
    parameter real P = 8, real I = 192, real TS = 0.002,
    parameter real LIMIT = 10000
)(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    wire signed [W-1:0] p = P * (2.0 ** FW);
    wire signed [W-1:0] i = (I * TS) * (2.0 ** FW);
    wire signed [W-1:0] ts = TS * (2.0 ** FW);
    wire signed [W-1:0] lim = LIMIT * (2.0 ** FW);
    wire signed [W-1:0] xp = ((2*W)'(in) * p) >>> FW;
    wire signed [W-1:0] xi_temp = ((2*W)'(in) * (2*W)'(i)) >>> (FW-1);
    wire signed [W-1:0] xi = (xi_temp == -1)? 0: xi_temp >>> 1;
    logic signed [W-1:0] xi_acc;
    always_ff@(posedge clk) begin
        if(rst) xi_acc <= 1'sb0;
        else if(en) begin
            if(xi_acc + xi > lim) xi_acc <= lim;
            else if(xi_acc + xi < -lim) xi_acc <= -lim;
            else xi_acc <= xi_acc + xi;
        end
    end
    always_ff@(posedge clk) begin
        if(rst) out <= 1'sb0;
        else if(en) out <= xp + xi_acc;
    end
endmodule


module PLLFilter#(
  parameter FW = 32,
  parameter DW = 16
  )(
    input wire clk,
    input wire en,
    input wire [DW-1:0]in,
    output wire [DW-1:0]out 
  );
  logic [DW-1:0]IIROut1;
  iir_2nd
  #(
      .w(DW),
      .FW(FW),
      .N0(0.000031097004254959256 * 1),
      .N1(0.000031097004254959256 * 2),
      .N2(0.000031097004254959256 * 1),
      .D1(-1.9913578525932132),
      .D2(0.99148224061023293)
    )iir1(clk,en,in,IIROut1);
  iir_2nd
  #(
      .w(DW),
      .FW(FW),
      .N0(0.000030910829398235002 * 1),
      .N1(0.000030910829398235002 * 2),
      .N2(0.000030910829398235002 * 1),
      .D1(-1.9794357793332418),
      .D2( 0.97955942265083495)
    )iir2(clk,en,IIROut1,out);    
endmodule


module ADPLL #(
    parameter PW=32, DW=12, AW=12
)(
    input wire clk, rst,    
    input wire en,
    input wire signed [DW-1:0] in,
    input wire signed [PW-1:0] base_freq,
    output logic signed [DW-1:0] sin, cos
);
    logic signed [DW-1:0] mix, mix_cic, mix_fir1, mix_fir2, mix_fil;

    assign mix = ((2*DW)'(in) * -sin) >>> (DW-1);
//    logic en_250k, en_125k, en_62k5;
    logic en_100k,en_50k;
    Counter #(10) cnt100k(clk, rst, en, , en_100k);
    Counter #(2) cnt50k(clk, rst, en_100k, , en_50k);
//    Counter #(2) cnt125k(clk, rst, en_250k, , en_125k);
//    Counter #(2) cnt62k5(clk, rst, en_125k, , en_62k5);
//    CicDownSampler2 #(DW, 50, 1, 3) cicDs(clk, rst, en, en_100k, mix, mix_cic);
    // @100ksps, 10k \ 30k
//    FIR_Kaiser_27Taps_LP_0d500 fir1(clk, en_100k, rst, mix_cic, mix_fir1);
    // @50ksps, 4k \ 16k 
//    FIR_Kaiser_22Taps_LP_0d500 fir2(clk, en_50k, rst, mix_fir1, mix_fil);

    // @250ksps, 17.5k \ 107.5k
//    FIR_Kaiser_13Taps_LP_0d500 fir1(clk, en_250k, rst, mix_cic, mix_fir1);
    // @125ksps, 15k \ 47.5k
//    FIR_Kaiser_17Taps_LP_0d500 fir2(clk, en_125k, rst, mix_fir1, mix_fir2);
    // @62.5ksps, 3.9k \ 10k
//    FIR_Kaiser_25Taps_LP_0d125 fir3(clk, en_62k5, rst, mix_fir2, mix_fil);
    CicDownSampler #(DW, 10, 1, 3) cicDs(clk, rst, en, en_100k, mix, mix_cic);
//    assign mix_fir1 = mix_cic >>> (DW-1);
    // @500sps, 60 \ 190
    FIR_Kaiser_27Taps_LP_0d500 fir1(clk, en_100k, rst, mix_cic, mix_fir2);
    //@250sps, 20 \ 60
    FIR_Kaiser_22Taps_LP_0d500 fir2(clk, en_50k, rst, mix_fir2, mix_fil);
//    logic signed [2*DW-1:0]mix;
//    logic signed [2*DW-1:0]IIROut;
//    assign mix = ((2*DW)'(in) * -sin);
//    PLLFilter#(2*DW-1,2*DW + 4)the_PPLFilter
//    (clk,en,(2*DW + 4)'(mix),IIROut);

    wire signed [PW-1:0] ph_err = (PW)'(mix_fil) <<< (PW-DW+1);
//    wire signed [PW-1:0] ph_err = (PW)'(ph_err) <<< (PW-2*DW+1);
//    wire signed [PW-2:0] ph_err_test = ph_err;
    localparam PIDW = (PW+8);
    logic signed [PIDW-1:0] freq_vari;
    PI #(PIDW, PW-1, 0.000001, 0.0005, 1.6e-5, 1.0)
        thePI( clk, rst, en_50k, (PIDW)'(ph_err), freq_vari);
//    	PID #(PIDW, PW-1, 0.000005, 0.0002, 5.78e-5, 1.0,5.7553e-6,0)
//	thePID( clk, rst,en,(PIDW)'(ph_err), freq_vari);
    logic signed [PW-1:0] freq;
    always_ff@(posedge clk) begin
        if(rst) freq <= base_freq;
        else freq <= (PW)'(freq_vari) + base_freq;
    end
    OrthDDS #(PW,DW,AW)
        theDds( clk, rst, 1'b1, freq, (PW)'(0), sin, cos );
endmodule
