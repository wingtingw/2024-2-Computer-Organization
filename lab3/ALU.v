// 111550120
module ALU(
    src1_i,
    src2_i,
	shamt_i,
    ctrl_i,
    result_o,
    zero_o,
    overflow
    );
     
// I/O ports
input  [31:0]  src1_i;
input  [31:0]  src2_i;
input  [3:0]   ctrl_i;
input  [4:0]   shamt_i;

output reg [31:0] result_o;
output            zero_o;
output reg        overflow;

// Internal signal

always @(*) begin
    overflow = 0;
    case (ctrl_i)
        4'b0000: result_o = src1_i & src2_i;                     // AND
        4'b0001: result_o = src1_i | src2_i;                     // OR
        4'b0010: begin                                           // ADD
            result_o = src1_i + src2_i;
            overflow = (~src1_i[31] & ~src2_i[31] & result_o[31]) | 
                       (src1_i[31] & src2_i[31] & ~result_o[31]);
        end
        4'b0110: begin                                           // SUB
            result_o = src1_i - src2_i;
            overflow = (~src1_i[31] & src2_i[31] & result_o[31]) |
                       (src1_i[31] & ~src2_i[31] & ~result_o[31]);
        end
        4'b0111: result_o = ($signed(src1_i) < $signed(src2_i)) ? 1 : 0; // SLT
        4'b1100: result_o = ~(src1_i | src2_i);                  // NOR
        4'b1000: result_o = src2_i << shamt_i[4:0];               // SLL
        4'b1001: result_o = src2_i >> shamt_i[4:0];               // SRL
        4'b1010: result_o = src2_i << src1_i[4:0];               // SLLV
        4'b1011: result_o = src2_i >> src1_i[4:0];               // SRLV
        default: result_o = 0;
    endcase
end

assign zero_o = (result_o == 0);

endmodule
