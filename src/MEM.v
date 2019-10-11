`include "Defines.vh"

module mem (
	//system signals
	input	wire				rst, 
	input	wire[`RegBus]		wdata_i,
	input   wire[`RegAddrBus]	wd_i,
	input   wire 				wreg_i,
    input   wire[5:0]           stall,
    input   wire[`RegBus]       hi_i,
    input   wire[`RegBus]       lo_i,
    input   wire                whilo_i,
    
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg                 whilo_o,
	output  reg[`RegBus]		wdata_o,
	output  reg[`RegAddrBus]	wd_o,
	output  reg  				wreg_o

);
	always @ (*) begin
		if (rst) begin
			wdata_o <= `ZeroWord;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
			whilo_o <= `WriteDisable;
		end else begin
			wdata_o <= wdata_i;
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;
		end
	end
endmodule
