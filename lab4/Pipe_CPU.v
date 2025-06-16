// 111550120

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"

`timescale 1ns / 1ps

module Pipe_CPU(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

// ==== IF stage signals ====
wire [31:0] pc_current, pc_next, pc_plus4, instr_IF;
wire        PCSrc_EX;

// ==== ID stage signals ====
wire [31:0] pc_plus4_ID, instr_ID;

// control signals from ID
wire        RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID;
wire        Branch_ID, ALUSrc_ID, RegDst_ID;
wire [1:0]  ALUOp_ID;

// register read / immediate
wire [31:0] RegData1_ID, RegData2_ID, signExt_ID;
wire [4:0]  rs_ID, rt_ID, rd_ID;

// funct field for EX
wire [5:0]  funct_ID;

// ==== EX stage signals ====
// control
wire        RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX;
wire        Branch_EX, ALUSrc_EX, RegDst_EX;
wire [1:0]  ALUOp_EX;

// data
wire [31:0] pc_plus4_EX, RegData1_EX, RegData2_EX, signExt_EX;
wire [4:0]  rs_EX, rt_EX, rd_EX;
wire [5:0]  funct_EX;

// ALU inputs / outputs
wire [31:0] ALU_in2_EX, ALU_result_EX, shift_ext_EX, branch_addr_EX;
wire        zero_EX;

// ALU control output
wire [3:0] ALUCtrl_EX;

// chosen write register
wire [4:0]  writeReg_EX;

// ==== MEM stage signals ====
wire        RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM;
wire        zero_MEM;
wire [31:0] ALU_result_MEM, RegData2_MEM, branch_addr_MEM;
wire [4:0]  writeReg_MEM;

// Data memory read
wire [31:0] MemData_MEM;

// ==== WB stage signals ====
wire        RegWrite_WB, MemtoReg_WB;
wire [31:0] MemData_WB, ALU_result_WB;
wire [4:0]  writeReg_WB;
wire [31:0] writeData_WB;

// ===================== IF stage =====================
ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_current)
);

Adder Add_PC(
    .src1_i(pc_current),
    .src2_i(32'd4),
    .sum_o(pc_plus4)
);

Instruction_Memory IM(
    .addr_i(pc_current),
    .instr_o(instr_IF)
);

Pipe_Reg #(.size(64)) IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({pc_plus4, instr_IF}),
    .data_o({pc_plus4_ID, instr_ID})
);

// ===================== ID stage =====================
Decoder Decoder_ID(
    .instr_op_i(instr_ID[31:26]),
    .RegWrite_o(RegWrite_ID),
    .ALUOp_o(ALUOp_ID),
    .ALUSrc_o(ALUSrc_ID),
    .RegDst_o(RegDst_ID),
    .Branch_o(Branch_ID),
    .MemRead_o(MemRead_ID),
    .MemWrite_o(MemWrite_ID),
    .MemtoReg_o(MemtoReg_ID)
);

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(instr_ID[25:21]),
    .RTaddr_i(instr_ID[20:16]),
    .RDaddr_i(writeReg_WB),
    .RDdata_i(writeData_WB),
    .RegWrite_i(RegWrite_WB),
    .RSdata_o(RegData1_ID),
    .RTdata_o(RegData2_ID)
);

Sign_Extend SE(
    .data_i(instr_ID[15:0]),
    .data_o(signExt_ID)
);

assign rs_ID    = instr_ID[25:21];
assign rt_ID    = instr_ID[20:16];
assign rd_ID    = instr_ID[15:11];
assign funct_ID = instr_ID[5:0];

localparam ID_EX_W = 9 + 32*4 + 5*3 + 6;
Pipe_Reg #(.size(ID_EX_W)) ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID,
             Branch_ID, ALUOp_ID, ALUSrc_ID, RegDst_ID,
             pc_plus4_ID, RegData1_ID, RegData2_ID, signExt_ID,
             rs_ID, rt_ID, rd_ID, funct_ID}),
    .data_o({RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX,
             Branch_EX, ALUOp_EX, ALUSrc_EX, RegDst_EX,
             pc_plus4_EX, RegData1_EX, RegData2_EX, signExt_EX,
             rs_EX, rt_EX, rd_EX, funct_EX})
);

// ===================== EX stage =====================
Shift_Left_Two_32 Shifter(
    .data_i(signExt_EX),
    .data_o(shift_ext_EX)
);
Adder Add_Branch(
    .src1_i(pc_plus4_EX),
    .src2_i(shift_ext_EX),
    .sum_o(branch_addr_EX)
);

ALU_Ctrl ALU_Control(
    .funct_i(funct_EX),
    .ALUOp_i(ALUOp_EX),
    .ALUCtrl_o(ALUCtrl_EX)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
    .data0_i(RegData2_EX),
    .data1_i(signExt_EX),
    .select_i(ALUSrc_EX),
    .data_o(ALU_in2_EX)
);

ALU ALU_Unit(
    .src1_i(RegData1_EX),
    .src2_i(ALU_in2_EX),
    .ctrl_i(ALUCtrl_EX),
    .result_o(ALU_result_EX),
    .zero_o(zero_EX)
);

// ===================== EX -> MEM =====================
MUX_2to1 #(.size(5)) Mux_RegDst(
    .data0_i(rt_EX),
    .data1_i(rd_EX),
    .select_i(RegDst_EX),
    .data_o(writeReg_EX)
);

localparam EX_MEM_W = 1+1+1+1+1 + 1 + 32+32+32 + 5;
Pipe_Reg #(.size(EX_MEM_W)) EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, Branch_EX,
             zero_EX, ALU_result_EX, RegData2_EX, branch_addr_EX, writeReg_EX}),
    .data_o({RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM,
             zero_MEM, ALU_result_MEM,RegData2_MEM,branch_addr_MEM,writeReg_MEM})
);

// ===================== MEM stage =====================
Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(ALU_result_MEM),
    .data_i(RegData2_MEM),
    .MemRead_i(MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .data_o(MemData_MEM)
);

// ===================== MEM -> WB =====================
localparam MEM_WB_W = 1+1 + 32 + 32 + 5;
Pipe_Reg #(.size(MEM_WB_W)) MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({RegWrite_MEM, MemtoReg_MEM, MemData_MEM, ALU_result_MEM, writeReg_MEM}),
    .data_o({RegWrite_WB, MemtoReg_WB, MemData_WB, ALU_result_WB, writeReg_WB})
);

// ===================== WB stage =====================
MUX_2to1 #(.size(32)) Mux_MemToReg(
    .data0_i(ALU_result_WB),
    .data1_i(MemData_WB),
    .select_i(MemtoReg_WB),
    .data_o(writeData_WB)
);

// // ===================== DEBUG LOGGING =====================
// always @(posedge clk_i) begin
//     // EX stage debug
//     if (RegWrite_EX || MemWrite_EX)
//         $display("[DBG EX] %0t EX: ALUop=%b A=%h B=%h -> Res=%h (zero=%b)",
//                  $time, ALUCtrl_EX, RegData1_EX, ALU_in2_EX, ALU_result_EX, zero_EX);
//     // MEM stage debug
//     if (MemWrite_MEM)
//         $display("[DBG MEM] %0t SW: Mem[%h] <= %h", $time, ALU_result_MEM, RegData2_MEM);
//     // WB stage debug
//     if (RegWrite_WB)
//         $display("[DBG WB]  %0t WB: R[%0d] <= %h", $time, writeReg_WB, writeData_WB);
// end

// ===================== PC update =====================
assign PCSrc_EX = Branch_EX & zero_EX;
MUX_2to1 #(.size(32)) Mux_PC_Source(
    .data0_i(pc_plus4),
    .data1_i(branch_addr_EX),
    .select_i(PCSrc_EX),
    .data_o(pc_next)
);

endmodule
