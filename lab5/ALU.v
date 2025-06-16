// 111550120
module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
// TO DO
input  [31:0] src1_i;
input  [31:0] src2_i;
input  [3:0]  ctrl_i;
output reg [31:0] result_o;
output       zero_o;

assign zero_o = (result_o == 0);

always @(*) begin
    case(ctrl_i)
        4'b0000: result_o = src1_i + src2_i; // add
        4'b0001: result_o = src1_i - src2_i; // sub
        4'b0010: result_o = src1_i & src2_i; // and
        4'b0011: result_o = src1_i | src2_i; // or
        4'b0100: result_o = ~(src1_i | src2_i); // nor
        4'b0101: result_o = (src1_i < src2_i) ? 1 : 0; // slt
        default: result_o = 0;
    endcase
end

endmodule