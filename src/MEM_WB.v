module mem_wb (
	//system signals
	input	wire				rst, 
	input	wire				clk,
	input   wire[`RegBus]		mem_wdata,
	input   wire[`RegAddrBus]	mem_wd,
	input   wire				mem_reg,

	output  reg[`RegBus]		wb_wdata,
	output  reg[`RegAddrBus]	wb_wd,
	output	reg 				wb_reg
	//
);
    always @(posedge clk) begin
    	if (rst) begin
    		// reset
    		wb_wdata <= `ZeroWord;
    		wb_wd <= `NOPAddrBus;
    		wb_reg <= `WriteDisable;
    	end
    	else begin
    		wb_wdata <= mem_wdata;
    		wb_wd <= mem_wd;
    		wb_reg <= mem_reg;
    	end
    end
endmodule