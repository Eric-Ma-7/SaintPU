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
    wire[5:0]           stall_pc;
    wire[5:0]           stall_ifid;
    wire[5:0]           stall_idex;
    wire[5:0]           stall_exmem;
    wire[5:0]           stall_memwb;
    
    
    
    
    //Variables connecting IF/ID and ID
    wire[`InstAddrBus]  pc;
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;
    wire[`InstBus]      if_inst_ex;

    //Variables Connecting ID and ID/EX
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_o;
    wire[`RegBus]       id_reg2_o;
    wire                id_wreg_o;
    wire[`RegAddrBus]   id_wd_o;    
    wire                stallreq_id;
    
    //Variables Connecting ID/EX and EX
    wire[`RegBus]       ex_inst_i;
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire                ex_wreg_i;
    wire[`RegAddrBus]   ex_wd_i;
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
    
    wire[`RegBus]       ex_cp0_reg_data_i;
    
    wire                mem_cp0_reg_we_o;
    wire[`RegAddrBus]   mem_cp0_reg_write_addr_o;
    wire[`RegBus]       mem_cp0_reg_data_o;
    
    //Variables Connecting EX/MEM and MEM
    wire                mem_wreg_i;
    wire[`RegAddrBus]   mem_wd_i;
    wire[`RegBus]       mem_wdata_i;
    wire[`RegBus]       mem_hi_i;
    wire[`RegBus]       mem_lo_i;
    wire                mem_whilo_i;
    
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
    
    
    
    //pc reg 
    pc pc_reg0(
        .clk(clk),  
        .rst(rst),  
        .pc(pc),    
        .ce(rom_ce),
        .stall(stall_pc)
    );
    
    assign rom_addr_o   =   pc;
    
    //IF/ID
    if_id if_id0(
        .clk(clk),  
        .rst(rst),  
        .if_pc(pc),
        .if_inst(rom_data_i),   
        .id_pc(id_pc_i),
        .id_inst(id_inst_i),
        .if_inst_ex(if_inst_ex),
        .stall(stall_ifid)
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
        
        //ID/EX
        .aluop_o(id_aluop_o),       
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),         
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),             
        .wreg_o(id_wreg_o),
        
        
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
        .id_inst(if_inst_ex),
        
        //output
        //To EX
        .ex_aluop(ex_aluop_i),  
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),    
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),        
        .ex_wreg(ex_wreg_i),
        .ex_inst(ex_inst_i),
        .stall(stall_idex)
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
        .cp0_reg_data_o(ex_cp0_reg_data_o)

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
        .stall(stall_exmem),
        
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
        .mem_cp0_reg_data(mem_cp0_reg_data_i)
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
        
        //To MEM/WB
        .wdata_o(mem_wdata_o),  
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o),
        .whilo_o(mem_whilo_o),

        .cp0_reg_we_o(mem_cp0_reg_we_o),
        .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
        .cp0_reg_data_o(mem_cp0_reg_data_o)

        
    );
    

    
    
    mem_wb mem_wb0(
        .rst(rst),              
        .clk(clk),
        .stall(stall_memwb),
        
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
        
        //output
        .stall_pc(stall_pc),
        .stall_ifid(stall_ifid),
        .stall_idex(stall_idex),
        .stall_exmem(stall_exmem),
        .stall_memwb(stall_memwb)
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

        //output
        .data_o(ex_cp0_reg_data_i),
        .timer_int_o(timer_int_o)
    );


endmodule


