`timescale 1ns / 1ps

module MULer(
    input wire sign,
    input wire [31:0] iA,
    input wire [31:0] iB,
    output reg [63:0] oZ
    );

    reg [31:0] rA;
    reg [31:0] rB;
    reg [63:0] temp;
    wire isNeg = iA[31] ^ iB[31];
    integer i;

    always @ * begin
        oZ = 64'b0;
        if (sign) begin
            rA = iA[31] ? -iA : iA;
            rB = iB[31] ? -iB : iB;
            for (i = 0; i < 32; i = i + 1) begin
                temp = rB[i] ? ({32'b0, rA} << i) : 64'b0;
                oZ = oZ + temp;
            end
            if (isNeg) oZ = -oZ;
        end
        else begin
            rA = iA;
            rB = iB;
            for (i = 0; i < 32; i = i + 1) begin
                temp = rB[i] ? ({32'b0, rA} << i) : 64'b0;
                oZ = oZ + temp;
            end
        end
    end

endmodule
