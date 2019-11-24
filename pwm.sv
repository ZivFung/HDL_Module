module pwm#(
    parameter DW = 10
)
(
    input wire clk,
    input wire signed [DW-1:0] in,
    output logic pwm,
    output logic tick
);
    localparam HalfCnt = 2**(DW-1) - 1;
    wire signed[DW-1:0]Peak = HalfCnt;
    logic signed [DW-1:0] cnt;
    always_ff@(posedge clk)
    begin
        cnt <= cnt + 'sb1;
    end
    
    always_ff@(posedge clk)
    begin
        pwm <= (in > cnt);
    end
    
    assign tick = cnt == Peak;
    
endmodule

