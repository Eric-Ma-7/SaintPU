`include "Defines.v"

module mem_wb (
	//system signals
	input	wire				rst, 
	input	wire				clk,
	input   wire[`RegBus]		mem_wdata,
	input   wire[`RegAddrBus]	mem_wd,
	input   wire				mem_wreg,

	output  reg[`RegBus]		wb_wdata,
	output  reg[`RegAddrBus]	wb_wd,
	output	reg 				wb_wreg
	//
);
    always @(posedge clk) begin
    	if (rst) begin
    		// reset
    		wb_wdata <= `ZeroWord;
    		wb_wd <=  `NOPRegAddr;
    		wb_wreg <= `WriteDisable;
    	end
    	else begin
    		wb_wdata <= mem_wdata;
    		wb_wd <= mem_wd;
    		wb_wreg <= mem_wreg;
    	end
    end
endmodule
