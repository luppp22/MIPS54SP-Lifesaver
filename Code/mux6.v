`timescale 1ns / 1ps

module MUX6 #(
        parameter DATA_WIDTH = 32
    ) (
        input wire [DATA_WIDTH-1:0] iData0,
        input wire [DATA_WIDTH-1:0] iData1,
        input wire [DATA_WIDTH-1:0] iData2,
        input wire [DATA_WIDTH-1:0] iData3,
        input wire [DATA_WIDTH-1:0] iData4,
        input wire [DATA_WIDTH-1:0] iData5, 
        input wire [5:0] select,
        output wire [DATA_WIDTH-1:0] oData
    );

    reg [DATA_WIDTH-1:0] rData;

    always @ (*) begin
        case(select)
            6'b000001: rData = iData0;
            6'b000010: rData = iData1;
            6'b000100: rData = iData2;
            6'b001000: rData = iData3;
            6'b010000: rData = iData4;
            6'b100000: rData = iData5;
            default: rData = {DATA_WIDTH{1'bz}};
        endcase
    end

    assign oData = rData;

endmodule
