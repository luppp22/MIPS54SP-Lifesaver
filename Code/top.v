`timescale 1ns / 1ps

`include "definition.vh"

module Top(
    input wire clk,
    input wire rst,
    output wire [7:0] oSeg,
    output wire [7:0] oSel
    );

    wire done;
    wire [31:0] dispDmemData;
    reg clkCnt;
    reg clk50mhz;

    Mips54sp mips54sp(
        .clk(clk50mhz),
        .rst(rst),
        .done(done),
        .dispDmemData(dispDmemData)
    );

    Seg7x16 seg7x16(
        .clk(clk),
        .reset(rst),
        .cs(done),
        .i_data(dispDmemData),
        .o_seg(oSeg),
        .o_sel(oSel)
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            clkCnt <= 0;
            clk50mhz <= 0;
        end
        else {clk50mhz, clkCnt} <= clkCnt + 2'b1;
    end

endmodule
