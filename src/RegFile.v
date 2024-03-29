`include "Defines.vh"

module regfile(
    input wire rst,
    input wire clk,
    
    //writing port
    input wire [`RegAddrBus] waddr,
    input wire [`RegBus] wdata,
    input wire we,
    
    //reading port1
    input wire [`RegAddrBus] raddr1,
    input wire re1,
    output reg [`RegBus] rdata1,
    //reading port2
    input wire [`RegAddrBus] raddr2,
    input wire re2,
    output reg [`RegBus] rdata2
    );
/*******************************define 32 32bits regs**************************************************/

reg[`RegBus] regs[0:`RegNum-1];

/******************************* Writing Operation **************************************************/
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

/******************************* Reading Operation of Reading Port1 **************************************************/
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata1 = `ZeroWord;
        end else if(raddr1 == `RegNumLog2'h0) begin
        rdata1 = `ZeroWord;
        end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) 
            begin  rdata1 = wdata;
        end else if(re1 == `ReadEnable) begin
            rdata1 = regs[raddr1];
        end else begin
            rdata1 = `ZeroWord;
        end
    end
/******************************* Reading Operation of Reading Port2 **************************************************/
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata2 = `ZeroWord;
        end else if(raddr2 == `RegNumLog2'h0) begin
        rdata2 = `ZeroWord;
        end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) 
            begin  rdata2 = wdata;
        end else if(re2 == `ReadEnable) begin
            rdata2 = regs[raddr2];
        end else begin
            rdata2 = `ZeroWord;
        end
    end

endmodule
