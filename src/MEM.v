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

	input	wire[`RegBus]		excepttype_i,
	input	wire[`RegBus]		current_inst_address_i,
	input	wire				is_in_delayslot_i,	
	
	input	wire[`RegBus]		cp0_status_i,
	input	wire[`RegBus]		cp0_cause_i,
	input	wire[`RegBus]		cp0_epc_i,

	input	wire				wb_cp0_reg_we,
	input	wire[`RegAddrBus]	wb_cp0_reg_write_address,
	input	wire[`RegBus]		wb_cp0_reg_data,

	output	reg[`RegBus]		excepttype_o,
	output	wire[`RegBus]		current_inst_address_o,
	output	wire				is_in_delayslot_o,
	output	wire[`RegBus]		cp0_epc_o,

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
	
	reg[`RegBus]	cp0_status;
	reg[`RegBus]	cp0_cause;
	reg[`RegBus]	cp0_epc;
	reg 			mem_we;

	assign  is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;

	always @(*) begin
		if ((wb_cp0_reg_we == `Enable) && (wb_cp0_reg_write_address == `CP0_REG_STATUS)) begin
			cp0_status = wb_cp0_reg_data;
		end
		else begin
			cp0_status = cp0_status_i;
		end
	end

	always @(*) begin
		if ((wb_cp0_reg_we == `Enable) && (wb_cp0_reg_write_address == `CP0_REG_EPC)) begin
			cp0_epc = wb_cp0_reg_data;
		end
		else begin
			cp0_epc = cp0_epc_i;
		end
	end

	assign cp0_epc_o = cp0_epc;

	always @(*) begin
		if ((wb_cp0_reg_we == `Enable) && (wb_cp0_reg_write_address == `CP0_REG_CAUSE)) begin
			cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
			cp0_cause[22] <= wb_cp0_reg_data[22];
			cp0_cause[23] <= wb_cp0_reg_data[23];
		end
		else begin
			cp0_cause <= cp0_cause_i;
		end
	end

	always @(*) begin
			if(current_inst_address_i != `ZeroWord) begin
				if(((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
				(cp0_status[1] == 1'b0) && 
				(cp0_status[0] == 1'b1)) begin
					excepttype_o = 32'h00000001;	//interrupt
				end else if(excepttype_i[8] == 1'b1) begin
					excepttype_o = 32'h00000008;	//syscall
				end else if(excepttype_i[9] == 1'b1) begin
					excepttype_o = 32'h0000000a;	//inst_valid
				end else if(excepttype_i[10] == 1'b1) begin
					excepttype_o = 32'h0000000d;	//trap
				end else if(excepttype_i[11] == 1'b1) begin
					excepttype_o = 32'h0000000c;	//ov
				end else if(excepttype_i[12] == 1'b1) begin
					excepttype_o = 32'h0000000e;	//eret
				end	else begin
					excepttype_o = `ZeroWord;
				end
			end else begin
				excepttype_o = `ZeroWord;
			end
	end

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