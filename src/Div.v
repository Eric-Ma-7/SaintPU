`include "Defines.vh"

module div(

	input wire  rst,
	input wire  clk,
	
	input wire	signed_div_i,
	input wire[31:0]  opdata1_i,
	input wire[31:0]  opdata2_i,
	input wire  start_i,            
	input wire  annul_i,			
	
	output reg[63:0]	result_o,   
	output reg	ready_o			
);

	reg[5:0] cnt;
	reg[63:0] temp_a;
	reg[63:0] temp_b;
	reg [1:0] state;
	reg [31:0] tempa;
	reg [31:0] tempb;
	
	always @ (posedge clk) begin
	 if	(rst == `RstEnable) begin
		state <= `DivFree;
		ready_o <= `DivResultNotReady;
		result_o <= {`ZeroWord, `ZeroWord};
	 end else begin
		case(state)
		`DivFree:	begin
			if(start_i == `DivStart && annul_i == 1'b0) begin	
				if(opdata2_i == `ZeroWord) begin                  
					state <= `DivByZero;
				end else begin											 
					state <= `DivOn;
					cnt <= 6'b000000;
					if(signed_div_i == 1'b1) begin
						if(opdata1_i[31] == 1'b1) begin
							tempa = ~opdata1_i+1;
						end else begin
							tempa = opdata1_i;
						end
						if(opdata2_i[31] == 1'b1) begin
							tempb = ~opdata2_i+1;
						end else begin
							tempb = opdata2_i;
						end
					end
					if(signed_div_i == 1'b0) begin	
						tempa = opdata1_i;
						tempb = opdata2_i;
					end
					temp_a <= {`ZeroWord, tempa[31:0]};
					temp_b <= {tempb[31:0], `ZeroWord};
				end
			end else begin
				ready_o <= `DivResultNotReady;
				result_o <= {`ZeroWord, `ZeroWord};
			end
		end
		
		`DivByZero:		begin
			result_o <= {`ZeroWord, `ZeroWord};
			state <= `DivEnd;
		end
		
		`DivOn:		begin
			if(annul_i == 1'b0) begin
				if(cnt != 6'b100000) begin
					temp_a <= {temp_a[62:0], 1'b0};
					if(temp_a[62:31] >= temp_b[63:32]) begin
						temp_a <= {temp_a[62:0], 1'b0}-temp_b+1'b1;
					end
					cnt <= cnt+1;
				end else begin
					if(signed_div_i == 1'b1) begin
						if(opdata1_i[31] == 1'b1 && opdata2_i[31] == 1'b1 ) begin
							temp_a <= {1'b0, temp_a[62:0]};
						end
						if(opdata1_i[31] != 1'b1 && opdata2_i[31] == 1'b1 ) begin
							temp_a <= {temp_a[63:32], ~temp_a[31:0]+1 };
						end
						if(opdata1_i[31] == 1'b1 && opdata2_i[31] != 1'b1 ) begin
							temp_a <= {~temp_a[63:32]+1, ~temp_a[31:0]+1};
						end
						if(opdata1_i[31] != 1'b1 && opdata2_i[31] != 1'b1 ) begin
							temp_a <= {1'b0, temp_a[62:0]};
						end
					end
					
				state <= `DivEnd;
				cnt <= 6'b000000;
				end
            end else begin
				state <= `DivFree;
			end
		end

		
		`DivEnd:    begin
			result_o <= temp_a;
			ready_o  <= `DivResultReady;
			if(start_i == `DivStop) begin;
				state <= `DivFree;
				ready_o <= `DivResultNotReady;
				result_o <= {`ZeroWord, `ZeroWord};
			end
		end
  endcase
	end
	end
	
endmodule
