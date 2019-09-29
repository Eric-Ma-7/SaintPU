`include "Defines.v"

module ex_mem (
	//system signals
	input	wire				rst, 
	input	wire				clk,
	input   wire[`RegBus]		ex_wdata,
	input   wire[`RegAddrBus]	ex_wd,
	input   wire				ex_wreg,

	output  reg[`RegBus]		mem_wdata,
	output  reg[`RegAddrBus]	mem_wd,
	output	reg 				mem_wreg
	//
);
    always @(posedge clk) begin
    	if (rst) begin
    		// reset
    		mem_wdata <= `ZeroWord;
    		mem_wd <=  `NOPRegAddr;
    		mem_wreg <= `WriteDisable;
    	end
    	else begin
    		mem_wdata <= ex_wdata;
    		mem_wd <= ex_wd;
    		mem_wreg <= ex_wreg;
    	end
    end
endmodule
