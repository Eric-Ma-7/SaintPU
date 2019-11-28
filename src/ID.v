/* This is the ID stage of St.PU */
/*  */
`include "Defines.vh"



module id(
input wire [`RegBus] pc_i,
input wire [`RegBus] inst_i,
input wire [`RegBus] reg1_data_i,
input wire [`RegBus] reg2_data_i,
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
input wire is_in_delayslot_i,

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
output reg              reg1_read_o,
output reg              reg2_read_o,
/* Stall Request From ID stage. */
output wire             stallreq_from_id,

output reg              next_inst_in_delayslot_o,
output reg              branch_flag_o,
output reg [`RegBus]    branch_target_address_o,
output reg [`RegBus]    link_addr_o,
output reg              is_in_delayslot_o,

output wire [`RegBus]        excepttype_o,
output wire [`InstAddrBus]   current_inst_addr_o
);
/* Internal Signals Define */
wire [`ImmBus]          imm;
wire [`InstOpBus]       inst_op;
wire [`InstFuncBus]     inst_func;
wire [`InstShamtBus]    inst_sa;
wire [`RegAddrBus]      rs_addr;
wire [`RegAddrBus]      rt_addr;
wire [`RegAddrBus]      rd_addr;
wire [`RegBus]          sign_imm;
wire [`RegBus]          unsign_imm;
wire [`RegBus]          pc_plus_8;
wire [`RegBus]          pc_plus_4;
wire [`RegBus]          imm_sll2_signedext;

reg [`RegBus]           imm_o;
reg                     excepttype_is_syscall;
reg                     excepttype_is_eret;
reg                     instvalid;

assign pc_plus_8 = pc_i + 4'h8;
assign pc_plus_4 = pc_i + 4'h4;
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
assign imm = inst_i[15:0];
assign inst_op = inst_i[31:26];
assign inst_func = inst_i[5:0];
assign inst_sa = inst_i[10:6];
assign rs_addr = inst_i[25:21];
assign rt_addr = inst_i[20:16];
assign rd_addr = inst_i[15:11];
assign sign_imm = {{16{imm[15]}},imm};
assign unsign_imm = {16'h0,imm};


assign stallreq_from_id = `NoStop;

assign excepttype_o = {19'b0, excepttype_is_eret, 2'b0, instvalid, excepttype_is_syscall,8'b0};

assign current_inst_addr_o = pc_i;

always @(rd_addr or rs_addr or rt_addr or inst_op or inst_func or inst_sa 
or unsign_imm or imm or sign_imm or inst_i[31:21] or inst_i[10:0] or inst_i[20:16] or pc_plus_8 or reg1_o) 
    begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        wd_o = rd_addr;
        wreg_o = `WriteDisable;
        reg1_read_o = `Disable;
        reg2_read_o = `Disable;
        reg1_addr_o = rs_addr;
        reg2_addr_o = rt_addr;
        imm_o = `ZeroWord;
        instvalid = `InstInvalid;
        
        link_addr_o = `ZeroWord;
		branch_target_address_o = `ZeroWord;
		branch_flag_o = `NotBranch;
		next_inst_in_delayslot_o = `NotInDelaySolt;
		
		excepttype_is_syscall = `False_v;
		excepttype_is_eret = `False_v;
		
        if(inst_i[31:21] == 11'b01000000000 && inst_i[10:0] == 11'b00000000000) //mfc0
    	begin
    		aluop_o = `EXE_MFC0_OP;
    		alusel_o = `EXE_RES_MOVE;
    		wd_o = inst_i[20:16];
    		wreg_o = `WriteEnable;
    		reg1_read_o = 1'b0;
    		reg2_read_o = 1'b0;
    		instvalid = `InstValid;
    	end else if (inst_i[31:21] == 11'b01000000100 && inst_i[10:0] == 11'b00000000000) //mtc0
    	begin
    		aluop_o = `EXE_MTC0_OP;
    		alusel_o = `EXE_RES_NOP;
    		wreg_o = `WriteDisable;
    		reg1_read_o = 1'b1;
    		reg1_addr_o = inst_i[20:16];
    		reg2_read_o = 1'b0;
    		instvalid = `InstValid;
    	end else if (inst_i == `EXE_ERET) begin
    	    wreg_o = `WriteDisable;
            aluop_o = `EXE_ERET_OP;
            alusel_o = `EXE_RES_NOP;
            reg1_read_o = `Disable;
            reg2_read_o = `Disable;
            instvalid = `InstValid;
            excepttype_is_eret = `True_v;
        end else
    	begin
        case (inst_op)
            `EXE_REGIMM_INST: begin
                case(rt_addr)
                    `EXE_TEQI: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TEQI_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    `EXE_TGEI: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TGEI_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    `EXE_TGEIU: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TGEIU_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    `EXE_TLTI: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TLTI_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    `EXE_TLTIU: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TLTIU_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    `EXE_TNEI: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TNEI_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        imm_o = {{16{inst_i[15]}},inst_i[15:0]};
                        instvalid = `InstValid;
                    end
                    default: begin
                    end
                endcase
             end
            `EXE_SPECIAL_INST:  begin
             if (rs_addr == 5'h0) begin 
                    case (inst_func)
                        `EXE_SLL: begin
                            wreg_o = `WriteEnable;
                            aluop_o = `EXE_SLL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            reg1_read_o = `Disable;
                            reg2_read_o = `Enable;
                            imm_o = {27'h0,inst_sa};
                            wd_o = rd_addr;
                            instvalid = `InstValid;
                        end
                        `EXE_SRL: begin
                            wreg_o = `WriteEnable;
                            aluop_o = `EXE_SRL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            reg1_read_o = `Disable;
                            reg2_read_o = `Enable;
                            imm_o = {27'h0,inst_sa};
                            wd_o = rd_addr;
                            instvalid = `InstValid;
                        end
                        `EXE_SRA: begin
                            wreg_o = `WriteEnable;
                            aluop_o = `EXE_SRA_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            reg1_read_o = `Disable;
                            reg2_read_o = `Enable;
                            imm_o = {27'h0,inst_sa};
                            wd_o = rd_addr;
                            instvalid = `InstValid;
                        end

                        default: begin
                        end
                    endcase
                end else begin
                case (inst_func)
                    `EXE_TEQ: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TEQ_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Disable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid; 
                    end
                    `EXE_TGE: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TGE_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_TGE: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TGEU_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_TLT: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TLT_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_TLTU: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TLTU_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_TNE: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_TNE_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SYSCALL: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_SYSCALL_OP;
                        alusel_o = `EXE_RES_NOP;
                        reg1_read_o = `Disable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid;
                        
                        excepttype_is_syscall = `True_v;
                    end
                    `EXE_OR: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_OR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_AND: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_AND_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_XOR: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_XOR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_NOR: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_NOR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SLLV: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SLL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SRLV: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SRL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SRAV: begin
                         wreg_o = `WriteEnable;
                        aluop_o = `EXE_SRA_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_ADD: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_ADD_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SUB: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SUB_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_ADDU: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_ADDU_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SUBU: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SUBU_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_SLT: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SLT_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    
                    `EXE_SLTU: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_SLTU_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MULT: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MULT_OP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MULTU: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MULTU_OP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MFHI: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_MFHI_OP;
                        alusel_o = `EXE_RES_MOVE;
                        reg1_read_o = `Disable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid;
                    end
                    `EXE_MFLO: begin
                        wreg_o = `WriteEnable;
                        aluop_o = `EXE_MFLO_OP;
                        alusel_o = `EXE_RES_MOVE;
                        reg1_read_o = `Disable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid;
                    end
                    `EXE_MTHI: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MTHI_OP;
                        alusel_o = `EXE_RES_MOVE;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid;
                    end
                    `EXE_MTLO: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MTLO_OP;
                        alusel_o = `EXE_RES_MOVE;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Disable;
                        instvalid = `InstValid;
                    end
                    `EXE_DIV: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_DIV_OP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_DIVU: begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_DIVU_OP;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MADD:  begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MADD_OP;
                        alusel_o = `EXE_RES_MUL;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MADDU:  begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MADDU_OP;
                        alusel_o = `EXE_RES_MUL;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MSUB:  begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MSUB_OP;
                        alusel_o = `EXE_RES_MUL;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_MSUBU:  begin
                        wreg_o = `WriteDisable;
                        aluop_o = `EXE_MSUBU_OP;
                        alusel_o = `EXE_RES_MUL;
                        reg1_read_o = `Enable;
                        reg2_read_o = `Enable;
                        instvalid = `InstValid;
                    end
                    `EXE_JR: begin // jrָ��
						wreg_o = `WriteDisable;
						aluop_o = `EXE_JR_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						link_addr_o = `ZeroWord;
						branch_target_address_o = reg1_o;
						branch_flag_o = `Branch;
						next_inst_in_delayslot_o = `InDelaySlot;
						instvalid = `InstValid;
					end
					`EXE_JALR: begin // jalrָ��
						wreg_o = `WriteEnable;
						aluop_o = `EXE_JALR_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						wd_o = inst_i[15:11];
						link_addr_o = pc_plus_8;
						branch_target_address_o = reg1_o;
						branch_flag_o = `Branch;
						next_inst_in_delayslot_o = `InDelaySlot;
						instvalid = `InstValid;
					end
                    default: begin
                    end
                endcase
                end
            end
            `EXE_ORI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_ORI_OP;
                alusel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = unsign_imm;   
                wd_o =  rt_addr;
                instvalid = `InstValid;
            end
            `EXE_ANDI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_ANDI_OP;
                alusel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = unsign_imm;
                wd_o =  rt_addr;
                instvalid = `InstValid;
            end
            `EXE_XORI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_XORI_OP;
                alusel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = unsign_imm;
                wd_o =  rt_addr;
                instvalid = `InstValid;
            end
            `EXE_LUI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_OR_OP;
                alusel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Disable;
                reg2_read_o = `Disable;
                imm_o = {imm,16'h0};
                wd_o = rt_addr;
                instvalid = `InstValid;
            end
            `EXE_ADDI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_ADDI_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = sign_imm;
                wd_o = rt_addr;
                instvalid = `InstValid;
            end
            `EXE_ADDIU: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_ADDIU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = unsign_imm;
                wd_o = rt_addr;
                instvalid = `InstValid;
            end
            `EXE_SLTI: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_SLTI_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = sign_imm;
                wd_o = rt_addr;
                instvalid = `InstValid;
            end
            `EXE_SLTIU: begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_SLTIU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Enable;
                reg2_read_o = `Disable;
                imm_o = sign_imm;
                wd_o = rt_addr;
                instvalid = `InstValid;
            end
			`EXE_J: begin
				wreg_o = `WriteDisable;
				aluop_o = `EXE_J_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Disable;
				reg2_read_o = `Disable;
				link_addr_o = `ZeroWord;
				branch_flag_o = `Branch;
				next_inst_in_delayslot_o = `InDelaySlot;
				branch_target_address_o =
				{pc_plus_4[31:28], inst_i[25:0], 2'b00};
				instvalid = `InstValid;
			end
			`EXE_JAL: begin
				wreg_o = `WriteEnable;
				aluop_o = `EXE_JAL_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Disable;
				reg2_read_o = `Disable;
				wd_o = 5'b11111;
				link_addr_o = pc_plus_8 ;
				branch_flag_o = `Branch;
				next_inst_in_delayslot_o = `InDelaySlot;
						branch_target_address_o =
				{pc_plus_4[31:28], inst_i[25:0], 2'b00};
				instvalid = `InstValid;
			end
			`EXE_BEQ: begin
				wreg_o = `WriteDisable;
				aluop_o = `EXE_BEQ_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Enable;
				reg2_read_o = `Enable;
				if(reg1_o == reg2_o) begin
					branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
					branch_flag_o = `Branch;
					next_inst_in_delayslot_o = `InDelaySlot;
				instvalid = `InstValid;
				end
			end
			`EXE_BGTZ: begin
				wreg_o = `WriteDisable;
				aluop_o = `EXE_BGTZ_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Enable;
				reg2_read_o = `Disable;
				if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
					branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
					branch_flag_o = `Branch;
					next_inst_in_delayslot_o = `InDelaySlot;
				end
				instvalid = `InstValid;
			end
			`EXE_BLEZ: begin
				wreg_o = `WriteDisable;
				aluop_o = `EXE_BLEZ_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Enable;
				reg2_read_o = `Disable;
				if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
					branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
					branch_flag_o = `Branch;
					next_inst_in_delayslot_o = `InDelaySlot;
				end
				instvalid = `InstValid;
			end
			`EXE_BNE: begin
				wreg_o = `WriteDisable;
				aluop_o = `EXE_BLEZ_OP;
				alusel_o = `EXE_RES_JUMP_BRANCH;
				reg1_read_o = `Enable;
				reg2_read_o = `Enable;
				if(reg1_o != reg2_o) begin
					branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
					branch_flag_o = `Branch;
					next_inst_in_delayslot_o = `InDelaySlot;
				end
				instvalid = `InstValid;
			end	
			`EXE_REGIMM_INST: begin
				case (inst_op)
					`EXE_BGEZ: begin
						wreg_o = `WriteDisable;
						aluop_o = `EXE_BGEZ_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						instvalid = `InstValid;
						if(reg1_o[31] == 1'b0) begin
							branch_target_address_o =
							pc_plus_4 + imm_sll2_signedext;
							branch_flag_o = `Branch;
							next_inst_in_delayslot_o = `InDelaySlot;
						end
					end
					`EXE_BGEZAL: begin
						wreg_o = `WriteEnable;
						aluop_o = `EXE_BGEZAL_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						link_addr_o = pc_plus_8;
						wd_o = 5'b11111;
						instvalid = `InstValid;
						if(reg1_o[31] == 1'b0) begin
							branch_target_address_o =
							pc_plus_4 + imm_sll2_signedext;
							branch_flag_o = `Branch;
							next_inst_in_delayslot_o = `InDelaySlot;
						end
					end
					`EXE_BLTZ: begin
						wreg_o = `WriteDisable;
						aluop_o = `EXE_BGEZAL_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						instvalid = `InstValid;
						if(reg1_o[31] == 1'b1) begin
							branch_target_address_o =
							pc_plus_4 + imm_sll2_signedext;
							branch_flag_o = `Branch;
							next_inst_in_delayslot_o = `InDelaySlot;
						end
					end
					`EXE_BLTZAL: begin
						wreg_o = `WriteEnable;
						aluop_o = `EXE_BGEZAL_OP;
						alusel_o = `EXE_RES_JUMP_BRANCH;
						reg1_read_o = `Enable;
						reg2_read_o = `Disable;
						link_addr_o = pc_plus_8;
						wd_o = 5'b11111;
						instvalid = `InstValid;
						if(reg1_o[31] == 1'b1) begin
							branch_target_address_o =
							pc_plus_4 + imm_sll2_signedext;
							branch_flag_o = `Branch;
							next_inst_in_delayslot_o = `InDelaySlot;
						end
					end
					default: begin
            end
				endcase
			end
			default: begin
			end
		endcase
		end
	end


always @(ex_wreg_i or ex_wd_i or reg1_read_o or reg1_addr_o or mem_wreg_i or mem_wd_i or ex_wdata_i or mem_wdata_i or reg1_data_i or imm_o) begin
    if ((ex_wreg_i == `Enable) && (ex_wd_i == reg1_addr_o) && (reg1_read_o == `Enable)) begin
        reg1_o = ex_wdata_i;
    end else if ((reg1_read_o == `Enable) && (mem_wreg_i == `Enable) && (mem_wd_i == reg1_addr_o
    )) begin
        reg1_o = mem_wdata_i;
    end else if (reg1_read_o == `Enable) begin
        reg1_o = reg1_data_i;
    end else if (reg1_read_o == `Disable) begin
        reg1_o = imm_o;
    end else begin
        reg1_o = `ZeroWord;
    end
end



always @(ex_wreg_i or ex_wd_i or reg2_read_o or reg2_addr_o or mem_wreg_i or mem_wd_i or ex_wdata_i or mem_wdata_i or reg2_data_i or imm_o) begin
    if ((ex_wreg_i == `Enable) && (ex_wd_i == reg2_addr_o) && (reg2_read_o == `Enable)) begin
        reg2_o = ex_wdata_i;
    end else if ((reg2_read_o == `Enable) && (mem_wreg_i == `Enable) && (mem_wd_i == reg2_addr_o
    )) begin
        reg2_o = mem_wdata_i;
    end else if (reg2_read_o == `Enable) begin
        reg2_o = reg2_data_i;
    end else if (reg2_read_o == `Disable) begin
        reg2_o = imm_o;
    end else begin
        reg2_o = `ZeroWord;
    end
end

always @(is_in_delayslot_i)begin
	is_in_delayslot_o = is_in_delayslot_i;
end


endmodule
