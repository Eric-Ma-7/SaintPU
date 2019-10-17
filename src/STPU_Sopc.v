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
`include "Defines.v"

module stpu_sopc(
    input clk,
    input rst
    );
    
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;
    
    stpu stpu0(
        .clk(clk),              .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce(rom_ce)
    );
   
    dist_mem_gen_0 rom (
    .a(inst_addr),              // input wire [4 : 0] a
    .qspo_ce(rom_ce),  // input wire qspo_ce
    .spo(inst)          // output wire [31 : 0] spo
);
    
endmodule
