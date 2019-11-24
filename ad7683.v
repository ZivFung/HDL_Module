
module ad7683(
    input adclken,
    output adcs,
    input userclk,
    input addatain,
    output  [15:0] addata
    );
  //  parameter start=3'b001;
    parameter cslow=3'b010;
    parameter cslowwait=3'b011;
    parameter datalow1=3'b100;
    parameter datatrans=3'b101;
    parameter datalow2=3'b110;
    parameter cshigh=3'b111; 
	
    reg [15:0] addata1;
    reg transfinish=1'b0;
    reg [2:0]state;
    reg [3:0] b;
    reg [2:0] waita;
    reg [3:0] waitc;
    
    initial begin waita=3'b0;waitc=4'b0;addata1=16'b0;b=4'b1111;transfinish=1'b0; end
    initial begin state=cshigh;end
  
    always@(posedge userclk)//wait1 cnt (250ns)
     begin
      if(adclken)begin
       if(state==cslowwait)
        begin
         if(waita<3'd3)
          waita<=waita+1;
         else
          waita<=3'b0;
        end  //state if
       end   //adclken if
      end
    wire waitaen=(waita==3'd3); //cs low wait enable}   begin 
 
    
    always@(posedge userclk)//wait2 cnt (400ns)
     begin
      if(adclken)begin
       if(state==cshigh)
        begin
         if(waitc<4'd2)
          waitc<=waitc+1;
         else
          waitc<=4'b0;
        end  //state if
       end   //adclken if
      end
    wire waitcen=(waitc==4'd2); //cs high wait enable
    

    always@(posedge userclk)
       begin
        if(adclken)
         begin
           if(state==datatrans)
            begin
             addata1[b]<=addatain;
             b=b-1'b1;
            end
           else
           addata1<=addata1;
          end  //adclken if
       end 
  wire waitben=(b==4'd0);
  
  
    always@(posedge userclk)
    begin
    if(adclken)
    begin
    case(state)
    //start:begin state=state+1'b1;end
    cslow:begin state=state+1'b1; end
    cslowwait:begin state=state+ ((waitaen==1'b1)? 1'd1:1'b0);end
    datalow1:begin state=state+1'b1; end
    datatrans:begin 
              state=state+( (waitben==1'b1)? 1'b1:1'b0);
              end
    datalow2:begin state=state+1'b1;end
    cshigh: begin  state = state+((waitcen==1'b1)? 3'd3:1'b0); end 
    endcase
    end //if   
    end //always
	
    assign adcs = (state==cshigh);
    assign addata = addata1;
    
endmodule
