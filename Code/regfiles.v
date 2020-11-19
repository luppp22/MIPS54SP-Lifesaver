`timescale 1ns / 1ps

module RegFiles(
    input wire clk,
    input wire rst,
    input wire wena,
    input wire [4:0] iRAddr1,
    input wire [4:0] iRAddr2,
    input wire [4:0] iWAddr,
    input wire [31:0] iWData,
    output wire [31:0] oRData1,
    output wire [31:0] oRData2
    );

    reg [31:0] rData [0:31];

    integer i;

    // todo: posedge or negedge clk?
    always @ (negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                rData[i] <= 32'b0;
        end
        else if (wena && iWAddr != 5'b0)
            rData[iWAddr] <= iWData;
    end

    assign oRData1 = rData[iRAddr1];
    assign oRData2 = rData[iRAddr2];

endmodule
