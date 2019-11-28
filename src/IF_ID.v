`include "Defines.vh"

module if_id (
	//system signals
	input	wire 				clk, 
	input	wire 				rst,
	input 	wire[`InstBus]		if_inst,
	input   wire[`InstAddrBus]	if_pc,
	input	wire[5:0]			stall,
    input   wire                flush,
    
	output	reg[`InstBus]		id_inst,
	output  reg[`InstAddrBus]	id_pc,
    output  reg[`InstBus]       if_inst_ex
	
	//
	
);
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
      		id_pc <= `ZeroWord;
      		id_inst <= `ZeroWord;
      		if_inst_ex <= `ZeroWord;
      	end else if (flush == `WriteEnable) begin
      	    id_pc <= `ZeroWord;
      	    id_inst <= `ZeroWord;
      	end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
      		id_inst <= `ZeroWord;
      		id_pc <= `ZeroWord;
      		if_inst_ex <= `ZeroWord;
      	end else if(stall[1] == `NoStop) begin
			id_inst <= if_inst;
      		id_pc <= if_pc;
      		if_inst_ex <= if_inst;
		end else begin
		end
    end
endmodule



