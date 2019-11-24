`timescale 1ns/1ps

//////////////////////////////////
//���Ϊ 2017.3.19
//Si5351A-B-GT��ʼ����Ĭ����·100Mʱ��
//clk:���Ͼ���100Mʱ������
//sclx:I2C SCL C3
//sda:I2C SDA C2
//////////////////////////////////

module Si5351_Init(
	input wire clk,
	output wire sclx,
	inout wire sda
);

	reg [15:0] Si351RAMData[0:58];
	initial $readmemh("registers_200M.dat", Si351RAMData); // Initialize the RAM
	
	reg scl,scl_,sda_o,sda_t,startsuccess,stopsuccess,sendsuccess;
	initial begin
		startsuccess = 1'b0;
		stopsuccess = 1'b0;
		sendsuccess = 1'b0;
		scl = 1'b1;
		sda_t = 1'b0;
	end
	
	wire sclrise,sclfall;
	assign sclrise = scl & (~scl_);
	assign sclfall = scl_ & (~scl);
	assign sclx = scl ? 1'bz : 1'b0;
	assign sda = sda_t ? (sda_o ? 1'bz : 1'b0) : 1'bz;
	
    reg [13:0] cnt_rst; initial cnt_rst = 14'd0;
    reg rst,rst_; initial rst = 1'b0;
    wire rstrise;
    assign rstrise = rst & (~rst_);
    always@(posedge clk)begin
        rst_ <= rst;
        if(cnt_rst <= 14'd9999)cnt_rst <= cnt_rst + 1'b1;
        else rst <= 1'b1;
    end
	
	reg [3:0] init;
	reg [31:0] init_regs;
	reg [5:0] cnt_data;
	always@(posedge clk)begin
		case(init)
			4'd0 : if(rstrise)init <= 4'd1;
			4'd1 : begin
					init_regs[29] <= 1'b1;
					init <= 4'd2;
				end
			4'd2 : begin
					init_regs[29] <= 1'b0;
					init <= 4'd3;
				end
			4'd3 : if(startsuccess)init <= 4'd4;
			4'd4 : begin
					init_regs[27] <= 1'b1;
					init_regs[7:0] <= 8'hc0;
					init <= 4'd5;
				end
			4'd5 : begin
					init_regs[27] <= 1'b0;
					init <= 4'd6;
				end
			4'd6 : if(sendsuccess)init <= 4'd7;
			4'd7 : begin
					init_regs[27] <= 1'b1;
					init_regs[7:0] <= Si351RAMData[cnt_data][15:8];
					init <= 4'd8;
				end
			4'd8 : begin
					init_regs[27] <= 1'b0;
					init <= 4'd9;
				end
			4'd9 : if(sendsuccess)init <= 4'd10;
			4'd10 : begin
					init_regs[27] <= 1'b1;
					init_regs[7:0] <= Si351RAMData[cnt_data][7:0];
					init <= 4'd11;
				end
			4'd11 : begin
					init_regs[27] <= 1'b0;
					init <= 4'd12;
				end
			4'd12 : if(sendsuccess)init <= 4'd13;
			4'd13 : begin
					init_regs[28] <= 1'b1;
					init <= 4'd14;
				end
			4'd14 : begin
					init_regs[28] <= 1'b0;
					init <= 4'd15;
				end
			4'd15 : if(stopsuccess)begin
					cnt_data <= cnt_data +1'b1;
					if(cnt_data < 6'd58)init <= 4'd1;
					else begin
						cnt_data <= 5'd0;
						init <= 4'd0;
					end
				end
		endcase
	end

	reg [6:0] cnt125;
	reg en800k;
	always@(posedge clk)begin								//800k信号	
		if(cnt125 < 7'd124)begin
			cnt125 <= cnt125 + 1'b1;
			en800k <= 1'b0;
		end
		else begin
			cnt125 <= 7'd0;
			en800k <= 1'b1;
		end
		scl_ <= scl;
	end
	
	reg [1:0] start; initial start = 2'd0;
	reg [1:0] stop; initial stop = 2'd0;
	reg [4:0] send; initial send = 5'd0;
	always@(posedge clk)begin
	
		if(init_regs[29])start <= 2'd1;								   //产生start信号
		if(en800k)begin
			if(start == 2'd1)begin
				sda_t <= 1'b0;
				scl <= 1'b1;
				start <= 2'd2;
			end
			else if(start == 2'd2)begin
				sda_o <= 1'b0;
				sda_t <= 1'b1;
				start <= 2'd3;
			end
			else if(start == 2'd3)begin
				scl <= 1'b0;
				start <= 2'd0;
				startsuccess <= 1'b1;
			end
		end
		if(startsuccess)startsuccess <= 1'b0;

        if(init_regs[28])stop[0] <= 1'b1;								//产生stop信号
        if(en800k)begin
			if(stop[0])begin
				scl <= 1'b1;
				stop <= 2'b10;
			end
			else if(stop[1])begin
				sda_t <= 1'b0;
				stop <= 2'd0;
				stopsuccess <= 1'b1;
			end
		end
		if(stopsuccess)stopsuccess <= 1'b0;

		if(init_regs[27])send <= 5'd1;								    //发�?�一个字节数�?
		if((send == 5'd1)&en800k)begin
			sda_o <= init_regs[7];
			send <= 5'b10000;
		end
		else if(send[4])begin
			if(en800k)scl <= ~scl;
			if(sclfall)begin
				send <= send + 1'b1;
				if(send[2:0] < 3'd7)sda_o <= init_regs[3'd6-send[2:0]];
				else begin
					sda_t <= 1'b0;
					send[4] <= 1'b0;
					send[3] <= 1'b1;
				end
			end
		end
		else if(send[3]&en800k)begin
			if(scl&(~sda))begin
				sendsuccess <= 1;
				sda_o <= 1'b0;
				sda_t <= 1'b1;
				scl <= 1'b0;
				send <= 5'd0;
			end
			else scl <= 1'b1;
		end
		if(sendsuccess)sendsuccess <= 1'b0;
		
	end
	
endmodule
