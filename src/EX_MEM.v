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
    	end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
    	    mem_wdata <= `ZeroWord;
    		mem_wd <= `NOPRegAddr;
    		mem_wreg <= `WriteDisable;
    		mem_whilo <= `WriteDisable;
    		mem_hi <= `ZeroWord;
    		mem_lo <= `ZeroWord;
    		hilo_o <= hilo_i;
    		cnt_o <= cnt_i;
        end else if(stall[3] == `NoStop) begin
    		mem_wdata <= ex_wdata;
    		mem_wd <= ex_wd;
    		mem_wreg <= ex_wreg;
    		mem_whilo <= ex_whilo;
    		mem_hi <= ex_hi;
    		mem_lo <= ex_lo;
    		hilo_o <= {`ZeroWord,`ZeroWord};
    	    cnt_o <= 2'b00;
    	end else begin
    	    hilo_o <= hilo_i;
    	    cnt_o <= cnt_i;
    	end
    	//other: remain ex_mem regs' value
    end
endmodule
