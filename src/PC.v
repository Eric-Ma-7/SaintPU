`include "Defines.vh"

module  pc(
	input	wire        		clk, 
	input	wire        		rst,
	input	wire[5:0]			stall,
	output  reg[`InstAddrBus]	pc,
	output  reg					ce   
);
    
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
			pc <= pc + 1'h1;
		end
	end



endmodule