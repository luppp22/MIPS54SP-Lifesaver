`timescale 1ns / 1ps

`include "definition.vh"

module WidthConv1(
    input wire [1:0] widthType,
    input wire [1:0] dataPos,
    input wire [31:0] iRfData,
    input wire [31:0] iMemData,
    output reg [31:0] oMemData
    );

    always @ * begin
        case (widthType)
        `WCONV_WORD: begin
            oMemData = iRfData;
        end
        `WCONV_HALF: begin
            case (dataPos)
                2'b00: oMemData = {iMemData[31:16], iRfData[15:0]};
                2'b10: oMemData = {iRfData[15:0], iMemData[15:0]};
                default: oMemData = iRfData;
            endcase
        end
        `WCONV_BYTE: begin
            case (dataPos)
                2'b00: oMemData = {iMemData[31:8], iRfData[7:0]};
                2'b01: oMemData = {iMemData[31:16], iRfData[7:0], iMemData[7:0]};
                2'b10: oMemData = {iMemData[31:24], iRfData[7:0], iMemData[15:0]};
                2'b11: oMemData = {iRfData[7:0], iMemData[23:0]};
            endcase
        end
        default: begin
            oMemData = iRfData;
        end
        endcase
    end

endmodule
