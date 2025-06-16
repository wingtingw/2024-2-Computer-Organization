// 111550120
module Decoder( 
    input  [5:0] instr_op_i, 
    output reg [1:0] ALUOp_o, 
    output reg ALUSrc_o,
    output reg RegWrite_o,	
    output reg RegDst_o,
    output reg Branch_o,
    output reg MemRead_o, 
    output reg MemWrite_o, 
    output reg MemtoReg_o,
    output reg BranchType_o
);
     

// Main function
always@(*)begin
	case(instr_op_i)
		// R-type
		6'b000000: begin // add sub and or nor slt
			ALUOp_o = 2'b00;
			ALUSrc_o = 0;
			RegDst_o = 1;
			RegWrite_o = 1;
			Branch_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
            BranchType_o = 0; 
		end

		6'b001000: begin // addi
			ALUOp_o = 2'b01;
			ALUSrc_o = 1;
			RegDst_o = 0;
			RegWrite_o = 1;
			Branch_o = 0;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0;
            BranchType_o = 0;
		end		
		6'b101011: begin // lw
			ALUOp_o = 2'b01;
			ALUSrc_o = 1;
			RegDst_o = 0;
			RegWrite_o = 1;
			Branch_o = 0;
			MemRead_o = 1;
			MemWrite_o = 0;
			MemtoReg_o = 1;
            BranchType_o = 0; 
		end
		6'b100011: begin // sw
			ALUOp_o = 2'b01;
			ALUSrc_o = 1;
			RegDst_o = 0; // DC
			RegWrite_o = 0;
			Branch_o = 0;			
			MemRead_o = 0;
			MemWrite_o = 1;
			MemtoReg_o = 0; // DC
            BranchType_o = 0; 
		end
		6'b000101: begin // beq
			ALUOp_o = 2'b10;
			ALUSrc_o = 0;
			RegDst_o = 0; // DC
			RegWrite_o = 0;	   
			Branch_o = 1;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0; // DC
            BranchType_o = 0; 
		end
		6'b000100: begin // bne
			ALUOp_o = 2'b11;
			ALUSrc_o = 0;
			RegDst_o = 0; // DC 
			RegWrite_o = 0;	   
			Branch_o = 1;
			MemRead_o = 0;
			MemWrite_o = 0;
			MemtoReg_o = 0; // DC
            BranchType_o = 1; 
		end


		default: begin
			ALUOp_o     = 2'b00;
			ALUSrc_o    = 1'b0;
			RegDst_o    = 1'b0;
			RegWrite_o  = 1'b0;	
			Branch_o    = 1'b0;
			MemRead_o   = 1'b0;
			MemWrite_o  = 1'b0;
			MemtoReg_o  = 1'b0;
            BranchType_o = 0; 
		end

	endcase
end

endmodule