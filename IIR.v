module iir_2nd
  #(
      parameter w = 32,
      parameter FW = 16,
      parameter real N0 = 1,
      parameter real N1 = 1,
      parameter real N2 = 1,
      parameter real D1 = 1,
      parameter real D2 = 1
    )(
      input clk,
      input en,
      input signed [w-1:0] in,

      output signed [w-1:0] out
    );
       reg signed [w-1:0] d[0:1];
    initial begin
        d[0] = 1'sb0;
        d[1] = 1'sb0;
    end 
    
    wire signed [w-1:0] n0 = (N0 * (2.0 **FW));
    wire signed [w-1:0] n1 = (N1 * (2.0 **FW));
    wire signed [w-1:0] n2 = (N2 * (2.0 **FW));
    wire signed [w-1:0] d1 = (D1 * (2.0 **FW));
    wire signed [w-1:0] d2 = (D2 * (2.0 **FW)); 
    wire signed [2*w-1:0] pn0l = n0 * in;
    wire signed [2*w-1:0] pn1l = n1 * in;
    wire signed [2*w-1:0] pn2l = n2 * in;
    wire signed [2*w-1:0] pd1l = d1 * out;
    wire signed [2*w-1:0] pd2l = d2 * out;
    wire signed [w-1:0] pn0 = pn0l >>> FW;
    wire signed [w-1:0] pn1 = pn1l >>> FW;
    wire signed [w-1:0] pn2 = pn2l >>> FW;
    wire signed [w-1:0] pd1 = pd1l >>> FW;
    wire signed [w-1:0] pd2 = pd2l >>> FW;
    

    
    assign out = (pn0 +d[0]);
    
    always@(posedge clk)begin
      if(en)
        begin
            d[0] <= pn1 - pd1 + d[1];
            d[1] <= pn2 - pd2; 
        end
    end
    
  endmodule
      
      
  module iir_filter#( parameter w = 32,
      parameter FW = 16)
  (
      input clk,
      input en,
      input signed [w-1:0] in,
      output signed [w-1:0] out
    );
    wire signed[w-1:0]out_s1;
    wire signed[w-1:0]out_s2;
//  iir_2nd
//      #(w,FW,1*0.00041277096291271394,2*0.00041277096291271394,1*0.00041277096291271394,-1.9774301049444645,0.9790811887961155
//        )iir1(clk,en,in,out_s1);
//    iir_2nd
//      #(w,FW,1*0.00040542617240150102,2*0.00040542617240150102,1*0.00040542617240150102,-1.9422439819456572,0.94386568663526316
//        )iir2(clk,en,out_s1,out_s2);
//    iir_2nd
//       #(w,FW,1*0.00040130346458563677,2*0.00040130346458563677,1*0.00040130346458563677,-1.9224936426983112,0.9240988565566538
//        )iir3(clk,en,out_s2,out);

//  iir_2nd
//      #(w,FW,1*0.00041013736777066183,2*0.00041013736777066183,1*0.00041013736777066183,-1.9582721209005742,0.95991267037165695
//        )iir1(clk,en,in,out_s1);
//    iir_2nd
//      #(w,FW,1*0.02005188884308047,1*0.02005188884308047,0*0.02005188884308047,-0.95989622231383898,0
//        )iir2(clk,en,out_s1,out); 

   iir_2nd
      #(w,FW,1*0.99991114628907862,-2*0.99991114628907862,1*0.99991114628907862,-1.9998222846831752 ,0.99982230047313914
       )iir1(clk,en,in,out);  
  endmodule
    