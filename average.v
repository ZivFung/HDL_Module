`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2017 02:18:22 PM
// Design Name: 
// Module Name: average
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module average#(
     parameter DATA0_W=32,
     parameter DATA1_W=32,
     parameter DATA2_W=32,
     parameter DATA3_W=32,
     parameter AVE_NUM=8,
     parameter AVE_W=3
             
)(
     input clk,
     input [DATA0_W-1:0]data_in0,
     input [DATA1_W-1:0]data_in1,
     input [DATA2_W-1:0]data_in2,
     input [DATA3_W-1:0]data_in3, 
     input data0_en,
     input data1_en,
     input data2_en,
     input data3_en,
     
     output [DATA0_W-1:0]data_out0,
     output [DATA1_W-1:0]data_out1,
     (* mark_debug="true" *)output [DATA2_W-1:0]data_out2,
     (* mark_debug="true" *)output [DATA3_W-1:0]data_out3 

    );
    
    
    reg [DATA0_W-1:0] data_delay0[AVE_NUM-1:0];
    reg [DATA0_W-1:0] data_delay1[AVE_NUM-1:0];
    reg [DATA0_W-1:0] data_delay2[AVE_NUM-1:0];
    reg [DATA0_W-1:0] data_delay3[AVE_NUM-1:0];
    
    reg [DATA0_W-1+AVE_W:0]data0_sum;
    reg [DATA0_W-1+AVE_W:0]data1_sum;
    reg [DATA0_W-1+AVE_W:0]data2_sum;
    reg [DATA0_W-1+AVE_W:0]data3_sum;
    
    reg [DATA0_W-1+AVE_W:0]data0_summation;
    reg [DATA0_W-1+AVE_W:0]data1_summation;
    reg [DATA0_W-1+AVE_W:0]data2_summation;
    reg [DATA0_W-1+AVE_W:0]data3_summation; 
    
    
    reg[AVE_W:0] cnt0;
    reg[AVE_W:0] cnt1;
    reg[AVE_W:0] cnt2;
    reg[AVE_W:0] cnt3;
    
    always@(posedge clk)
      begin
        if(data0_en)
          begin
            if(cnt0<AVE_NUM)
              begin
                data0_sum<=data0_sum+data_in0;
                cnt0=cnt0+1;
              end
            else
              begin
                data0_sum<=0;
                data0_summation<=data0_sum;
                cnt0<=0;
              end
          end       
        else
          begin
            data0_summation<=data0_summation;
          end
      end
    
    
    always@(posedge clk)
        begin
          if(data1_en)
            begin
              if(cnt1<AVE_NUM)
                begin
                  data1_sum<=data1_sum+data_in1;
                  cnt1=cnt1+1;
                end
              else
                begin
                  data1_sum<=0;
                  data1_summation<=data1_sum;
                  cnt1<=0;
                end
            end       
          else
            begin
              data1_summation<=data1_summation;
            end
        end
        
    always@(posedge clk)
          begin
            if(data2_en)
              begin
                if(cnt2<AVE_NUM)
                  begin
                    data2_sum<=data2_sum+data_in2;
                    cnt2=cnt2+1;
                  end
                else
                  begin
                    data2_sum<=0;
                    data2_summation<=data2_sum;
                    cnt2<=0;
                  end
              end       
            else
              begin
                data2_summation<=data2_summation;
              end
          end
          
    always@(posedge clk)
            begin
              if(data3_en)
                begin
                  if(cnt3<AVE_NUM)
                    begin
                      data3_sum<=data3_sum+data_in3;
                      cnt3=cnt3+1;
                    end
                  else
                    begin
                      data3_sum<=0;
                      data3_summation<=data3_sum;
                      cnt3<=0;
                    end
                end       
              else
                begin
                  data3_summation<=data3_summation;
                end
            end
//    always@(posedge clk)
//      begin
//      if(data0_en)
//        begin
//          data_delay0[0]<=data_in0;
//        end
//      end
      
      
//    genvar k;
//    generate
//    if(data0_en)
//      begin
//        for(k=1;k<AVE_NUM;k=k+1)begin:stages0
//          always@(posedge clk)
//            begin
//              data_delay0[k]<=data_delay0[k-1];
//            end
//        end
//      end          
//     endgenerate
        
//    genvar i;
//     generate
//     if(data1_en)
//       begin
//         for(i=1;i<AVE_NUM;i=i+1)begin:stages1
//           always@(posedge clk)
//             begin
//               data_delay1[i]<=data_delay1[i-1];
//             end
//         end
//       end          
//      endgenerate 
    
//    genvar m;
//       generate
//       if(data2_en)
//         begin
//           for(m=1;m<AVE_NUM;m=m+1)begin:stages2
//             always@(posedge clk)
//               begin
//                 data_delay2[m]<=data_delay2[m-1];
//               end
//           end
//         end          
//        endgenerate 
        
//    genvar n;
//         generate
//         if(data3_en)
//           begin
//             for(n=1;n<AVE_NUM;n=n+1)begin:stages3
//               always@(posedge clk)
//                 begin
//                   data_delay3[n]<=data_delay3[n-1];
//                 end
//             end
//           end          
//          endgenerate  

//    genvar a;
//    generate
//        for(a=0;a<AVE_NUM;a=a+1)begin:stages4
//          always@(posedge clk)
//            begin
//              data0_sum<=data0_sum+data_delay0[a];
//              if(a==AVE_NUM-1)
//                begin
//                  data0_summation<=data0_sum;
//                  a<=0;
//                end
//            end
//        end  
//    endgenerate
    
//    genvar b;
//    generate
//        for(b=0;b<AVE_NUM;b=b+1)begin:stages5
//          always@(posedge clk)
//            begin
//              data1_sum<=data1_sum+data_delay1[b];
//              if(b==AVE_NUM-1)
//                begin
//                  data1_summation<=data1_sum;
//                  b<=0;
//                end
//            end
//        end  
//    endgenerate
    
//    genvar c;
//    generate
//        for(c=0;c<AVE_NUM;c=c+1)begin:stages6
//          always@(posedge clk)
//            begin
//              data2_sum<=data2_sum+data_delay2[c];
//              if(c==AVE_NUM-1)
//                begin
//                  data2_summation<=data2_sum;
//                  c<=0;
//                end
//            end
//        end  
//    endgenerate
    
//    genvar d;
//    generate
//        for(d=0;d<AVE_NUM;d=d+1)begin:stages7
//          always@(posedge clk)
//            begin
//              data3_sum<=data3_sum+data_delay3[d];
//              if(d==AVE_NUM-1)
//                begin
//                  data3_summation<=data3_sum;
//                  d<=0;
//                end
//            end
//        end  
//    endgenerate
    
    
    assign data_out0=(data0_summation>>AVE_W);
    assign data_out1=(data1_summation>>AVE_W);
    assign data_out2=(data2_summation>>AVE_W);
    assign data_out3=(data3_summation>>AVE_W);
    
endmodule
