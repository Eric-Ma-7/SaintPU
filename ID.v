/* This is the ID stage of St.PU */
/*  */
`define InstOpBus 5:0
`define InstFuncBus 5:0
`define ImmBus 15:0

module ID(
input reg [`RegBus] pc_i,
input reg [`RegBus] inst_i,
input wire [`RegBus] reg1_data_i,
input wire [`RegBus] reg2_data_i,
/* Reset Signal */
input wire rst,
/* Ex data input enable */
input wire ex_wreg_i;
/* Ex data input destination addr */
input wire [`RegAddrBus] ex_wd_i;
/* EX data input*/
input wire [`RegBus] ex_wdata_i
/* Output Ports */
/* ALU Operation Code */
output reg [`AluOpBus] aluop_o,
/* ALU Opaeration Type Select */
output reg [`AluSelBus] alusel_o,
output reg [`RegBus] reg1_o,
output reg [`RegBus] reg2_o,
/* Write Destination */
output reg [`RegAddrBus] wd_o,
/* Write Enable */
output wire wreg_o,
/* Register Files Address */
output reg [`RegAddrBus] reg1_addr_o,
output reg [`RegAddrBus] reg2_addr_o,
/* Register Read Enable */
output wire reg1_read_o,
output wire reg2_read_o,
);
/* Internal Signals Define */
wire [`ImmBus] imm = inst_i[15:0];
wire [`InstOpBus] inst_op = inst_i[31:26];
wire [`InstFuncBus] inst_func = inst_i[5:0];
wire [`] inst_sa;
wire [`RegAddrBus] rs_addr;
wire [`RegAddrBus] rt_addr;
wire [`RegAddrBus] rd_addr;
wire [`RegBus] sign_imm = {16{imm[15]},imm};
wire [`RegBus] unsign_imm = {16{1'b0},imm};

always @(*) begin
    
end