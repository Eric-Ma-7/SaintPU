module mem (
	//system signals
	input	wire				rst, 
	input	wire[`RegBus]		wdata_i,
	input   wire[`RegAddrBus]	wd_i,
	input   wire 				wreg_i,

	output  reg[`RegBus]		wdata_o,
	output  reg[`RegAddrBus]	wd_o,
	output  reg  				wreg_o
	//
	always @(*) begin
		if (rst) begin
			wdata_o <= `ZeroWord;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		end
		else begin
			wdata_o <= wdata_i;
			wd_o <= wd_i;
			wreg_o <= wreg_i;
		end
	end
);
    
endmodule