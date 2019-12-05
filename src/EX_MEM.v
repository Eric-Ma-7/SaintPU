`include "Defines.vh"

module ex_mem (
	//system signals
	input	wire				rst, 
	input	wire				clk,
	input   wire[`RegBus]		ex_wdata,
	input   wire[`RegAddrBus]	ex_wd,
	input   wire				ex_wreg,
    input   wire                ex_whilo,
    input   wire[`RegBus]       ex_hi,
    input   wire[`RegBus]       ex_lo,    
    input   wire[5:0]           stall,
    input   wire[`DoubleRegBus] hilo_i,
    input   wire[1:0]           cnt_i,
	input	wire				flush,
	input	wire[`RegBus]		ex_excepttype,
	input	wire[`RegBus]		ex_current_inst_addr,
	input	wire				ex_is_in_delayslot,
    
    input   wire                ex_cp0_reg_we,
    input   wire[`RegAddrBus]   ex_cp0_reg_write_addr,
    input   wire[`RegBus]       ex_cp0_reg_data,

    output   reg                mem_cp0_reg_we,
    output   reg[`RegAddrBus]   mem_cp0_reg_write_addr,
    output   reg[`RegBus]       mem_cp0_reg_data,

	output	reg[`RegBus]		mem_excepttype,
	output	reg[`RegBus]		mem_current_inst_addr,
	output	reg					mem_is_in_delayslot,

    output  reg[`DoubleRegBus]  hilo_o,
    output  reg[1:0]            cnt_o,
    output  reg                 mem_whilo,
    output  reg[`RegBus]        mem_hi,
    output  reg[`RegBus]        mem_lo,
	output  reg[`RegBus]		mem_wdata,
	output  reg[`RegAddrBus]	mem_wd,
	output	reg 				mem_wreg
	//
);
    always @(posedge clk) begin
    	if (rst == `RstEnable) begin
    		// reset
    		mem_wdata <= `ZeroWord;
    		mem_wd <= `NOPRegAddr;
    		mem_wreg <= `WriteDisable;
    		mem_whilo <= `WriteDisable;
    		mem_hi <= `ZeroWord;
    		mem_lo <= `ZeroWord;
    		hilo_o <= {`ZeroWord,`ZeroWord};
    		cnt_o <= 2'b00;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;
			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_addr <= `ZeroWord;
    	end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
    	    mem_wdata <= `ZeroWord;
    		mem_wd <= `NOPRegAddr;
    		mem_wreg <= `WriteDisable;
    		mem_whilo <= `WriteDisable;
    		mem_hi <= `ZeroWord;
    		mem_lo <= `ZeroWord;
    		hilo_o <= hilo_i;
    		cnt_o <= cnt_i;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;
			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_addr <= `ZeroWord;
        end else if(flush == `WriteEnable) begin
			mem_wdata <= `ZeroWord;
    		mem_wd <= `NOPRegAddr;
    		mem_wreg <= `WriteDisable;
    		mem_whilo <= `WriteDisable;
    		mem_hi <= `ZeroWord;
    		mem_lo <= `ZeroWord;
    		hilo_o <= {`ZeroWord,`ZeroWord};
    		cnt_o <= 2'b00;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;	
			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_addr <= `ZeroWord;
		end else if(stall[3] == `NoStop) begin
    		mem_wdata <= ex_wdata;
    		mem_wd <= ex_wd;
    		mem_wreg <= ex_wreg;
    		mem_whilo <= ex_whilo;
    		mem_hi <= ex_hi;
    		mem_lo <= ex_lo;
    		hilo_o <= {`ZeroWord,`ZeroWord};
    	    cnt_o <= 2'b00;
            mem_cp0_reg_we <= ex_cp0_reg_we;
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
            mem_cp0_reg_data <= ex_cp0_reg_data;
			mem_excepttype <= ex_excepttype;
			mem_is_in_delayslot <= ex_is_in_delayslot;
			mem_current_inst_addr <= ex_current_inst_addr;
    	end else begin
    	    /*hilo_o <= hilo_i;
    	    cnt_o <= cnt_i;
    	    mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;*/
    	end
    	//other: remain ex_mem regs' value
    end
endmodule