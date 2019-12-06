//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/18 20:21:03
// Design Name: 
// Module Name: panghu_min_sopc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "Defines.vh"

module stpu_sopc(
    input clk,
    input rst
    );
    wire[`InstAddrBus]  pc_rom;
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;
    wire[5:0]           int;
    wire                timer_int;
    
    
    assign int = {5'b00000, timer_int};
    assign pc_rom = {2'b00,{inst_addr[31:2]}};
    
    stpu stpu0(
        .clk(clk),              .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce(rom_ce),        .int_i(int),
        .timer_int_o(timer_int) 
    );
   
   
    inst_rom rom (
    .clka(clk),
    .addra(pc_rom),         // input wire [4 : 0] a
    .ena(rom_ce),  // input wire enable
    .douta(inst)          // output wire [31 : 0] spo
);
    
endmodule

