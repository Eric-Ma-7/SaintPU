`include "Defines.v"

module ex(
    input wire rst,
    input wire[`AluSelBus] alusel_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    
    input wire wreg_i,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    input wire mem_whilo_i,
    input wire[`RegBus] mem_hi_i,
    input wire[`RegBus] mem_lo_i,
    
    input wire wb_whilo_i,
    input wire[`RegBus] wb_hi_i,
    input wire[`RegBus] wb_lo_i,
    
    output reg whilo_o,
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg[`RegBus] wdata_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o
    );

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    reg[`RegBus] arithout;
    reg[`RegBus] moveout;
    reg[`RegBus] HI;
    reg[`RegBus] LO;
    reg ov_flag;
    reg[63:0] mul_res;
    
    wire[`RegBus] reg1_i_u;
    wire[`RegBus] reg2_i_u;
    wire[`RegBus] reg1_i_not;
    wire[`RegBus] add_res_temp;
    wire[`RegBus] sub_res_temp;
    wire[63:0] mul_res_u;
    
    wire mul_sign_flag;
    
    //Add&Sub&Mul temp value
    assign add_res_temp = reg1_i + reg2_i;
    assign sub_res_temp = reg1_i - reg2_i;
    assign reg1_i_not = ~reg1_i;

    
    // logic 
    always @(*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_AND_OP:
                    begin
                        logicout <= reg1_i & reg2_i;
                    end
                `EXE_ANDI_OP:
                    begin
                        logicout <= reg1_i & reg2_i;
                    end
                `EXE_OR_OP:
                    begin
                        logicout <= reg1_i | reg2_i;
                    end
                `EXE_ORI_OP:
                    begin
                        logicout <= reg1_i | reg2_i;
                    end
                `EXE_XOR_OP:
                    begin
                        logicout <= reg1_i ^ reg2_i;
                    end
                `EXE_XORI_OP:
                    begin
                        logicout <= reg1_i ^ reg2_i;
                    end
                `EXE_NOR_OP:
                    begin
                        logicout <= ~(reg1_i | reg2_i);
                    end
                default: 
                    begin
                        logicout <= `ZeroWord;
                    end
            endcase
        end
    end

//Hi LO value
    always @(*) begin
	if (rst == `RstEnable) begin
	    HI <= `ZeroWord;
            LO <= `ZeroWord;
	end else if (mem_whilo_i == `WriteEnable) begin
            HI <= mem_hi_i;
	    LO <= mem_lo_i;
        end else if (wb_whilo_i == `WriteEnable) begin
            HI <= wb_hi_i;
            LO <= wb_lo_i;
	end else begin
	    HI <= hi_i;
	    LO <= lo_i;
        end
    end	

//MOVZ MOVN MFHI MFLO
    always @(*) begin
        if (rst == `RstEnable) begin
            moveout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_MOVZ_OP:
                    begin
                        moveout <= reg1_i;
                    end
		        `EXE_MOVN_OP:
                    begin
			            moveout <= reg1_i;
                    end
		        `EXE_MFHI_OP:
                    begin
                        moveout <= HI;
                    end
		        `EXE_MFLO_OP:
                    begin
                        moveout <= LO;
                    end
		        default: 
		            begin
			            moveout <= `ZeroWord;
		            end
		     endcase
	    end
    end
    
//MUL, MULT, MULTU
    assign reg1_i_u = (reg1_i[31] == 1'b0) ? reg1_i : ~reg1_i + 1;
    assign reg2_i_u = (reg2_i[31] == 1'b0) ? reg2_i : ~reg2_i + 1;
    assign mul_res_u = reg1_i_u * reg2_i_u;
    assign mul_sign_flag = reg1_i[31] ^ reg2_i[31];

    always @(*) begin
        if(mul_sign_flag == 1'b1) begin
            mul_res <= ~mul_res_u + 1;
        end else begin
            mul_res <= mul_res_u;
        end
    end

//write HILO's value , MTHI MTLO
    always @(*) begin
        if (rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
	        hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
	    end else begin 
        case (aluop_i)
                `EXE_MTHI_OP:
                    begin
                        whilo_o <= `WriteEnable;
	    		        hi_o <= reg1_i;
            		    lo_o <= LO;
                    end
		        `EXE_MTLO_OP:
                    begin
			            whilo_o <= `WriteEnable;
	    		        hi_o <= HI;
            		    lo_o <= reg1_i;
                    end
                `EXE_MULT_OP:
                    begin
                        whilo_o <= `WriteEnable;
                        hi_o <= mul_res[63:32];
                        lo_o <= mul_res[31:0];
                    end
                `EXE_MULTU_OP:
                    begin
                        whilo_o <= `WriteEnable;
                        hi_o <= mul_res_u[63:32];
                        lo_o <= mul_res_u[31:0];
                    end
		        default:
		            begin
			            whilo_o <= `WriteDisable;
	    		        hi_o <= `ZeroWord;
            		    lo_o <= `ZeroWord;
		            end
	        endcase
	    end
    end

// shift
    always @(*) begin
        if (rst == `RstEnable) begin
            shiftout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP:
                    begin
                        shiftout <= reg2_i << reg1_i[4:0];
                    end
                `EXE_SRL_OP:
                    begin
                        shiftout <= reg2_i >> reg1_i[4:0];
                    end
                `EXE_SRA_OP:
                    begin
                        shiftout <= reg2_i >>> reg1_i[4:0];
                    end
                default: 
                    begin
                        shiftout <= `ZeroWord;
                    end
            endcase
        end
    end

// arithmetics
    always @(*) begin
        if (rst == `RstEnable) begin
            arithout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_ADD_OP:
                    //add overflow detection        
                    begin if((reg1_i[31] && reg2_i[31] && (~add_res_temp[31]))||((~reg1_i[31]) && (~reg2_i[31]) && (add_res_temp[31]))) begin
                        ov_flag <= 1'b1;
                        end else begin
                        arithout <= reg2_i + reg1_i;
                        ov_flag <= 1'b0;
                        end
                    end
                `EXE_ADDI_OP:
                    //add overflow detection 
                    begin if((reg1_i[31] && reg2_i[31] && (~add_res_temp[31]))||((~reg1_i[31]) && (~reg2_i[31]) && (add_res_temp[31]))) begin
                        ov_flag <= 1'b1;
                        end else begin
                        arithout <= reg2_i + reg1_i;
                        ov_flag <= 1'b0;
                        end
                    end
                `EXE_ADDU_OP:
                    //no overflow detection
                    begin 
                        arithout <= reg2_i + reg1_i;
                        ov_flag <= 1'b0;
                    end
                `EXE_ADDIU_OP:
                    //no overflow detection
                    begin 
                        arithout <= reg2_i + reg1_i;
                        ov_flag <= 1'b0;
                    end
                `EXE_SUB_OP:
                    //sub overflow detection 
                    begin if((reg1_i[31] && (~reg2_i[31]) && (~add_res_temp[31]))||((~reg1_i[31]) && (reg2_i[31]) && (add_res_temp[31]))) begin
                        ov_flag <= 1'b1;
                        end else begin
                        arithout <= reg1_i - reg2_i;
                        ov_flag <= 1'b0;
                        end
                    end
                `EXE_SUBU_OP:
                    //no sub overflow detection 
                    begin 
                        arithout <= reg1_i - reg2_i;
                        ov_flag <= 1'b0;
                    end
                `EXE_SLT_OP:
                    //compare rs and rt's value
                    begin if((reg1_i[31] == 1'b0) && (reg2_i[31] == 1'b1)) begin
                            arithout <= 1'b0;
                        end else if((reg1_i[31] == 1'b1) && (reg2_i[31] == 1'b0)) begin
                            arithout <= 1'b1;
                        end else if(sub_res_temp[31] == 1'b0) begin    //the same sign
                            arithout <= 1'b0;
                        end else if(sub_res_temp[31] == 1'b1) begin    //the same sign
                            arithout <= 1'b1;
                        end
                    end
                `EXE_SLTI_OP:
                    //compare rs and rt's value
                    begin if((reg1_i[31] == 1'b0) && (reg2_i[31] == 1'b1)) begin
                            arithout <= 1'b0;
                        end else if((reg1_i[31] == 1'b1) && (reg2_i[31] == 1'b0)) begin
                            arithout <= 1'b1;
                        end else if(sub_res_temp[31] == 1'b0) begin    //the same sign
                            arithout <= 1'b0;
                        end else if(sub_res_temp[31] == 1'b1) begin    //the same sign
                            arithout <= 1'b1;
                        end
                    end
                `EXE_SLTU_OP:
                    //compare rs and rt's value
                    begin if(sub_res_temp[31] == 1'b0) begin    //the same sign
                            arithout <= 1'b0;
                        end else if(sub_res_temp[31] == 1'b1) begin    //the same sign
                            arithout <= 1'b1;
                        end
                    end
                `EXE_SLTIU_OP:
                    //compare rs and rt's value
                    begin if(sub_res_temp[31] == 1'b0) begin    //the same sign
                            arithout <= 1'b0;
                        end else if(sub_res_temp[31] == 1'b1) begin    //the same sign
                            arithout <= 1'b1;
                        end
                    end
                `EXE_CLZ_OP: begin 				//a counter 
			     	arithout <= (reg1_i[31] ? 0 : reg1_i[30] ? 1 :
			     				reg1_i[29] ? 2 : reg1_i[28] ? 3 :
			     				reg1_i[27] ? 4 : reg1_i[26] ? 5 :
			     				reg1_i[25] ? 6 : reg1_i[24] ? 7 :
			     				reg1_i[23] ? 8 : reg1_i[22] ? 9 :
			     				reg1_i[21] ? 10 : reg1_i[20] ? 11 :
			     				reg1_i[19] ? 12 : reg1_i[18] ? 13 :
			     				reg1_i[17] ? 14 : reg1_i[16] ? 15 :
			     				reg1_i[15] ? 16 : reg1_i[14] ? 17 :
			     				reg1_i[13] ? 18 : reg1_i[12] ? 19 :
			     				reg1_i[11] ? 20 : reg1_i[10] ? 21 :
			     				reg1_i[9] ? 22 : reg1_i[8] ? 23 :
			     				reg1_i[7] ? 24 : reg1_i[6] ? 25 :
			     				reg1_i[5] ? 26 : reg1_i[4] ? 27 :
			     				reg1_i[3] ? 28 : reg1_i[2] ? 29 :
			     				reg1_i[1] ? 39 : reg1_i[0] ? 31 : 32) ;
			     end
			     `EXE_CLO_OP: 	begin
			     	arithout <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 :
			     				reg1_i_not[29] ? 2 : reg1_i_not[28] ? 3 :
			     				reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
			     				reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 :
			     				reg1_i_not[23] ? 8 : reg1_i_not[22] ? 9 :
			     				reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
			     				reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 :
			     				reg1_i_not[17] ? 14 : reg1_i_not[16] ? 15 :
			     				reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 :
			     				reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 :
			     				reg1_i_not[11] ? 20 : reg1_i_not[10] ? 21 :
			     				reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 :
			     				reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 :
			     				reg1_i_not[5] ? 26 : reg1_i_not[4] ? 27 :
			     				reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 :
			     				reg1_i_not[1] ? 39 : reg1_i_not[0] ? 31 : 32) ;
			     end
                default: 
                    begin
                        arithout <= `ZeroWord;
                    end
            endcase
        end
    end



    // finally write back to regs
    always @(*) begin
        wd_o <= wd_i;
	if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_flag == 1'b1)) begin
        wreg_o <= `WriteDisable;
	end else begin 
	    wreg_o <= wreg_i;
	end
        case (alusel_i)
            `EXE_RES_LOGIC:
                begin
                    wdata_o <= logicout;
                end 
            `EXE_RES_SHIFT:
                begin
                    wdata_o <= shiftout;
                end
	        `EXE_RES_MOVE:
                begin
		            wdata_o <= moveout;
		        end
	        `EXE_RES_ARITHMETIC:
		        begin
		            wdata_o <= arithout;
		        end
	        `EXE_RES_MUL:
		        begin
		            wdata_o <= mul_res[31:0];////
		        end
            default: 
                begin
                    wdata_o <= `ZeroWord;
                end
        endcase
    end
    
endmodule
