

 module MUX_VAR #(parameter size) (output reg [8*size-1:0] out, input [8*size-1:0] in,input [$clog2(size)-1:0]ctrl);
 
integer i,j;
 
always@(*) begin 

    for(i=0;i<size;i=i+8) 
	 begin
	 
	 if(ctrl == j) out[i+7:i] = in[i+7:i];
	 
	 j = j + 1;
	 
	 end
	 
end

 endmodule
 