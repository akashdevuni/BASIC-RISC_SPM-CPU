
module cpu_controller(output reg load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,load_IR,load_Y,load_Z,load_addr,write,
                      output [2:0] sel_mux1,
                      output [1:0] sel_mux2,
							 input  [7:0] IR,
							 input  Z,clk,rst    );


localparam idle = 0,
           fet1 = 1,
			  fet2 = 2,
			  dec  = 3,
			  exe  = 4,
			  rd1  = 5,
			  rd2  = 6,
			  wr1  = 7,
			  wr2  = 8,
			  br1  = 9,
			  br2  = 10,
			  halt = 11;
			  
localparam NOP = 0,
           ADD = 1,
			  SUB = 2,
			  AND = 3,
			  NOT = 4,
			  RD  = 5,
			  WR  = 6,
			  BR  = 7,
			  BRZ = 8;
			  
localparam R0 = 0,
           R1 = 1,
			  R2 = 2,
			  R3 = 3;
			  
reg [3:0] state,next_state;
reg sel_alu,sel_bus1,sel_mem;
reg sel_R0,sel_R1,sel_R2,sel_R3,sel_PC;
reg err_flag;
wire [3:0] opcode = IR[7:4];
wire [1:0] src = IR[3:2];
wire [1:0] dest = IR[1:0];


assign sel_mux1 = sel_R0 ? 0:
                  sel_R1 ? 1:
						sel_R2 ? 2:
						sel_R3 ? 3:
						sel_PC ? 4:3'bx;
assign sel_mux2 = sel_alu ? 0:
                  sel_bus1 ? 1:
						sel_mem ? 3:2'bx;
						
						
always@(posedge clk,negedge rst) begin : State_transtitions
if(rst==0) state <= idle; else state <= next_state; end

always@(*) begin 
sel_R0 = 0;sel_R1 = 0;sel_R2 = 0;sel_R3 = 0;sel_PC = 0;
load_R0 = 0;load_R1 = 0;load_R2 = 0;load_R3 = 0;load_PC = 0;
load_IR = 0;load_Y = 0; load_Z = 0;load_addr = 0;
inc_PC = 0;
sel_bus1 = 0;
sel_alu = 0;
sel_mem = 0;
write = 0;
err_flag = 0;

next_state = state;
case(state) 
             idle : next_state = fet1;
				 fet1 : begin
				        next_state = fet2;
						  sel_PC = 1;
						  sel_bus1 = 1;
						  load_addr = 1;
						  end
				 fet2 : begin 
				        next_state = dec;
						  sel_mem = 1;
						  load_IR = 1;
						  inc_PC = 1;
						  end
				 dec  : begin
				        case(opcode) 
						               NOP : next_state = fet1;
											ADD,SUB,AND : begin 
											              next_state = exe;
															  sel_bus1 = 1;
															  load_Y = 1;
															  case(src) 
															           R0 : sel_R0 = 1;
																		  R1 : sel_R1 = 1;
																		  R2 : sel_R2 = 1;
																		  R3 : sel_R3 = 1;
																	default : err_flag = 1;
																endcase
																end // ADD,SUB,AND
											NOT : begin 
											      next_state = fet1;
													load_Z = 1;
													sel_alu = 1;
                                       case(src) 
															    R0 : sel_R0 = 1;
																 R1 : sel_R1 = 1;
																 R2 : sel_R2 = 1;
																 R3 : sel_R3 = 1;
														  default : err_flag = 1;
													 endcase
													 case(dest) 
															    R0 : load_R0 = 1;
																 R1 : load_R1 = 1;
																 R2 : load_R2 = 1;
																 R3 : load_R3 = 1;
														  default : err_flag = 1;
													 endcase
													 end // NOT
											RD : begin 
											     next_state = rd1;
												  sel_PC = 1;
												  sel_bus1 = 1;
												  load_addr = 1;
												  end
											WR : begin
										        next_state = wr1;
												  sel_PC = 1;
												  sel_bus1 = 1;
												  load_addr = 1;
												  end
											BRZ: if(Z) begin
											     next_state = br1;
												  sel_PC = 1;
												  sel_bus1 = 1;
												  load_addr = 1;
												  end
												  else begin
												  next_state = fet1;
												  inc_PC = 1;
												  end
										default: next_state = halt;
								endcase
								end
				exe: begin
					  next_state = fet1;
					  load_Z = 1;
					  sel_alu = 1;
					  case(dest)
							R0 : begin sel_R0 = 1;load_R0 = 1; end
							R1 : begin sel_R1 = 1;load_R1 = 1; end
							R2 : begin sel_R2 = 1;load_R2 = 1; end
							R3 : begin sel_R3 = 1;load_R3 = 1; end
							default : err_flag = 1;
						endcase
						end
				 rd1: begin
						next_state = rd2;
						sel_mem = 1;
						load_addr = 1;
						inc_PC = 1;
						end
				 wr1: begin
						next_state = wr2;
						sel_mem = 1;
						load_addr = 1;
						inc_PC = 1;
						end	
				 rd2: begin
						next_state = fet1;
						sel_mem = 1;
						case(dest) 
									 R0 : load_R0 = 1;
									 R1 : load_R1 = 1;
									 R2 : load_R2 = 1;
									 R3 : load_R3 = 1;
							  default : err_flag = 1;
						 endcase
						 end
				 wr2: begin
						next_state = fet1;
						write = 1;
						case(src) 
									 R0 : sel_R0 = 1;
									 R1 : sel_R1 = 1;
									 R2 : sel_R2 = 1;
									 R3 : sel_R3 = 1;
							  default : err_flag = 1;
						 endcase
						 end
				 br1: begin
						next_state = br2;
						sel_mem = 1;
						load_addr = 1;
						end
				 br2: begin
						next_state = fet1;
						load_PC = 1;
						sel_mem = 1;
						end
				halt: next_state = halt;
			default: next_state = idle;
endcase
		end

endmodule
