module pwm
(
    input clk,
    input signed [9:0] in,
    output reg pwm,
    output tick
);
    reg signed [9:0] cnt;
    always@(posedge clk)
    begin
        cnt <= cnt + 10'sb1;
    end
    
    always@(posedge clk)
    begin
        pwm <= (in > cnt);
    end
    
    assign tick = cnt == 10'sd511;
    
endmodule

