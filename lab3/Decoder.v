// 111550120
module Decoder(
    instr_op_i,
    RegWrite_o,
    ALU_op_o,
    ALUSrc_o,
    RegDst_o,
    Branch_o,
    Jump_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

// I/O ports
input  [5:0] instr_op_i;

output       RegWrite_o;
output [1:0] ALU_op_o;
output       ALUSrc_o;
output [1:0] RegDst_o;
output [1:0] Branch_o;
output       Jump_o;
output       MemRead_o;
output       MemWrite_o;
output [1:0] MemtoReg_o;

// Internal signals
reg          RegWrite_o;
reg   [1:0]  ALU_op_o;
reg          ALUSrc_o;
reg   [1:0]  RegDst_o;
reg   [1:0]  Branch_o;
reg          Jump_o;
reg          MemRead_o;
reg          MemWrite_o;
reg   [1:0]  MemtoReg_o;

// Decoder logic
always @(*) begin
    case(instr_op_i)
        6'b000000: begin // R-type
            RegWrite_o = 1;
            ALU_op_o   = 2'b10;
            ALUSrc_o   = 0;
            RegDst_o   = 2'b01;
            Branch_o   = 2'b00;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00;
        end
        6'b001000: begin // addi
            RegWrite_o = 1;
            ALU_op_o   = 2'b00;
            ALUSrc_o   = 1;
            RegDst_o   = 2'b00;
            Branch_o   = 2'b00;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00;
        end
        6'b101011: begin // lw
            RegWrite_o = 1;
            ALU_op_o   = 2'b00;
            ALUSrc_o   = 1;
            RegDst_o   = 2'b00;
            Branch_o   = 2'b00;
            Jump_o     = 0;
            MemRead_o  = 1;
            MemWrite_o = 0;
            MemtoReg_o = 2'b01;
        end
        6'b100011: begin // sw
            RegWrite_o = 0;
            ALU_op_o   = 2'b00;
            ALUSrc_o   = 1;
            RegDst_o   = 2'b00;
            Branch_o   = 2'b00;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 1;
            MemtoReg_o = 2'b00;  
        end
        6'b000101: begin // beq
            RegWrite_o = 0;
            ALU_op_o   = 2'b01;
            ALUSrc_o   = 0;
            RegDst_o   = 2'b00; 
            Branch_o   = 2'b01;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00; 
        end
        6'b000100: begin // bne
            RegWrite_o = 0;
            ALU_op_o   = 2'b01;
            ALUSrc_o   = 0;
            RegDst_o   = 2'b00; 
            Branch_o   = 2'b10;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00;
        end
        6'b000011: begin // jump
            RegWrite_o = 0;
            ALU_op_o   = 2'b00; 
            ALUSrc_o   = 0;
            RegDst_o   = 2'b00;
            Branch_o   = 2'b00;
            Jump_o     = 1;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00;
        end
        6'b000010: begin // jal
            RegWrite_o = 1;
            ALU_op_o   = 2'b00;
            ALUSrc_o   = 0;
            RegDst_o   = 2'b10;  // $ra (reg 31)
            Branch_o   = 2'b00;
            Jump_o     = 1;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b10;  // write PC+4
        end
        default: begin
            RegWrite_o = 0;
            ALU_op_o   = 2'b00;
            ALUSrc_o   = 0;
            RegDst_o   = 2'b00;
            Branch_o   = 2'b00;
            Jump_o     = 0;
            MemRead_o  = 0;
            MemWrite_o = 0;
            MemtoReg_o = 2'b00;
        end
    endcase
end

endmodule
