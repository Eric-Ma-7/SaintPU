/* This is the CTRL model of STPU */

`include "Defines.vh"

module ctrl(
    input wire rst,
    input wire stallreq_from_id,
    input wire stallreq_from_ex,
    
    output reg [5:0] stall_pc,
    output reg [5:0] stall_ifid,
    output reg [5:0] stall_idex,
    output reg [5:0] stall_exmem,
    output reg [5:0] stall_memwb
);

always @(rst or stallreq_from_id or stallreq_from_ex) begin
    if (rst == `RstEnable) begin
        stall_pc = 6'b000000;
        stall_ifid = 6'b000000;
        stall_idex = 6'b000000;
        stall_exmem = 6'b000000;
        stall_memwb = 6'b000000;
    end else if (stallreq_from_ex == `Stop) begin
        stall_pc = 6'b001111;
        stall_ifid = 6'b001111;
        stall_idex = 6'b001111;
        stall_exmem = 6'b001111;
        stall_memwb = 6'b001111;
    end else if (stallreq_from_id == `Stop) begin
        stall_pc = 6'b000111;
        stall_ifid = 6'b000111;
        stall_idex = 6'b000111;
        stall_exmem = 6'b000111;
        stall_memwb = 6'b000111;
    end else begin
        stall_pc = 6'b000000;
        stall_ifid = 6'b000000;
        stall_idex = 6'b000000;
        stall_exmem = 6'b000000;
        stall_memwb = 6'b000000;
    end
end

endmodule

