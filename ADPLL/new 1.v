	input wire clk,
	input wire x;
	
	
	
	reg [1:0]xCapture;initial xCapture = 0;
	
	always@(posedge clk)begin
		xCapture <= {xCapture[0],x};
	end
	
	wire xRise = xCapture == 2'b01;