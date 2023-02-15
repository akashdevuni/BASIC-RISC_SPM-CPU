

module RAM(output [7:0] out,input [7:0] in,addr,input clk,write);

reg [7:0] memory[255:0];

assign out = memory[addr];
always@(posedge clk) begin
if(write) memory[addr] <= in; end

endmodule
