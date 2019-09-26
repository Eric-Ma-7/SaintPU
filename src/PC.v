module  pc(
	input	wire        		clk, 
	input	wire        		rst,
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
			pc <= 32`h00000000;
		end
		else if (ce == `ChipEnable) begin
			pc <= pc + 4`h4;
		end
	end

endmodule