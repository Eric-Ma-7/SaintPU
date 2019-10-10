/* This is the ID stage of St.PU */
/*  */
`define InstOpBus 5:0
`define InstFuncBus 5:0
`define InstShamtBus 4:0
`define ImmBus 15:0
`define Enable 1'b1
`define Disable 1'b0

module id(
input wire [`RegBus] pc_i,
input wire [`RegBus] inst_i,
input wire [`RegBus] reg1_data_i,
input wire [`RegBus] reg2_data_i,
/* Reset Signal */
input wire rst,
/* EX data input enable */
input wire ex_wreg_i,
/* Ex data input destination addr */
input wire [`RegAddrBus] ex_wd_i,
/* EX data input*/
input wire [`RegBus] ex_wdata_i,
/* MEM data input enable*/
input wire mem_wreg_i,
/* MEM data input destination addr*/
input wire [`RegAddrBus] mem_wd_i,
/* MEM data input */
input wire [`RegBus] mem_wdata_i,
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
output reg wreg_o,
/* Register Files Address */
output reg [`RegAddrBus] reg1_addr_o,
output reg [`RegAddrBus] reg2_addr_o,
/* Register Read Enable */
output reg reg1_read_o,
output reg reg2_read_o.
/* Stall Request From ID stage. */
output reg stallreq_from_id
);
/* Internal Signals Define */
wire [`ImmBus] imm = inst_i[15:0];
wire [`InstOpBus] inst_op = inst_i[31:26];
wire [`InstFuncBus] inst_func = inst_i[5:0];
wire [`InstShamtBus] inst_sa = inst_i[10:6];
wire [`RegAddrBus] rs_addr = inst_i[25:21];
wire [`RegAddrBus] rt_addr = inst_i[20:16];
wire [`RegAddrBus] rd_addr = inst_i[15:11];
wire [`RegBus] sign_imm = {{16{imm[15]}},imm};
wire [`RegBus] unsign_imm = {16'h0,imm};
reg [`RegBus] imm_o;

assign stallreq = `NoStop;

always @(rst, inst_i, reg1_data_i, reg2_data_i, pc_i) begin
    if (rst == `RstEnable) begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        wd_o = `NOPRegAddr;
        wreg_o = `WriteDisable;
        reg1_read_o = `Disable;
        reg2_read_o = `Disable;
        reg1_addr_o = `NOPRegAddr;
        reg2_addr_o = `NOPRegAddr;
        imm_o = `ZeroWord;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= rd_addr;
        reg1_read_o <= `Disable;
        reg2_read_o <= `Disable;
        reg1_addr_o <= rs_addr;
        reg2_addr_o <= rt_addr;
        imm_o <= `ZeroWord;
        case (inst_op)
            `EXE_SPECIAL_INST:  begin
                case (inst_func)
                    `EXE_OR: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_OR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_AND: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_AND_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_XOR: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_XOR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_NOR: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_NOR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SLLV: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SLL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SRLV: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SRL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SRAV: begin
                         wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SRA_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_ADD: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_ADD_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SUB: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SUB_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_ADDU: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_ADDU_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SUBU: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SUBU_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SLT: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SLT_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_SLTU: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_SLTU_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_MULT: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MULT_OP;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_MULTU: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MULTU_OP;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_MFHI: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_MFHI_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= `Disable;
                        reg2_read_o <= `Disable;
                    end
                    `EXE_MFLO: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_MFLO_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= `Disable;
                        reg2_read_o <= `Disable;
                    end
                    `EXE_MTHI: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MTHI_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;
                    end
                    `EXE_MTLO: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MTLO_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;
                    end
                    `EXE_DIV: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_DIV_OP;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    `EXE_DIVU: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_DIVU_OP;
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Enable;
                    end
                    default: begin
                    end
                endcase
                if (rs_addr == 5'h0) begin 
                    case (inst_func)
                        `EXE_SLL: begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `Disable;
                            reg2_read_o <= `Enable;
                            imm_o <= {27'h0,inst_sa};
                            wd_o <= rd_addr;
                        end
                        `EXE_SRL: begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `Disable;
                            reg2_read_o <= `Enable;
                            imm_o <= {27'h0,inst_sa};
                            wd_o <= rd_addr;
                        end
                        `EXE_SRA: begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SRA_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `Disable;
                            reg2_read_o <= `Enable;
                            imm_o <= {27'h0,inst_sa};
                            wd_o <= rd_addr;
                        end
                    endcase
                end
            end
            `EXE_ORI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= unsign_imm;
                wd_o <=  rt_addr;
            end
            `EXE_ANDI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_AND_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= unsign_imm;
                wd_o <=  rt_addr;
            end
            `EXE_XORI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_XOR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= unsign_imm;
                wd_o <=  rt_addr;
            end
            `EXE_LUI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `Disable;
                reg2_read_o <= `Disable;
                imm_o <= {imm,16'h0};
                wd_o <= rt_addr;
            end
            `EXE_ADDI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADD_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= sign_imm;
                wd_o <= rt_addr;
            end
            `EXE_ADDIU: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADDU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= unsign_imm;
                wd_o <= rt_addr;
            end
            `EXE_SLTI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLT_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= sign_imm;
                wd_o <= rt_addr;
            end
            `EXE_SLTIU: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLTU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                imm_o <= unsign_imm;
                wd_o <= rt_addr;
            end
            default: begin
            end
        endcase
    end
end

always @(rst, ex_wd_i, ex_wreg_i, reg1_read_o, reg1_addr_o, mem_wd_i, mem_wreg_i) begin
    if (rst == `RstEnable) begin
        reg1_o <=  `ZeroWord;
    end else if ((ex_wreg_i == `Enable) && (ex_wd_i == reg1_addr_o) && (reg1_read_o == `Enable)) begin
        reg1_o <= ex_wdata_i;
    end else if ((reg1_read_o == `Enable) && (mem_wreg_i == `Enable) && (mem_wd_i == reg1_addr_o
    )) begin
        reg1_o <= mem_wdata_i;
    end else if (reg1_read_o == `Enable) begin
        reg1_o <= reg1_data_i;
    end else if (reg1_read_o == `Disable) begin
        reg1_o <= imm_o;
    end else begin
        reg1_o <= `ZeroWord;
    end
end

always @(rst, ex_wd_i, ex_wreg_i, reg2_read_o, reg2_addr_o, mem_wd_i, mem_wreg_i) begin
    if (rst == `RstEnable) begin
        reg2_o <=  `ZeroWord;
    end else if ((ex_wreg_i == `Enable) && (ex_wd_i == reg2_addr_o) && (reg2_read_o == `Enable)) begin
        reg2_o <= ex_wdata_i;
    end else if ((reg2_read_o == `Enable) && (mem_wreg_i == `Enable) && (mem_wd_i == reg2_addr_o
    )) begin
        reg2_o <= mem_wdata_i;
    end else if (reg2_read_o == `Enable) begin
        reg2_o <= reg1_data_i;
    end else if (reg2_read_o == `Disable) begin
        reg2_o <= imm_o;
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule