// 111550120
module Decoder( 
    input  [5:0] instr_op_i, 
    output reg [1:0] ALUOp_o,
    output reg       ALUSrc_o,
    output reg       RegWrite_o,    
    output reg       RegDst_o,
    output reg       Branch_o,
    output reg       MemRead_o, 
    output reg       MemWrite_o, 
    output reg       MemtoReg_o
);
always @(*) begin
    case(instr_op_i)
        6'b000000: begin // R-type
            RegWrite_o  = 1; ALUSrc_o    = 0; RegDst_o  = 1;
            Branch_o    = 0; MemRead_o   = 0; MemWrite_o= 0;
            MemtoReg_o  = 0; ALUOp_o     = 2'b10;
        end
        6'b001000: begin // addi
            RegWrite_o  = 1; ALUSrc_o    = 1; RegDst_o  = 0;
            Branch_o    = 0; MemRead_o   = 0; MemWrite_o= 0;
            MemtoReg_o  = 0; ALUOp_o     = 2'b00;
        end
        6'b101011: begin // lw
            RegWrite_o  = 1; ALUSrc_o    = 1; RegDst_o  = 0;
            Branch_o    = 0; MemRead_o   = 1; MemWrite_o= 0;
            MemtoReg_o  = 1; ALUOp_o     = 2'b00;
        end
        6'b100011: begin // sw
            RegWrite_o  = 0; ALUSrc_o    = 1; RegDst_o  = 0; // x
            Branch_o    = 0; MemRead_o   = 0; MemWrite_o= 1;
            MemtoReg_o  = 0; ALUOp_o     = 2'b00;
        end
        6'b000101, // beq
        6'b000100: // bne
        begin
            RegWrite_o  = 0; ALUSrc_o    = 0; RegDst_o  = 0; // x
            Branch_o    = 1; MemRead_o   = 0; MemWrite_o= 0;
            MemtoReg_o  = 0; ALUOp_o     = 2'b01;
        end
    endcase
end
endmodule
