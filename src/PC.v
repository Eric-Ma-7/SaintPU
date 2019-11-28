`include "Defines.vh"

module  pc(
	input	wire        		clk, 
	input	wire        		rst,
	input	wire[5:0]			stall,
	input	wire				branch_flag_i,
	input	wire[`InstAddrBus]	branch_target_address_i,
	
	input   wire               flush,
	input   wire[`RegBus]      new_pc,
	
	output  reg[`InstAddrBus]	pc,
	output  reg					ce   
);
    reg[`InstAddrBus]   pc_temp;
	always @(posedge clk) begin
		if (rst) begin
			ce <= `ChipDisable;
		end
		else begin
			ce <= `ChipEnable;
		end
	end
	always @(posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= `ZeroWord;
		end
		else if (stall[0] == `NoStop) begin
			if (flush == `Enable) begin
				pc <= new_pc ;
			end else if (branch_flag_i == `Branch) begin
			    pc <= branch_target_address_i;
			end else begin	
			pc <= pc + 4'h4;
		end
	end
	end


endmodule
