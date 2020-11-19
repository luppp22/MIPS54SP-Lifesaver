`timescale 1ns / 1ps

module EXT #(
        parameter IWIDTH = 16,
        parameter OWIDTH = 32
    ) (
        input wire [IWIDTH-1:0] iData,
        input wire sign,
        output wire [OWIDTH-1:0] oData 
    );

    assign oData = (sign ? {{(OWIDTH-IWIDTH){iData[IWIDTH-1]}}, iData[IWIDTH-1:0]} : {{(32-IWIDTH){1'b0}}, iData[IWIDTH-1:0]});

endmodule
