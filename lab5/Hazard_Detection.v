// 111550120
module Hazard_Detection(
    input memread,
    input [31:0] instr_i,
    input [4:0] idex_regt,
    input branch,
    output reg pcwrite,
    output reg ifid_write,
    output reg ifid_flush,
    output reg idex_flush,
    output reg exmem_flush
);

wire [4:0] ifid_rs, ifid_rt;
assign ifid_rs = instr_i[25:21];
assign ifid_rt = instr_i[20:16];

always @(*) begin
    // Default: no stall, no flush
    pcwrite     = 1'b1;
    ifid_write  = 1'b1;
    ifid_flush  = 1'b0;
    idex_flush  = 1'b0;
    exmem_flush = 1'b0;

    if (memread && ((idex_regt == ifid_rs) || (idex_regt == ifid_rt))) begin
        pcwrite     = 1'b0;
        ifid_write  = 1'b0;
        idex_flush  = 1'b1;
    end

    if (branch) begin
    ifid_flush  = 1'b1;
    idex_flush  = 1'b0;
end
end

endmodule
