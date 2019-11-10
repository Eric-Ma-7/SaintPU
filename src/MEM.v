`include "Defines.vh"

module mem (
	//system signals
	input	wire[`RegBus]		wdata_i,
	input   wire[`RegAddrBus]	wd_i,
	input   wire 				wreg_i,
    input   wire[`RegBus]       hi_i,
    input   wire[`RegBus]       lo_i,
    input   wire                whilo_i,

    input   wire                cp0_reg_we_i,
    input   wire[`RegAddrBus]   cp0_reg_write_addr_i,
    input   wire[`RegBus]       cp0_reg_data_i,

    output   reg                cp0_reg_we_o,
    output   reg[`RegAddrBus]   cp0_reg_write_addr_o,
    output   reg[`RegBus]       cp0_reg_data_o,
    
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg                 whilo_o,
	output  reg[`RegBus]		wdata_o,
	output  reg[`RegAddrBus]	wd_o,
	output  reg  				wreg_o

);
	always @ ( wdata_i or wd_i or wreg_i or hi_i or lo_i 
	or whilo_i or cp0_reg_we_i or cp0_reg_write_addr_i or cp0_reg_data_i) begin
         begin
			wdata_o = wdata_i;
			wd_o = wd_i;
			wreg_o = wreg_i;
			hi_o = hi_i;
			lo_o = lo_i;
			whilo_o = whilo_i;
			cp0_reg_we_o = cp0_reg_we_i;
			cp0_reg_write_addr_o = cp0_reg_write_addr_i;
			cp0_reg_data_o = cp0_reg_data_i;
		end
	end
endmodule

