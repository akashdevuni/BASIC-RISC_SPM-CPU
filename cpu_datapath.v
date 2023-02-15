
module cpu_datapath(output [7:0] bus_1,IR_OUT,addr_out ,output Z_OUT,
                    input load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,load_IR,load_Y,load_Z,load_addr,clk,rst,
                    input [2:0] sel_mux1,
                    input [1:0] sel_mux2, 
						  input [7:0] mem_word );


wire [7:0] R0_OUT,R1_OUT,R2_OUT,R3_OUT;
wire [7:0] bus_2;
wire [7:0] PC_OUT;
wire [7:0] Y_out;
wire       Z_flag;
wire [7:0] ALU_OUT;
wire [7:0] mux1_out,mux2_out;
wire zero_flag;

assign bus_1 = mux1_out;
assign bus_2 = mux2_out;

  REGISTER R0(R0_OUT,bus_2,load_R0,clk,rst);
  REGISTER R1(R1_OUT,bus_2,load_R1,clk,rst);
  REGISTER R2(R2_OUT,bus_2,load_R2,clk,rst);
  REGISTER R3(R3_OUT,bus_2,load_R3,clk,rst);

  REGISTER Y(Y_OUT,bus_2,load_Y,clk,rst);
  REGISTER ADDR(addr_out,bus_2,load_addr,clk,rst);
  REGISTER IR(IR_OUT,bus_2,load_IR,clk,rst);
  
  D_FLIP_FLOP Z(Z_OUT,zero_flag,load_Z,clk,rst);
  
  RPROGRAM_COUNTER PC(PC_out,bus_2,load_PC,inc_PC,clk,rst);
  
  
  MUX_5 MUX1(mux1_out,R0_OUT,R1_OUT,R2_OUT,R3_OUT,PC_OUT,sel_mux1);
  MUX_3 MUX2(mux2_out,ALU_OUT,bus_1,mem_word,sel_mux2);
  
  
  ALU ALU1(ALU_OUT,zero_flag,Y_out,bus_1,IR);
  


endmodule


////////// module for register files //////////////

module REGISTER(output reg [7:0] data_out,input [7:0] data_in,input enable,clk,rst);


always@(posedge clk, negedge rst) 
        begin 
		  if(rst == 1'b0)  data_out <= 8'b0; 
		  else if(enable)  data_out <= data_in;
		  end
endmodule  


////////// module for D_flip flop //////////////

module D_FLIP_FLOP(output reg data_out,input data_in,input enable,clk,rst);


always@(posedge clk, negedge rst) 
        begin 
		  if(rst == 1'b0)  data_out <= 1'b0; 
		  else if(enable)  data_out <= data_in;
		  end
endmodule


////////// module for program counter //////////////

module RPROGRAM_COUNTER(output reg [7:0] data_out,input [7:0] data_in,input enable,cnt,clk,rst);


always@(posedge clk, negedge rst) 
        begin 
		  if(rst == 1'b0)  data_out <= 8'b0; 
		  else if(enable)  data_out <= data_in;
		  else if(cnt)     data_out <= data_out + 8'd1;
		  end
endmodule 


////////////// module for 5 input mux //////////

module MUX_5( output reg [7:0] out, input [7:0] in1,in2,in3,in4,in5, input[2:0] sel);

always@(*)
begin
case(sel)
	 3'd0   : out = in1;
	 3'd1   : out = in2;
	 3'd2   : out = in3;
	 3'd3   : out = in4;
	 3'd4   : out = in5;
	 default: out = 8'b0;
endcase
end

endmodule


////////////// module for 3 input mux //////////

module MUX_3( output reg [7:0] out, input [7:0] in1,in2,in3, input[1:0] sel);

always@(*)
begin
case(sel)
	 3'd0   : out = in1;
	 3'd1   : out = in2;
	 3'd2   : out = in3;
	 default: out = 8'b0;
endcase
end

endmodule


////////////  module for ALU /////////////

module ALU(output reg [7:0] out,output zero_flag,input [7:0] A,B,input [3:0] sel);

localparam NOP = 4'd0,
           ADD = 4'd1,
           SUB = 4'd2,
			  AND = 4'd3,
           NOT = 4'd4,
			  RD  = 4'd5,
			  WR  = 4'd6,
			  BR  = 4'd7,
			  BRZ = 4'd8;
			  
assign zero_flag = ~|out;
        

always@(*)
begin
case(sel)
   
	        NOP  : out = 8'd0;
           ADD  : out = A + B;
           SUB  : out = B - A;
			  AND  : out = A & B;
           NOT  : out = ~B;
		 default  : out = 8'd0;
	  
endcase
end
endmodule  


