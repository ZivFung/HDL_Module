module ad7705
  (
       input  clk,
       input  DRDYn,
       output din,
       output cs,
       output rst,
       input  dout,
       input  [31:0]config_data,       //bit0 rst,bit1 start,bit2 rd 1/wr 0,bit3 big 1/small 0 reg      
       output [15:0]read_data
  );
  
  
   /*     
RS2 RS1 RS0 Register Register   Size
0 0 0 Communication register    8 bits
0 0 1 Setup register            8 bits
0 1 0 Clock register            8 bits
0 1 1 Data register             16 bits
1 0 0 Test register             8 bits
1 0 1 No operation
1 1 0 Offset register           24 bits
1 1 1 Gain register             24 bits
  */
    parameter RST=0;
    parameter IDLE=1;  
    parameter START=2;
    parameter READ=3;
    parameter WRITE_SMALL=4;
    parameter WRITE_BIG=5;
    //parameter READ=6;
    
    parameter READ_WAIT=1;
    parameter READ_CSL=2;
    parameter READ_DATA=3;
    parameter READ_FINISH=4;
    
    parameter WRITE_START=1;
    parameter WRITE_CSL=2;
    parameter WRITE_DATA=3;
    parameter WRITE_FINISH=4;
    
    reg [31:0] config_da;
    reg [3:0]  state,next_state;
    reg [2:0]  read_state;
    reg [15:0] read_da;
    reg [4:0]  bit0;
    reg [2:0]  write_state;
    reg [5:0]  bit1;
    reg [5:0]  bit2;
    reg [0:0]  din_da;
    
    initial 
      begin
        config_da=32'b0;
        bit0=5'd16;
        bit1=6'd31;
        bit2=6'd31;
        state=4'd1;
        read_state=4'd1;
        write_state=4'd1;
        din_da=1'b0;
      end
    
    always@(posedge clk)
      begin
        case(state)
          RST:
            begin
              config_da<=config_data;
              if(config_da[0])
                state<=state;
              else if(~config_da[0])   //means that you should write rst=0 after you write rst=1
                state<=IDLE;
            end
            
          IDLE:
            begin
              config_da<=config_data;
              if(config_da[0])
                state<=RST;
              else if(~config_da[0]&config_da[1])
                state<=START;
              else
                state<=state;
            end
            
          START:
            begin
              if(config_da[2])
                state<=READ;
              else if(~config_da[2])
                begin
                  if(config_da[3])
                    state<=WRITE_BIG;
                  else
                    state<=WRITE_SMALL;
                end
              else
                state<=state;             
            end
            
          READ:
            begin
              
              case(read_state)
                READ_WAIT:
                  begin
                    if(~DRDYn)
                      read_state<=READ_CSL;
                    else
                      read_state<=read_state;
                  end
                
                READ_CSL:
                  begin
                    read_state<=READ_DATA;
                  end
                  
                READ_DATA:
                  begin
                    if(bit0>=1)
                      begin
                        read_da[bit0-1]<=dout;
                        bit0<=bit0-1;
                      end
                    else
                      begin
                        bit0<=16;
                        read_state<=READ_FINISH;
                      end
                   end
                      
                 READ_FINISH:
                   begin
                     read_state<=READ_WAIT;
                     state<=IDLE;
                   end
                 default:read_state<=read_state;          
              endcase
           
            end
            
          WRITE_SMALL:
            begin
              case(write_state)
                WRITE_START:
                  begin
                    write_state<=WRITE_CSL;
                  end
                
                WRITE_CSL:
                  begin
                    write_state<=WRITE_DATA;        
                  end
                
                WRITE_DATA:
                  begin
                    if(bit1>=6'd24)
                      begin
                        din_da<=config_da[bit1];
                        bit1<=bit1-1;
                      end
                    else
                      begin
                        din_da<=1'b0;
                        bit1<=6'd31;
                        write_state<=WRITE_FINISH;
                      end
                  end
                  
                WRITE_FINISH:
                  begin
                    write_state<=WRITE_START;
                    state<=IDLE;
                  end 
                
                default:write_state<=write_state;   
              endcase
            end
            
          WRITE_BIG:
            begin
              case(write_state)
                WRITE_START:
                  begin
                    write_state<=WRITE_CSL;
                  end
                
                WRITE_CSL:
                  begin
                    write_state<=WRITE_DATA;        
                  end
                
                WRITE_DATA:
                  begin
                    if(bit2>=6'd8)
                      begin
                        din_da<=config_da[bit1];
                        bit2<=bit2-1;
                      end
                    else
                      begin
                        din_da<=1'b0;
                        bit2<=6'd31;
                        write_state<=WRITE_FINISH;
                      end
                  end
                  
                WRITE_FINISH:
                  begin
                    write_state<=WRITE_START;
                    state<=IDLE;
                  end     
                default:write_state<=write_state;   
              endcase
              
            end  
            
       endcase
      end
    
//    assign cs=~(write_state==WRITE_CSL|read_state==READ_CSL|write_state==WRITE_DATA|read_state==READ_DATA);
    assign cs=~(write_state==WRITE_DATA|read_state==READ_DATA);
    assign din=din_da;
    assign rst=~(state==RST);
    assign read_data=read_da;
    
    
  endmodule
    
    
    
    
    
    

