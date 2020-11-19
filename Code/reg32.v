`timescale 1ns / 1ps

module Reg32 #(
        parameter INIT_VALUE = 32'b0
    ) (
        input wire clk,
        input wire rst,
        input wire wena,
        input wire [31:0] iData,
        output wire [31:0] oData
    );

    reg [31:0] rData;

    always @ (posedge clk or posedge rst) begin
        if (rst) rData <= INIT_VALUE;
        else if (wena) rData <= iData;
    end

    assign oData = rData;

endmodule
