/* This is the ID stage of St.PU */
/*  */
module ID(
input reg [`RegBus] pc_i,
input reg [`RegBus] inst_i,
input wire [`RegBus] reg1_data_i,
input wire [`RegBus] reg2_data_i,
/* Reset Signal */
input wire rst,
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