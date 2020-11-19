`timescale 1ns / 1ps

`include "definition.vh"

module WidthConv2(
    input wire sign,
    input wire [1:0] widthType,
    input wire [1:0] dataPos,
    input wire [31:0] iMemData,
    output reg [31:0] oRfData
    );

    always @ * begin
        case (widthType)
            `WCONV_WORD: begin
                oRfData = iMemData;
            end
            `WCONV_HALF: begin
                case (dataPos)
                    2'b00: oRfData = {(sign ? {(16){iMemData[15]}} : 16'b0), iMemData[15:0]};
                    2'b10: oRfData = {(sign ? {(16){iMemData[31]}} : 16'b0), iMemData[31:16]};
                    default: oRfData = iMemData;
                endcase
            end
            `WCONV_BYTE: begin
                case (dataPos)
                    2'b00: oRfData = {(sign ? {(24){iMemData[7]}} : 24'b0), iMemData[7:0]};
                    2'b01: oRfData = {(sign ? {(24){iMemData[15]}} : 24'b0), iMemData[15:8]};
                    2'b10: oRfData = {(sign ? {(24){iMemData[23]}} : 24'b0), iMemData[23:16]};
                    2'b11: oRfData = {(sign ? {(24){iMemData[31]}} : 24'b0), iMemData[31:24]};
                endcase
            end
            default: begin
                oRfData = iMemData;
            end
        endcase
    end

endmodule
