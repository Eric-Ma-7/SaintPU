`include "Defines.vh"

module cp0 (
	//system signals
	input	wire	rst, 
	input	wire	clk,
	input	wire[`RegAddrBus]		raddr_i,	
	input	wire[5:0]				int_i,
	input	wire	we_i,
	input	wire[`RegAddrBus]		waddr_i,
	input   wire[`RegBus]			wdata_i,
	input 	wire[`RegBus]			excepttype_i,
	input 	wire[`RegBus]			current_inst_addr_i,
	input 	wire 					is_in_delayslot_i,

	//
	output	reg[`RegBus]			data_o,
    output  reg     		        timer_int_o,
    output  reg[`RegBus]			count_o,
	output  reg[`RegBus]			compare_o,
	output  reg[`RegBus]			status_o,
	output  reg[`RegBus]			cause_o,
	output  reg[`RegBus]			epc_o,
	output  reg[`RegBus]			config_o,
	output  reg[`RegBus]			prid_o
);


	

	
always @ (posedge clk ) begin
	if(rst == `RstEnable) begin
		count_o <= `ZeroWord;
		compare_o <= `ZeroWord;
		status_o <= `ZeroWord;
		cause_o <= `ZeroWord;
		epc_o <= `ZeroWord;
		config_o <= 32'b00000000000000001000000000000000;	//MSB working mode
		//prid_o <= 32'b00000000010011000000000100000010;		//version
		prid_o <= 32'b01010011010101000101000001010101;
		timer_int_o <= `InterruptNotAssert;
	end	else begin
		count_o <= count_o + 1;
		cause_o[15:10] <= int_i;	
        
		if (compare_o != `ZeroWord && count_o == compare_o) begin
			timer_int_o <= `InterruptAssert;
		end else begin
		    timer_int_o <= `InterruptNotAssert;
		end
		
		if (we_i == `WriteEnable) begin
			case (waddr_i) 
			    `CP0_REG_COUNT:	begin
			    	count_o <= wdata_i;
			    end
			    `CP0_REG_COMPARE: begin
			    	compare_o <= wdata_i;
			    	timer_int_o <= `InterruptNotAssert;
			    end
			    `CP0_REG_STATUS: begin
			    	status_o <= wdata_i;
			    end
			    `CP0_REG_EPC: begin
			    	epc_o <= wdata_i;
			    end
			    `CP0_REG_CAUSE: begin
			    	cause_o[9:8] <= wdata_i[9:8];
			    	cause_o[23] <= wdata_i[23];
			    	cause_o[22] <= wdata_i[22];
			    end
			    default: begin
    			end
			endcase					
		end
		case (excepttype_i)
			32'h00000001:	begin 		//External Intterupt
				if(is_in_delayslot_i == `InDelaySlot) begin
					epc_o <= current_inst_addr_i - 4;
					cause_o[31]	<= 1'b1;
				end else begin
					epc_o <= current_inst_addr_i;
					cause_o[31] <= 1'b0;
				end
					status_o[1] <= 1'b1;	//EXL
					cause_o[6:2] <= 5'b00000;	//ExcCode
			end
			32'h00000008:	begin 		//syscall
				if(status_o[1] == 1'b0)begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						epc_o <= current_inst_addr_i -4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01000;
			end
			32'h0000000a: begin
				if(status_o[1] == 1'b0)begin 		//Invalid Instruction
					if(is_in_delayslot_i == `InDelaySlot) begin
						epc_o <= current_inst_addr_i -4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01010;
			end
			32'h0000000d: begin
				if(status_o[1] == 1'b0)begin 		//Trap
					if(is_in_delayslot_i == `InDelaySlot) begin
						epc_o <= current_inst_addr_i -4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01101;
			end
			32'h0000000c: begin
				if(status_o[1] == 1'b0)begin 		//Ov
					if(is_in_delayslot_i == `InDelaySlot) begin
						epc_o <= current_inst_addr_i -4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01100;
			end
			32'h0000000e: begin          //eret
				status_o[1] <= 1'b0;
			end
			default:begin
			end
			endcase
	end	    
end

always @ ( * ) begin
    case (raddr_i)
    	`CP0_REG_COUNT: begin
    		data_o = count_o;
    	end
    	`CP0_REG_STATUS: begin
    		data_o = status_o;
    	end
    	`CP0_REG_COMPARE: begin
    		data_o = compare_o;
    	end
    	`CP0_REG_CAUSE: begin
    		data_o = cause_o;
    	end
    	`CP0_REG_EPC: begin
    		data_o = epc_o;
    	end
    	`CP0_REG_CONFIG: begin
    		data_o = config_o;
    	end
    	default: begin
    	   data_o = `ZeroWord;
    	end
    endcase
end

endmodule