// 111550120
`timescale 1ns/1ps
`include "MUX_2to1.v"
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output reg          result,     //1 bit result    (output)
	// output reg          cout        //1 bit carry out (output)
	output           cout        //1 bit carry out (output)
	);
		
/* Write down your code HERE */
wire a_in, b_in;

assign a_in = Ainvert ? ~src1 : src1;
assign b_in = Binvert ? ~src2 : src2;
assign cout = (a_in & b_in) | (a_in & cin) | (b_in & cin); // cout = ab + a*cin + b*cin

always @(*) begin
	case (operation)
		2'b00: result = a_in & b_in;
		2'b01: result = a_in | b_in;
		2'b10: result = a_in ^ b_in ^ cin; // a xor b xor cin
		2'b11: result = a_in ^ b_in ^ cin;
		// 2'b11: result = less;
		default: result = 0;
	endcase	
end

endmodule
