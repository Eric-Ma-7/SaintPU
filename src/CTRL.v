/* This is the CTRL model of STPU */

`include "Defines.vh"

module ctrl(
    input wire rst,
    input wire stallreq_from_id,
    input wire stallreq_from_ex,
    input wire[`RegBus]	cp0_epc_i,
    input wire[`RegBus] excepttype_i,

    output reg[`RegBus] new_pc,
    output reg flush,
    output reg [5:0] stall_o

);

always @(rst or stallreq_from_id or stallreq_from_ex or excepttype_i or cp0_epc_i) begin
    if (rst == `RstEnable) begin
        stall_o = 6'b000000;
        flush = 1'b0;
        new_pc = `ZeroWord;
    end else if(excepttype_i != `ZeroWord) begin
    	flush = 1'b1;
    	stall_o = 6'b000000;
    	case (excepttype_i)
    		32'h00000001: begin 	//interruption
    			new_pc = 32'h00000020;
    		end
    		32'h00000008: begin 	//syscall
    			new_pc = 32'h00000040;
    		end
    		32'h0000000a: begin 	//invalid inst
    			new_pc = 32'h00000040;
    		end
    		32'h0000000d: begin 	//trap
    			new_pc = 32'h00000040;
    		end
    		32'h0000000c: begin 	//ov
    			new_pc = 32'h00000040;
    		end
    		32'h0000000e: begin 	//eret
    			new_pc = cp0_epc_i;
    		end
    		default: begin
    		end
    		endcase
    end else if (stallreq_from_ex == `Stop) begin
        stall_o = 6'b001111;
        flush = 1'b0;
    end else if (stallreq_from_id == `Stop) begin
        stall_o = 6'b000111;
        flush = 1'b0;
    end else begin
        stall_o = 6'b000000;
        flush = 1'b0;
        new_pc = `ZeroWord;
    end
end

endmodule
