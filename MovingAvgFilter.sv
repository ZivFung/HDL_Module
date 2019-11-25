module MovingAvg #(parameter W = 10, LOG2N = 3)(
    input wire clk, rst, en,
    input wire signed [W-1 :0]in,
    output logic signed [W-1 :0]out
);
    localparam N = 2 ** LOG2N;
    logic signed [W-1 :0]Dly[N-1];
    always_ff@(posedge clk) begin
        if(rst) Dly <= '{N-1{'0}};
        else if(en)Dly <= {in, Dly[0 : N-3]};
    end
    
    function integer StgWidth(integer k);  //
        if(k == 0) StgWidth = W;
		    else StgWidth = W + $clog2(k);
    endfunction
    
    logic signed [W+LOG2N-1 :0]Adder[N];
    assign Adder[0] = in;
    generate
        for(genvar k = 0; k < N - 1; k++)begin : Adders_wire
            localparam DW = StgWidth(k);
            assign Adder[k + 1] = Adder[k][DW-1 :0] + Dly[k];
        end
    endgenerate
    
    always_ff@(posedge clk)begin
        if(rst) out <= '0;
        else if(en) out <= Adder[N-1] >>> LOG2N;
    end
endmodule
