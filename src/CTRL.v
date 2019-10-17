/* This is the CTRL model of STPU */

`include "Defines.vh"

module ctrl(
    input wire rst,
    input wire stallreq_from_id,
    input wire stallreq_from_ex,
    output reg [5:0] stall
);

always @(rst or stallreq_from_id or stallreq_from_ex) begin
    if (rst == `RstEnable) begin
        stall <= 6'b000000;
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
    end else begin
        stall <= 6'b000000;
    end
end

endmodule