// 111550120

`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Adder.v"
`include "Decoder.v"
`include "ALU.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Shift_Left_Two_32.v"

module Simple_Single_CPU(
    clk_i,
    rst_i
);
		
// I/O ports
input clk_i;
input rst_i;

// Internal signals
wire [31:0] pc_current, pc_next, pc_add4;
wire [31:0] instruction;
wire [5:0] op = instruction[31:26];
wire [4:0] rs = instruction[25:21];
wire [4:0] rt = instruction[20:16];
wire [4:0] rd = instruction[15:11];
wire [5:0] funct = instruction[5:0];
wire [15:0] imm = instruction[15:0];
wire [25:0] address = instruction[25:0];
wire [4:0] shamt = instruction[10:6];

wire [1:0] RegDst, MemtoReg, Branch;
wire [1:0] ALUOp;
wire RegWrite, ALUSrc, Jump, MemRead, MemWrite;

wire [3:0] ALU_control;
wire [31:0] rs_data, rt_data, alu_src2, alu_result;
wire [31:0] mem_data, write_data;
wire [31:0] imm_ext, imm_shift, branch_addr, jump_addr;
wire [4:0] write_reg;
wire zero;

// Components

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_current)
);

Instr_Memory IM(
    .pc_addr_i(pc_current),
    .instr_o(instruction)
);

Reg_File Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(rs),
    .RTaddr_i(rt),
    .RDaddr_i(write_reg),
    .RDdata_i(write_data),
    .RegWrite_i(RegWrite),
    .RSdata_o(rs_data),
    .RTdata_o(rt_data)
);

Data_Memory Data_Memory(
    .clk_i(clk_i),
    .addr_i(alu_result),
    .data_i(rt_data),
    .MemRead_i(MemRead),
    .MemWrite_i(MemWrite),
    .data_o(mem_data)
);

Adder Adder1(
    .src1_i(pc_current),
    .src2_i(32'd4),
    .sum_o(pc_add4)
);

Decoder Decoder(
    .instr_op_i(op),
    .ALU_op_o(ALUOp),
    .ALUSrc_o(ALUSrc),
    .RegWrite_o(RegWrite),
    .RegDst_o(RegDst),
    .Branch_o(Branch),
    .Jump_o(Jump),
    .MemRead_o(MemRead),
    .MemWrite_o(MemWrite),
    .MemtoReg_o(MemtoReg)
);

MUX_3to1 #(.size(5)) Mux_Write_Reg(
    .data0_i(rt),
    .data1_i(rd),
    .data2_i(5'd31),
    .select_i(RegDst),
    .data_o(write_reg)
);

Sign_Extend SE(
    .data_i(imm),
    .data_o(imm_ext)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
    .data0_i(rt_data),
    .data1_i(imm_ext),
    .select_i(ALUSrc),
    .data_o(alu_src2)
);

ALU_Ctrl ALU_Ctrl(
    .funct_i(funct),
    .ALUOp_i(ALUOp),
    .ALUCtrl_o(ALU_control)
);

ALU ALU(
    .src1_i(rs_data),
    .src2_i(alu_src2),
    .shamt_i(shamt),
    .ctrl_i(ALU_control),
    .result_o(alu_result),
    .zero_o(zero)
);

MUX_3to1 #(.size(32)) Mux_MemtoReg(
    .data0_i(alu_result),
    .data1_i(mem_data),
    .data2_i(pc_add4),
    .select_i(MemtoReg),
    .data_o(write_data)
);

Shift_Left_Two_32 Shifter(
    .data_i(imm_ext),
    .data_o(imm_shift)
);

Adder Adder2(
    .src1_i(pc_add4),
    .src2_i(imm_shift),
    .sum_o(branch_addr)
);

assign jump_addr = {pc_add4[31:28], address, 2'b00};

assign pc_next = (Jump) ? jump_addr :
                 (Branch == 2'b01 && zero) ? branch_addr : // beq
                 (Branch == 2'b10 && !zero) ? branch_addr : // bne
                 pc_add4;

endmodule
