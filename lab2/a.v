`timescale 1ns/1ps
`include "ALU_1bit.v"

module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output reg   [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow          (output)
	);
    
    // zcv
    // zero, cout, overflow

    /* Write down your code HERE */

    wire Ainvert, Binvert;
    wire [31:0] cin;
    wire [31:0] res;
    wire [31:0] less;
    wire cout_31;

    assign Ainvert   = ALU_control[3];
    assign Binvert   = ALU_control[2];
    assign cin[0]    = ALU_control[2];

    // wire set;
    // assign set = (src1[31] ^ Binvert) & ~src2[31];

    // assign less[0] = (ALU_control == 4'b0111) ? set : 1'b0;
    // assign less[31:1] = 31'b0;


    ALU_1bit alu_lsbs[30:0] (
        .src1(src1[30:0]),
        .src2(src2[30:0]),
        .less(1'b0),
        .Ainvert(Ainvert),
        .Binvert(Binvert),
        .cin(cin[30:0]),
        .operation(ALU_control[1:0]),
        .result(res[30:0]),
        .cout(cin[31:1])
    );

    ALU_1bit alu_msb (
        .src1(src1[31]),
        .src2(src2[31]),
        .less(1'b0),
        .Ainvert(Ainvert),
        .Binvert(Binvert),
        .cin(cin[31]),
        .operation(ALU_control[1:0]),
        .result(res[31]),
        .cout(cout_31)
    );

    always @(*) begin
        result = res;
        zero = ~( |result );
        if (ALU_control == 4'b0010 || ALU_control == 4'b0110) begin
            overflow = (cin[31] ^ cout_31);
            cout = cout_31;
        end else begin
            overflow = 1'b0;
            cout = 1'b0;
        end

        // if (ALU_control == 4'b0111) begin
        //     if (result[31] == 1'b1 && (cin[31] ^ cout_31) == 1'b0) begin // [31] == 1 -> negative and no overflow
        //         result = 32'b1;
        //     end else if (result[31] == 1'b0 && (cin[31] ^ cout_31) == 1'b1) begin // positive but overflow
        //         result = 32'b1;
        //     end else begin
        //         result = 32'b0;
        //     end
        // end
        if (ALU_control == 4'b0111) begin
            result = {31'b0, res[31] ^ (src1[31] ^ src2[31]) & (src1[31] ^ res[31])};
            zero = ~( |result );
        end


        if (rst_n == 1'b0) begin
            result = 32'b0;
            cout = 1'b0;
            zero = 1'b1;
            overflow = 1'b0;
        end
    end


endmodule
