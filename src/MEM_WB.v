`include "Defines.vh"

module mem_wb (
	//system signals
	input	wire				rst, 
	input	wire				clk,
	input   wire[`RegBus]		mem_wdata,
	input   wire[`RegAddrBus]	mem_wd,
	input   wire				mem_wreg,
    input   wire[`RegBus]       mem_hi,
    input   wire[`RegBus]       mem_lo,
    input   wire                mem_whilo,
    input   wire[5:0]           stall,
    
    input   wire                flush,
    
    input   wire                mem_cp0_reg_we,
    input   wire[`RegAddrBus]   mem_cp0_reg_write_addr,
    input   wire[`RegBus]       mem_cp0_reg_data,
    
    output   reg                wb_cp0_reg_we,
    output   reg[`RegAddrBus]   wb_cp0_reg_write_addr,
    output   reg[`RegBus]       wb_cp0_reg_data,
    
    output  reg[`RegBus]        wb_hi,
    output  reg[`RegBus]        wb_lo,
    output  reg                 wb_whilo,
	output  reg[`RegBus]		wb_wdata,
	output  reg[`RegAddrBus]	wb_wd,
	output	reg 				wb_wreg
	//
);
    always @(posedge clk ) begin
    	if (rst == `RstEnable) begin
    		// reset
    		wb_wdata <= `ZeroWord;
    		wb_wd <=  `NOPRegAddr;
    		wb_wreg <= `WriteDisable;
    		wb_hi <= `ZeroWord;
    		wb_lo <= `ZeroWord;
    		wb_whilo <= `WriteDisable;
    		wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
    	end else if (stall[4] == `Stop && stall[5] ==`NoStop) begin
    		wb_wdata <= `ZeroWord;
    		wb_wd <=  `NOPRegAddr;
    		wb_wreg <= `WriteDisable;
    		wb_hi <= `ZeroWord;
    		wb_lo <= `ZeroWord;
    		wb_whilo <= `WriteDisable;
    		wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end else if (flush == `WriteEnable) begin
        	wb_wdata <= `ZeroWord;
    		wb_wd <=  `NOPRegAddr;
    		wb_wreg <= `WriteDisable;
    		wb_hi <= `ZeroWord;
    		wb_lo <= `ZeroWord;
    		wb_whilo <= `WriteDisable;
    		wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end else if (stall[4] == `NoStop) begin
         	wb_wdata <= mem_wdata;
    		wb_wd <= mem_wd;
    		wb_wreg <= mem_wreg;
    		wb_hi <= mem_hi;
    		wb_lo <= mem_lo;
    		wb_whilo <= mem_whilo;
    		wb_cp0_reg_we <= mem_cp0_reg_we;
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
            wb_cp0_reg_data <= mem_cp0_reg_data;
    	end
    end
endmodule