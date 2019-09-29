`include "defines.v"
`timescale 1ns / 1ps

module EX(
    input wire rst,
    input wire[`AluSelBus] alusel_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    output reg[`RegBus] wdata_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o
    );

    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    // reg[`RegBus] arithout;

    // logic 
    always @(*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_AND_OP:
                    begin
                        logicout <= reg1_i & reg2_i;
                    end
                `EXE_ANDI_OP:
                    begin
                        logicout <= reg1_i & reg2_i;
                    end
                `EXE_OR_OP:
                    begin
                        logicout <= reg1_i | reg2_i;
                    end
                `EXE_ORI_OP:
                    begin
                        logicout <= reg1_i | reg2_i;
                    end
                `EXE_XOR_OP:
                    begin
                        logicout <= reg1_i ^ reg2_i;
                    end
                `EXE_XORI_OP:
                    begin
                        logicout <= reg1_i ^ reg2_i;
                    end
                `EXE_NOR_OP:
                    begin
                        logicout <= ~(reg1_i | reg2_i);
                    end
                default: 
                    begin
                        logicout <= `ZeroWord;
                    end
            endcase
        end
    end

    // shift
    always @(*) begin
        if (rst == `RstEnable) begin
            shiftout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP:
                    begin
                        shiftout <= reg2_i << reg1_i[4:0];
                    end
                `EXE_SRL_OP:
                    begin
                        shiftout <= reg2_i >> reg1_i[4:0];
                    end
                `EXE_SRA_OP:
                    begin
                        shiftout <= reg2_i >>> reg1_i[4:0];
                    end
                default: 
                    begin
                        shiftout <= `ZeroWord;
                    end
            endcase
        end
    end

    // arithmetics
    /*
    always @(*) begin
        if (rst == `RstEnable) begin
            arithcout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_ADD_OP:
                    begin
                        arithout <= reg2_i + reg1_i;
                    end

                default: 
                    begin
                        arithout <= `ZeroWord;
                    end
            endcase
        end
    end*/

    // finally
    always @(*) begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (alusel_i)
            `EXE_RES_LOGIC:
                begin
                    wdata_o <= logicout;
                end 
            `EXE_RES_SHIFT:
                begin
                    wdata_o <= shiftout;
                end
            default: 
                begin
                    wdata_o <= `ZeroWord;
                end
        endcase
    end
    
endmodule
