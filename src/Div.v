module div(

	input wire  rst,
	input wire  clk,
	
	input wire	signed_div_i,
	input wire[31:0]  opdata1_i,
	input wire[31:0]  opdata2_i,
	input wire  start_i,            //是否开始除法运算
	input wire  annul_i,			//是否取消除法预算，若是则为1
	
	output reg[63:0]	result_o,   //calculate result
	output reg	ready_o			//end?
);

	reg[5:0] cnt;
	reg[63:0] temp_a;
	reg[63:0] temp_b;
	reg [1:0] state;
	
	always @ (posedge clk) begin
	 if	{rst == 'RstEnable} begin
		state <= 'DivFree;
		ready_o <= 'DivResultNotReady;
		result_o <= {'ZeroWord, 'ZeroWord};
	 end else begin
		case(state)
		'DivFree:	begin
			if(start_i == 'DivFree && annul_i == 1'b0) begin	
				if(opdata2_i == 'ZeroWord) begin                  
					state <= 'DivByZero
				end else begin											 //这个if语句用来处理开始工作时的符号位处理，即先把符号运算取绝对值
					state <= 'DivOn;
					cnt <= 6'b000000;
					if(signed_div_i == 1'b1 ) begin
						temp_a <= {'ZeroWord, 1'b0, opdata1_i[30:0]};
						temp_b <= {1'b0, opdata2_i[30:0], 'ZeroWord};
					end
					if(signed_div_i == 1'b0)	begin
						temp_a <= {opdata1_i, 'ZeroWord};	
						temp_b <= {'ZeroWord, opdata2_i};
					end
					
					
				end
			end else begin
				ready_o <= 'DivResultNotReady;
				result_o <= {'ZeroWord, 'ZeroWord};
			end
		end
		
		'DivByZero:		begin
			dividend <= {'ZeroWord, 'ZeroWord};
			state <= 'DivEnd;
		end
		
		'Divon:		begin
			if(annul_i == 1'b0) begin
				if(cnt != 6'b100000) begin
					temp_a = {temp_a[62:0], 1'b0};
					if(temp_a[63:32] >= temp_b[63:32]) begin
						temp_a = temp_a-temp_b+1'b1;
					end
					cnt <= cnt+1;
				end else begin
					if(signed_div_i == 1'b1) begin
						if(opdata1_i[31] == 1'b1 && opdata2_i[31] == 1'b1 ) begin
							temp_a = {1'b0, temp_a[62:0]};
						end
						if(opdata1_i[31] == 1'b1 && opdata2_i[31] != 1'b1 && ) begin
							if (temp_a != 1'b0) begin
							temp_a = {1'b1 , (temp_a[62:32]+1'b1), 1'b1, (opdata2_i[30:0]-temp_a[30:0]) };
							end else begin
							temp_a = {1'b1 , (temp_a[62:32]), 'ZeroWord};
						end
						if(opdata1_i[31] != 1'b1 && opdata2_i[31] == 1'b1 && ) begin
							temp_a = {1'b1 , (temp_a[62:32], (temp_a[31:0])}
						end
						if(opdata1_i[31] != 1'b1 && opdata2_i[31] != 1'b1 ) begin
							temp_a = {1'b0, temp_a[62:0]};
						end
					end
					//加上符号位
				state <= 'DivEnd;
				cnt <= 6'b000000;
				end
			end else begin
				state <= 'DivFree;
			end
		end
		
		'DivEnd:	begin
			result_o <= temp_a;
			ready_o  <= 'DivResultReady;
			if(start_i == 'DivStop) begin;
				state <= 'DivFree'
				ready_o <= 'DivResultNotReady;
				result_o <= {'ZeroWord, 'ZeroWord};
			end
		end
	endcase
	end
	end
	
endmodule