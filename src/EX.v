`include "Defines.vh"

module ex(

    input wire[`AluSelBus] alusel_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire[`InstBus] ex_inst_i,

    input wire wreg_i,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,
 
    input wire[`DoubleRegBus] hilo_temp_i,
    input wire[1:0] cnt_i,
   
    input wire mem_whilo_i,
    input wire[`RegBus] mem_hi_i,
    input wire[`RegBus] mem_lo_i,
    
    input wire wb_whilo_i,
    input wire[`RegBus] wb_hi_i,
    input wire[`RegBus] wb_lo_i,
    
    input wire[`DoubleRegBus] div_result_i,
    input wire div_ready_i,
    
    input wire[`RegBus] cp0_reg_data_i,
    input wire mem_cp0_reg_we,
    input wire[`RegAddrBus] mem_cp0_reg_write_addr,
    input wire[`RegBus] mem_cp0_reg_data,

    input wire wb_cp0_reg_we,
    input wire[`RegAddrBus] wb_cp0_reg_write_addr,
    input wire[`RegBus] wb_cp0_reg_data,


    output reg[`RegBus] div_opdata1_o,
    output reg[`RegBus] div_opdata2_o,
    output reg div_start_o,
    output reg signed_div_o,
  
    output reg[`DoubleRegBus] hilo_temp_o,  
    output reg[1:0] cnt_o,
    output reg stallreq,
     
    output reg whilo_o,
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg[`RegBus] wdata_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,

    output reg[`RegAddrBus] cp0_reg_read_addr_o,
    output reg cp0_reg_we_o,
    output reg[`RegAddrBus] cp0_reg_write_addr_o,
    output reg[`RegBus] cp0_reg_data_o
    );

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    reg[`RegBus] arithout;
    reg[`RegBus] moveout;
    reg[`RegBus] HI;
    reg[`RegBus] LO;
    reg ov_flag;
    
    
    wire[`RegBus] reg1_i_u;
    wire[`RegBus] reg2_i_u;
    wire[`RegBus] reg1_i_not;
    wire[`RegBus] add_res_temp;
    wire[`RegBus] sub_res_temp;
    wire[`RegBus] sub_res_temp_u;
    wire[`DoubleRegBus] mul_res_u;
    wire[`DoubleRegBus] mul_res;
    wire          ov_flag_sub;
    wire          ov_flag_add;
    wire mul_sign_flag;
    
    reg[`DoubleRegBus] hilo_temp_wt_hilo;
    reg stallreq_madd_msub;
    reg stallreq_div;
    
    //Add&Sub&Mul temp value
    assign add_res_temp = reg1_i + reg2_i;
    assign sub_res_temp = reg1_i - reg2_i;
    assign reg1_i_not = ~reg1_i;
        
        
    assign ov_flag_add = ((reg1_i[31] && reg2_i[31] && (~add_res_temp[31]))||
    ((~reg1_i[31]) && (~reg2_i[31]) && (add_res_temp[31]))) ? 1'b1 : 1'b0;
    
    assign ov_flag_sub = (((reg1_i[31] && (~reg2_i[31]) && (~sub_res_temp[31]))||
    ((~reg1_i[31]) && (reg2_i[31]) && (sub_res_temp[31])))) ? 1'b1 : 1'b0; 
    
    // logic 
    always @(reg1_i or reg2_i or aluop_i)
        begin
            case (aluop_i)
                `EXE_AND_OP:
                    begin
                        logicout = reg1_i & reg2_i;
                    end
                `EXE_ANDI_OP:
                    begin
                        logicout = reg1_i & reg2_i;
                    end
                `EXE_OR_OP:
                    begin
                        logicout = reg1_i | reg2_i;
                    end
                `EXE_ORI_OP:
                    begin
                        logicout = reg1_i | reg2_i;
                    end
                `EXE_XOR_OP:
                    begin
                        logicout = reg1_i ^ reg2_i;
                    end
                `EXE_XORI_OP:
                    begin
                        logicout = reg1_i ^ reg2_i;
                    end
                `EXE_NOR_OP:
                    begin
                        logicout = ~(reg1_i | reg2_i);
                    end
                default: 
                    begin
                        logicout = `ZeroWord;
                    end
            endcase
        end

//Hi LO value
    always @(mem_whilo_i or mem_hi_i or mem_lo_i or  wb_whilo_i 
    or wb_hi_i or wb_lo_i or hi_i or lo_i) begin
	if (mem_whilo_i == `WriteEnable) begin
            HI = mem_hi_i;
	        LO = mem_lo_i;
        end else if (wb_whilo_i == `WriteEnable) begin
            HI = wb_hi_i;
            LO = wb_lo_i;
	end else begin
	        HI = hi_i;
	        LO = lo_i;
        end
    end	

//MOVZ MOVN MFHI MFLO
    always @(aluop_i or reg1_i or HI or LO or ex_inst_i[15:11] or cp0_reg_data_i 
    or mem_cp0_reg_we or mem_cp0_reg_write_addr or mem_cp0_reg_data or wb_cp0_reg_we 
    or wb_cp0_reg_write_addr or wb_cp0_reg_data) begin
        begin
            case (aluop_i)
                `EXE_MOVZ_OP:
                    begin
                        moveout = reg1_i;
                    end
		        `EXE_MOVN_OP:
                    begin
			            moveout = reg1_i;
                    end
		        `EXE_MFHI_OP:
                    begin
                        moveout = HI;
                    end
		        `EXE_MFLO_OP:
                    begin
                        moveout = LO;
                    end
                `EXE_MFC0_OP:  
                    begin
                    cp0_reg_read_addr_o = ex_inst_i[15:11];
                    moveout = cp0_reg_data_i;
                    if( mem_cp0_reg_we == `WriteEnable &&
                        mem_cp0_reg_write_addr == ex_inst_i[15:11])
                    begin
                        moveout = mem_cp0_reg_data;
                    end else
                        if (wb_cp0_reg_we == `WriteEnable &&
                            wb_cp0_reg_write_addr == ex_inst_i[15:11])
                        begin
                            moveout = wb_cp0_reg_data;
                        end
                    end
		        default: 
		            begin
			            moveout = `ZeroWord;
			            cp0_reg_read_addr_o = 5'b00000;
		            end
		     endcase
	    end
    end
    
//MADD MADDU MSUB MSUSB

    always @(aluop_i or cnt_i or mul_res or cnt_i or hilo_temp_i or HI
    or LO ) begin
        begin 
            case (aluop_i)
                `EXE_MADD_OP,`EXE_MADDU_OP:
                    begin if(cnt_i == 2'b00) begin
                        hilo_temp_o = mul_res;
                        stallreq_madd_msub = `Stop;
                        cnt_o = 2'b01;
                        hilo_temp_wt_hilo = {`ZeroWord,`ZeroWord};
                    end else if(cnt_i == 2'b01) begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        cnt_o = 2'b10;
                        hilo_temp_wt_hilo = hilo_temp_i + {HI,LO};
                        stallreq_madd_msub = `NoStop;
                    end else begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        stallreq_madd_msub = `NoStop;
                        cnt_o = 2'b10;
                        hilo_temp_wt_hilo = {`ZeroWord,`ZeroWord};
                    end
                    end
                `EXE_MSUB_OP,`EXE_MSUBU_OP:
                    begin if(cnt_i == 2'b00) begin
                        hilo_temp_o = mul_res;
                        stallreq_madd_msub = `Stop;
                        cnt_o = 2'b01;
                        hilo_temp_wt_hilo = {`ZeroWord,`ZeroWord};
                    end else if(cnt_i == 2'b01) begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        stallreq_madd_msub = `NoStop;
                        cnt_o = 2'b10;
                        hilo_temp_wt_hilo = hilo_temp_i - {HI,LO};
                    end else begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        stallreq_madd_msub = `NoStop;
                        cnt_o = 2'b10;
                        hilo_temp_wt_hilo = {`ZeroWord,`ZeroWord};
                    end
                end
                default:
                    begin
                        hilo_temp_o = {`ZeroWord,`ZeroWord};
                        stallreq_madd_msub = `NoStop;
                        cnt_o = 2'b10;
                        hilo_temp_wt_hilo = {`ZeroWord,`ZeroWord};
                    end
           endcase
       end
   end
   
    always @ (aluop_i or div_ready_i or reg1_i or reg2_i) begin
		begin
			stallreq_div = `NoStop;
	        div_opdata1_o = `ZeroWord;
			div_opdata2_o = `ZeroWord;
			div_start_o = `DivStop;
			signed_div_o = 1'b0;	
			case (aluop_i) 
				`EXE_DIV_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			    div_opdata1_o = reg1_i;
						div_opdata2_o = reg2_i;
						div_start_o = `DivStart;
						signed_div_o = 1'b1;
						stallreq_div = `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    			    div_opdata1_o = reg1_i;
						div_opdata2_o = reg2_i;
						div_start_o = `DivStop;
						signed_div_o = 1'b1;
						stallreq_div = `NoStop;
					end else begin						
	    			    div_opdata1_o = `ZeroWord;
						div_opdata2_o = `ZeroWord;
						div_start_o = `DivStop;
						signed_div_o = 1'b0;
						stallreq_div = `NoStop;
					end					
				end
				`EXE_DIVU_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			    div_opdata1_o = reg1_i;
						div_opdata2_o = reg2_i;
						div_start_o = `DivStart;
						signed_div_o = 1'b0;
						stallreq_div = `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    			    div_opdata1_o = reg1_i;
						div_opdata2_o = reg2_i;
						div_start_o = `DivStop;
						signed_div_o = 1'b0;
						stallreq_div = `NoStop;
					end else begin						
	    			    div_opdata1_o = `ZeroWord;
						div_opdata2_o = `ZeroWord;
						div_start_o = `DivStop;
						signed_div_o = 1'b0;
						stallreq_div = `NoStop;
					end					
				end
				default: begin
				end
			endcase
		end
	end	

//prepare for MUL, MULT, MULTU
    assign reg1_i_u = (reg1_i[31] == 1'b0) ? reg1_i : ~reg1_i + 1;
    assign reg2_i_u = (reg2_i[31] == 1'b0) ? reg2_i : ~reg2_i + 1;
    assign mul_res_u = reg1_i_u * reg2_i_u;
    assign mul_sign_flag = reg1_i[31] ^ reg2_i[31];
    assign mul_res = mul_sign_flag ? ~mul_res_u + 1 : mul_res_u;
    
//write HILO's value , MTHI MTLO DIV DIVU
    always @(whilo_o or hi_o or lo_o or aluop_i or reg1_i 
    or HI or LO or mul_res or mul_res_u or div_result_i or hilo_temp_wt_hilo) begin
	    begin 
        case (aluop_i)
                `EXE_MTHI_OP:
                    begin
                        whilo_o = `WriteEnable;
	    		        hi_o = reg1_i;
            		    lo_o = LO;
                    end
		        `EXE_MTLO_OP:
                    begin
			            whilo_o = `WriteEnable;
	    		        hi_o = HI;
            		    lo_o = reg1_i;
                    end
                `EXE_MULT_OP:
                    begin
                        whilo_o = `WriteEnable;
                        hi_o = mul_res[63:32];
                        lo_o = mul_res[31:0];
                    end
                `EXE_MULTU_OP:
                    begin
                        whilo_o = `WriteEnable;
                        hi_o = mul_res_u[63:32];
                        lo_o = mul_res_u[31:0];
                    end
                `EXE_MADD_OP,`EXE_MADDU_OP,`EXE_MSUB_OP,`EXE_MSUBU_OP:
                    begin
                        whilo_o = `WriteEnable;
                        hi_o = hilo_temp_wt_hilo[63:32];
                        lo_o = hilo_temp_wt_hilo[31:0];
                    end
                `EXE_DIV_OP,`EXE_DIVU_OP:
                    begin
                        whilo_o = `WriteEnable;
                        hi_o = div_result_i[63:32];
                        lo_o = div_result_i[31:0];
                    end
		        default:
		            begin
			            whilo_o = `WriteDisable;
	    		        hi_o = `ZeroWord;
            		    lo_o = `ZeroWord;
		            end
	        endcase
	    end
    end

// shift
    always @(aluop_i or reg1_i[4:0] or reg2_i) begin
        begin
            case (aluop_i)
                `EXE_SLL_OP:
                    begin
                        shiftout = reg2_i << reg1_i[4:0];
                    end
                `EXE_SRL_OP:
                    begin
                        shiftout = reg2_i >> reg1_i[4:0];
                    end
                `EXE_SRA_OP:
                    begin
                        shiftout = reg2_i >>> reg1_i[4:0];
                    end
                default: 
                    begin
                        shiftout = `ZeroWord;
                    end
            endcase
        end
    end

// arithmetics
    always @(aluop_i or add_res_temp or sub_res_temp or ov_flag_add 
    or ov_flag_sub or reg1_i[31] or reg2_i[31] or reg1_i or reg2_i or reg1_i_not) begin
        begin
            arithout = `ZeroWord;
            ov_flag = 1'b0;
            case (aluop_i)
                `EXE_ADD_OP:
                    //add overflow detection        
                    begin 
                        arithout = add_res_temp;
                        ov_flag = ov_flag_add;
                    end
                `EXE_ADDI_OP:
                    //add overflow detection 
                    begin 
                        arithout = add_res_temp;
                        ov_flag = ov_flag_add;
                    end
                `EXE_ADDU_OP:
                    //no overflow detection
                    begin 
                        arithout = add_res_temp;
                        ov_flag = 1'b0;
                    end
                `EXE_ADDIU_OP:
                    //no overflow detection
                    begin 
                        arithout = add_res_temp;
                        ov_flag = 1'b0;
                    end
                `EXE_SUB_OP:
                    //sub overflow detection 
                    begin 
                        arithout = sub_res_temp;
                        ov_flag = ov_flag_sub;
                    end
                `EXE_SUBU_OP:
                    //no sub overflow detection 
                    begin 
                        arithout = sub_res_temp;
                        ov_flag = 1'b0;
                    end
                `EXE_SLT_OP:
                    //compare rs and rt's value
                    begin if((reg1_i[31] == 1'b0) && (reg2_i[31] == 1'b1)) begin
                            arithout = 1'b0;
                        end else if((reg1_i[31] == 1'b1) && (reg2_i[31] == 1'b0)) begin
                            arithout = 1'b1;
                        end else begin
                            arithout = reg1_i[31] ^ ov_flag_sub;
                        end
                    end
                `EXE_SLTI_OP:
                    //compare rs and rt's value
                    begin if((reg1_i[31] == 1'b0) && (reg2_i[31] == 1'b1)) begin
                            arithout = 1'b0;
                        end else if((reg1_i[31] == 1'b1) && (reg2_i[31] == 1'b0)) begin
                            arithout = 1'b1;
                        end else begin
                            arithout = reg1_i[31] ^ ov_flag_sub;
                        end
                    end
                `EXE_SLTU_OP:
                    //compare rs and rt's value
                     begin if(reg1_i < reg2_i) begin    //the same sign
                            arithout = 1'b1;
                        end else  begin    //the same sign
                            arithout = 1'b0;
                        end
                    end
                `EXE_SLTIU_OP:
                    //compare rs and rt's value
                     begin if(reg1_i < reg2_i) begin    //the same sign
                            arithout = 1'b1;
                        end else  begin    //the same sign
                            arithout = 1'b0;
                        end
                    end
                /*
                `EXE_CLZ_OP: begin 				//a counter 
			     	arithout = (reg1_i[31] ? 0 : reg1_i[30] ? 1 :
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
			     	arithout = (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 :
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
                 */
                default: 
                    begin
                        arithout = `ZeroWord;
                        ov_flag = 1'b0;
                    end
            endcase
        end
    end
    
    //stall request
    always @(stallreq_madd_msub or stallreq_div) begin
        stallreq = stallreq_madd_msub || stallreq_div;
    end

    // finally write back to regs
    always @(wd_i or wreg_i or aluop_i or ov_flag or alusel_i 
    or logicout or shiftout or moveout or arithout or mul_res[31:0]) begin
        wd_o = wd_i;
	if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_flag == 1'b1)) begin
        wreg_o = `WriteDisable;
	end else begin 
	    wreg_o = wreg_i;
	end
        case (alusel_i)
            `EXE_RES_LOGIC:
                begin
                    wdata_o = logicout;
                end 
            `EXE_RES_SHIFT:
                begin
                    wdata_o = shiftout;
                end
	        `EXE_RES_MOVE:
                begin
		            wdata_o = moveout;
		        end
	        `EXE_RES_ARITHMETIC:
		        begin
		            wdata_o = arithout;
		        end
	        `EXE_RES_MUL:
		        begin
		            wdata_o = mul_res[31:0];////
		        end
            default: 
                begin
                    wdata_o = `ZeroWord;
                end
        endcase
    end
    
    // writing process of MTC0
    always @ ( aluop_i or reg1_i or ex_inst_i[15:11] ) begin
        if(aluop_i == `EXE_MTC0_OP) begin
            cp0_reg_write_addr_o = ex_inst_i[15:11];
            cp0_reg_we_o = `WriteEnable;
            cp0_reg_data_o = reg1_i;    
        end else begin
            cp0_reg_write_addr_o = 5'b00000;
            cp0_reg_we_o = `WriteDisable;
            cp0_reg_data_o = `ZeroWord;
        end
    end
endmodule

