`timescale 1ns / 1ps

module MUX5 #(
        parameter DATA_WIDTH = 32
    ) (
        input wire [DATA_WIDTH-1:0] iData0,
        input wire [DATA_WIDTH-1:0] iData1,
        input wire [DATA_WIDTH-1:0] iData2,
        input wire [DATA_WIDTH-1:0] iData3,
        input wire [DATA_WIDTH-1:0] iData4,
        input wire [4:0] select,
        output wire [DATA_WIDTH-1:0] oData
    );

    reg [DATA_WIDTH-1:0] rData;

    always @ (*) begin
        case(select)
            5'b00001: rData = iData0;
            5'b00010: rData = iData1;
            5'b00100: rData = iData2;
            5'b01000: rData = iData3;
            5'b10000: rData = iData4;
            default: rData = {DATA_WIDTH{1'bz}};
        endcase
    end

    assign oData = rData;

endmodule
