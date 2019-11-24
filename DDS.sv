module DDS #(
    parameter PW = 32, DW = 12, AW = 12
)(
    input wire clk, rst, en,
    input wire signed [PW - 1 : 0] freq, phase,
    output logic signed [DW - 1 : 0] sin
);
    localparam LEN = 2**AW;
    logic signed [DW-1 : 0] sine[LEN];
    initial begin
        $readmemh("./sin12b4k.dat", sine);
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
endmodule
