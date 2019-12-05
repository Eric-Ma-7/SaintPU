`include "Defines.vh"

module stpu(
    input wire              rst,
    input wire              clk,
    input wire [`RegBus]    rom_data_i,
    input wire [5:0]        int_i,
   
    output wire             timer_int_o,
    output wire [`RegBus]   rom_addr_o,
    output wire             rom_ce
    );
    //Variables connecting PC and CTRL
    //CTRL
    wire[5:0]           stall;
    wire[`RegBus]       new_pc;
    wire                flush;
    
    //Variables connecting IF/ID and ID
    wire[`InstAddrBus]  pc;
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;

    //Variables Connecting ID and ID/EX
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_o;
    wire[`RegBus]       id_reg2_o;
    wire                id_wreg_o;
    wire[`RegAddrBus]   id_wd_o;    
    wire                id_in_delayslot_o;
    wire[`RegBus]       id_link_address_o;	
    wire                stallreq_id;
    wire[`RegBus]   id_excepttype_o;
    wire[`RegBus]   id_current_inst_addr_o;
    wire            id_in_delayslot_i;
    
    //Variables Connecting ID/EX and EX
    wire[`RegBus]       ex_inst_i;
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire                ex_wreg_i;
    wire[`RegAddrBus]   ex_wd_i;
    
    wire[`RegBus]       ex_excepttype_i;
    wire[`RegBus]       ex_current_inst_addr_i;
    wire                ex_is_in_delayslot_i;  


    
    //Variables Connecting EX and EX/MEM
    wire                ex_wreg_o;
    wire[`RegAddrBus]   ex_wd_o;
    wire[`RegBus]       ex_wdata_o;
    wire[`RegBus]       ex_hi_o;
    wire[`RegBus]       ex_lo_o;
    wire                ex_whilo_o;
    
    wire[1:0]           ex_cnt_o;
    wire[`DoubleRegBus] ex_hilo_temp_o;
    wire                stallreq_ex;
    
    wire                ex_cp0_reg_we_o;
    wire[`RegAddrBus]   ex_cp0_reg_write_addr_o;
    wire[`RegBus]       ex_cp0_reg_data_o;
        
    wire[`RegBus]       ex_excepttype_o;
    wire[`RegBus]       ex_current_inst_addr_o;
    wire                ex_is_in_delayslot_o;  
    
    //direct read from cp0
    wire[`RegBus]       ex_cp0_reg_data_i;
    

    

    wire[`RegBus] ex_link_address_i;	
    

	wire id_next_delayslot_o;
	wire id_branch_flag_o;
	wire[`RegBus] id_branch_address;
    
    //Variables Connecting EX/MEM and MEM
    wire                mem_wreg_i;
    wire[`RegAddrBus]   mem_wd_i;
    wire[`RegBus]       mem_wdata_i;
    wire[`RegBus]       mem_hi_i;
    wire[`RegBus]       mem_lo_i;
    wire                mem_whilo_i;
    
    wire[`RegBus]       mem_excepttype_i;
    wire[`RegBus]       mem_current_inst_address_i;
    wire                mem_is_in_delayslot_i;
    
    wire                mem_cp0_reg_we_i;
    wire[`RegAddrBus]   mem_cp0_reg_write_addr_i;
    wire[`RegBus]       mem_cp0_reg_data_i;
    
    //Variables Connecting MEM and MEM/WB
    wire                mem_wreg_o;
    wire[`RegAddrBus]   mem_wd_o;
    wire[`RegBus]       mem_wdata_o;
    wire[`RegBus]       mem_hi_o;
    wire[`RegBus]       mem_lo_o;
    wire                mem_whilo_o;    
    wire[`RegBus]       mem_excepttype_o;
    wire[`RegBus]       mem_current_inst_address_o;
    wire                mem_is_in_delayslot_o;
    
    wire                mem_cp0_reg_we_o;
    wire[`RegAddrBus]   mem_cp0_reg_write_addr_o;
    wire[`RegBus]       mem_cp0_reg_data_o;
    
    wire[`DoubleRegBus] mem_hilo_i;
    wire[1:0]           mem_cnt_i;
        
    //MEM/WB and WB
    wire                wb_wreg_i;
    wire[`RegAddrBus]   wb_wd_i;
    wire[`RegBus]       wb_wdata_i;
    wire[`RegBus]       wb_hi_i;
    wire[`RegBus]       wb_lo_i;
    wire                wb_whilo_i;
    
    wire[`RegAddrBus]   wb_cp0_reg_read_addr_i;
    wire                wb_cp0_reg_we_i;
    wire[`RegAddrBus]   wb_cp0_reg_write_addr_i;
    wire[`RegBus]       wb_cp0_reg_data_i;
    
    wire[`RegBus]       latest_epc;
    
    //Variables Connecting ID and Regfile
    wire                reg1_read;
    wire                reg2_read;
    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire[`RegAddrBus]   reg1_addr;
    wire[`RegAddrBus]   reg2_addr;
   
    //HILO
   	wire[`RegBus] 	    hi;
    wire[`RegBus]       lo;
    
    //Div
    wire                signed_div;
    wire[`RegBus]       div_opdata1;
    wire[`RegBus]       div_opdata2;
    wire                div_start;
    wire[`DoubleRegBus] div_result;
    wire                div_ready;
    
    
    //GLobal control signal

    //CP0
    wire[`RegBus]   cp0_count;
    wire[`RegBus]   cp0_compare;
    wire[`RegBus]   cp0_status;
    wire[`RegBus]   cp0_cause;
    wire[`RegBus]   cp0_epc;
    wire[`RegBus]   cp0_config;
    wire[`RegBus]   cp0_prid;
    
    
    wire[`RegBus] id_inst_o;
    assign id_inst_i = rom_data_i;
    assign rom_addr_o   =   pc;
    
    //pc reg 
    pc pc_reg0(
        .clk(clk),  
        .rst(rst),  
        .pc(pc),    
        .ce(rom_ce),
        
        .branch_flag_i(id_branch_flag_o),
		.branch_target_address_i(id_branch_address),
        
        .new_pc(new_pc),
        .flush(flush),
        .stall(stall)
    );
    
    
    
    //IF/ID
    if_id if_id0(
        .clk(clk),  
        .rst(rst),  
        .if_pc(pc),
          
        .id_pc(id_pc_i),
        
        .stall(stall),
        .flush(flush)
    );
    
    //ID
    id id0(
        .pc_i(id_pc_i), 
        .inst_i(id_inst_i),
        
        .reg1_data_i(reg1_data),     
        .reg2_data_i(reg2_data),
        
        .reg1_read_o(reg1_read),    
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),    
        .reg2_addr_o(reg2_addr),
        
        .ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),


		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),
		.is_in_delayslot_i(id_in_delayslot_i),
        
        //ID/EX
        .aluop_o(id_aluop_o),       
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),         
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),             
        .wreg_o(id_wreg_o),
        .id_inst_o(id_inst_o),
        
        .next_inst_in_delayslot_o(id_next_delayslot_o),	
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(id_branch_address),       
		.link_addr_o(id_link_address_o),
		
		.is_in_delayslot_o(id_in_delayslot_o),
        .excepttype_o(id_excepttype_o),
        .current_inst_addr_o(id_current_inst_addr_o),
        
        //stall
        .stallreq_from_id(stallreq_id)
    );
    
    //Regfile
    regfile regfile0(
        .clk(clk),          
        .rst(rst),
        .we(wb_wreg_i),     
        .waddr(wb_wd_i),
        .wdata(wb_wdata_i), 
        .re1(reg1_read),
        .raddr1(reg1_addr), 
        .rdata1(reg1_data),
        .re2(reg2_read),    
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );
    

    //ID/EX
    id_ex id_ex0(
        .clk(clk),          
        .rst(rst),
        //From ID
        .id_aluop(id_aluop_o),  
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),    
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),        
        .id_wreg(id_wreg_o),
        
        //.id_inst(if_inst_ex),
        .id_inst(id_inst_o),
        
        
        .id_link_address(id_link_address_o),
		.id_is_in_delayslot(id_in_delayslot_o),
		.next_inst_in_delayslot_i(id_next_delayslot_o),		
        .id_excepttype(id_excepttype_o),
        .id_current_inst_addr(id_current_inst_addr_o),
        
        //output
        //To EX
        .ex_aluop(ex_aluop_i),  
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),    
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),        
        .ex_wreg(ex_wreg_i),
        .ex_inst(ex_inst_i),
        .ex_excepttype(ex_excepttype_i),
        .ex_current_inst_addr(ex_current_inst_addr_i),
        
        
        .ex_link_address(ex_link_address_i),
  	    .ex_is_in_delayslot(ex_is_in_delayslot_i),
		.is_in_delayslot_o(id_in_delayslot_i),	
        
        .stall(stall),
        .flush(flush)
    );

    //EX
    ex ex0(
        .alusel_i(ex_alusel_i),
        .aluop_i(ex_aluop_i),   
        .reg1_i(ex_reg1_i),     
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),         
        .wreg_i(ex_wreg_i),
        .ex_inst_i(ex_inst_i),


        .wb_hi_i(wb_hi_i),
        .wb_lo_i(wb_lo_i),
        .wb_whilo_i(wb_whilo_i),
        
        .mem_hi_i(mem_hi_i),
        .mem_lo_i(mem_lo_i),
        .mem_whilo_i(mem_whilo_i),
        
        //HILO value from EX/MEM
        .hilo_temp_i(mem_hilo_i),
        .cnt_i(mem_cnt_i),
        
        //HILO value
        .hi_i(hi),
        .lo_i(lo),
        
        .div_result_i(div_result),
        .div_ready_i(div_ready),
        
        
        //from cp0
        .cp0_reg_data_i(ex_cp0_reg_data_i),
        
        //from mem
        .mem_cp0_reg_we(mem_cp0_reg_we_i),
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
        .mem_cp0_reg_data(mem_cp0_reg_data_i),

        //from wb
        .wb_cp0_reg_we(wb_cp0_reg_we_i),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
        .wb_cp0_reg_data(wb_cp0_reg_data_i),
        
        
        .link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),
        .excepttype_i(ex_excepttype_i),
        .current_inst_addr_i(ex_current_inst_addr_i),
        
        //output
        //to EX/MEM
        .wdata_o(ex_wdata_o),   
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        
        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o),
        
        .hilo_temp_o(ex_hilo_temp_o),
        .cnt_o(ex_cnt_o),
        .stallreq(stallreq_ex),
        
        //Div
        .signed_div_o(signed_div),
        .div_opdata1_o(div_opdata1),
        .div_opdata2_o(div_opdata2),
        .div_start_o(div_start),

        .cp0_reg_read_addr_o(wb_cp0_reg_read_addr_i),
        .cp0_reg_we_o(ex_cp0_reg_we_o),
        .cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
        .cp0_reg_data_o(ex_cp0_reg_data_o),
        .excepttype_o(ex_excepttype_o),
        .current_inst_addr_o(ex_current_inst_addr_o),
        .is_in_delayslot_o(ex_is_in_delayslot_o)
    );
    
    
    
    div div0(
        .clk(clk),
        .rst(rst),
        
        .signed_div_i(signed_div),
        .opdata1_i(div_opdata1),
        .opdata2_i(div_opdata2),
        .start_i(div_start),
        .annul_i(1'b0),
        
        .result_o(div_result),
        .ready_o(div_ready)
    );

    
    //EX/MEM
    ex_mem ex_mem0(
        //From EX
        .rst(rst),              
        .clk(clk),
        .stall(stall),
        .flush(flush),
        
        .ex_wdata(ex_wdata_o),  
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        
        .ex_hi(ex_hi_o),
        .ex_lo(ex_lo_o),
        .ex_whilo(ex_whilo_o),
        
        .hilo_i(ex_hilo_temp_o),
        .cnt_i(ex_cnt_o),
        
        .ex_cp0_reg_we(ex_cp0_reg_we_o),
        .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
        .ex_cp0_reg_data(ex_cp0_reg_data_o),

        .ex_is_in_delayslot(ex_is_in_delayslot_o),
        .ex_excepttype(ex_excepttype_o),
        .ex_current_inst_addr(ex_current_inst_addr_o),
        
        //output
        //To MEM
        .mem_wdata(mem_wdata_i), 
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        
        .mem_hi(mem_hi_i),
        .mem_lo(mem_lo_i),
        .mem_whilo(mem_whilo_i),
        
        .hilo_o(mem_hilo_i),
        .cnt_o(mem_cnt_i),

        .mem_cp0_reg_we(mem_cp0_reg_we_i),
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
        .mem_cp0_reg_data(mem_cp0_reg_data_i),
        
        .mem_excepttype(mem_excepttype_i),
        .mem_current_inst_addr(mem_current_inst_address_i),
        .mem_is_in_delayslot(mem_is_in_delayslot_i)
    );
    
    

       
    //MEM
    mem mem0(
        .wdata_i(mem_wdata_i),  
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),
        .whilo_i(mem_whilo_i),

        .cp0_reg_we_i(mem_cp0_reg_we_i),
        .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
        .cp0_reg_data_i(mem_cp0_reg_data_i),
        
        .excepttype_i(mem_excepttype_i),
        .current_inst_address_i(mem_current_inst_address_i),
        .is_in_delayslot_i(mem_is_in_delayslot_i),
        
        .cp0_status_i(cp0_status),
        .cp0_cause_i(cp0_cause),
        .cp0_epc_i(cp0_epc),
        
        
        .wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_address(wb_cp0_reg_write_addr_i),
	    .wb_cp0_reg_data(wb_cp0_reg_data_i),
        
        //To MEM/WB
        .wdata_o(mem_wdata_o),  
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o),
        .whilo_o(mem_whilo_o),

        .cp0_reg_we_o(mem_cp0_reg_we_o),
        .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
        .cp0_reg_data_o(mem_cp0_reg_data_o),
        .cp0_epc_o(latest_epc),
        .excepttype_o(mem_excepttype_o),
        .current_inst_address_o(mem_current_inst_address_o),
        .is_in_delayslot_o(mem_is_in_delayslot_o)
    );

    mem_wb mem_wb0(
        .rst(rst),              
        .clk(clk),
        .stall(stall),
        .flush(flush),
        
        //From MEM
        .mem_wdata(mem_wdata_o),
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),  
        
        .mem_hi(mem_hi_o),
        .mem_lo(mem_lo_o),
        .mem_whilo(mem_whilo_o),
        
        .mem_cp0_reg_we(mem_cp0_reg_we_o),
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
        .mem_cp0_reg_data(mem_cp0_reg_data_o),

        //To WB
        .wb_wdata(wb_wdata_i),
        .wb_wd(wb_wd_i),        
        .wb_wreg(wb_wreg_i),
        
        .wb_hi(wb_hi_i),
        .wb_lo(wb_lo_i),
        .wb_whilo(wb_whilo_i),

        .wb_cp0_reg_we(wb_cp0_reg_we_i),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
        .wb_cp0_reg_data(wb_cp0_reg_data_i)
    );
    

    hilo_reg hilo_reg0(
        .clk(clk),
        .rst(rst),
        
        //input
        .we(wb_whilo_i),
        .hi_i(wb_hi_i),
        .lo_i(wb_lo_i),
        
        //output
        .hi_o(hi),
        .lo_o(lo)
   );
   

   ctrl ctrl0(
        //input
        .stallreq_from_ex(stallreq_ex),
        .stallreq_from_id(stallreq_id),
        .rst(rst),
        .excepttype_i(mem_excepttype_o),
        .cp0_epc_i(latest_epc),
        
        .flush(flush),
        
        //output
        .stall_o(stall),
        .new_pc(new_pc)
    );  
    


   cp0 cp0_0(
        //input
        .rst(rst), 
        .clk(clk),
        .raddr_i(wb_cp0_reg_read_addr_i),    
        .int_i(int_i),
        .we_i(wb_cp0_reg_we_i),
        .waddr_i(wb_cp0_reg_write_addr_i),
        .wdata_i(wb_cp0_reg_data_i),
        .excepttype_i(mem_excepttype_o),
        .current_inst_addr_i(mem_current_inst_address_o),
        .is_in_delayslot_i(mem_is_in_delayslot_o),
        
        
        //output
        .data_o(ex_cp0_reg_data_i),
        .timer_int_o(timer_int_o),
        .count_o(cp0_count),
        .compare_o(cp0_compare),
        .status_o(cp0_status),
        .cause_o(cp0_cause),
        .epc_o(cp0_epc),
        .config_o(cp0_config),
        .prid_o(cp0_prid)
    );


endmodule

