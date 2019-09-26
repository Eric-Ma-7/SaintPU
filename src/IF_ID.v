module if_id (
	//system signals
	input	wire 				clk, 
	input	wire 				rst,
	input 	wire[`InstBus]		if_inst,
	input   wire[`InstAddrBus]	if_pc,

	output	reg[`InstBus]		id_inst,
	output  reg[`InstAddrBus]	id_pc				
	//
);
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
      		id_pc <= 32'h00000000;
      		id_inst <= 32'h00000000;
      	end else begin
      		id_inst <= if_inst;
      		id_pc <= if_pc;
      	end
    end


endmodule