`timescale 1ns / 1ps

`include "definition.vh"

module Mips54sp(
    input clk,
    input rst,
    output reg done,
    output wire [31:0] dispDmemData
    );

    wire [31:0] imemAddr;
    wire [31:0] dmemAddr;
    wire [31:0] cpuDmemAddr;
    wire [31:0] imemOutData;
    wire [31:0] convMemInData;
    wire [31:0] conv1CpuInData;
    wire [31:0] conv1OutData;
    wire [31:0] conv2OutData;
    wire dmemWena;
    wire [`WCONVW-1:0] conv1Wtype;
    wire [`WCONVW-1:0] conv2Wtype;
    wire conv2Sign;

    // 输出用
    reg [31:0] dispDmemAddr;

    CPU cpu(
        .clk(clk),
        .rst(rst),
        .halt(done),
        .iImemData(imemOutData),
        .iDmemData(conv2OutData),
        .oImemAddr(imemAddr),
        .oDmemAddr(cpuDmemAddr),
        .oDmemData(conv1CpuInData),
        .oDmemWena(dmemWena),
        .oConv1Wtype(conv1Wtype),
        .oConv2Wtype(conv2Wtype),
        .oConv2Sign(conv2Sign)
    );

    IP_IMEM imem(
        .a(imemAddr[12:2]),
        .spo(imemOutData)
    );

    IP_DMEM dmem(
        .a(dmemAddr[12:2]),
        .d(conv1OutData),
        .clk(clk),
        .we(dmemWena),
        .spo(convMemInData)
    );

    WidthConv1 widthConv1(
        .widthType(conv1Wtype),
        .dataPos(cpuDmemAddr[1:0]),
        .iRfData(conv1CpuInData),
        .iMemData(convMemInData),
        .oMemData(conv1OutData)
    );

    WidthConv2 widthConv2(
        .sign(conv2Sign),
        .widthType(conv2Wtype),
        .dataPos(cpuDmemAddr[1:0]),
        .iMemData(convMemInData),
        .oRfData(conv2OutData)
    );


    // 计算完成信号
    always @ (posedge clk or posedge rst) begin
        if (rst) done <= 0;
        else if (conv1CpuInData == 32'ha0602880) done <= 1;
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) dispDmemAddr = 32'h100104ac;
    end

    assign dmemAddr = done ? dispDmemAddr : cpuDmemAddr;
    assign dispDmemData = done ? convMemInData : 32'b0;

endmodule
