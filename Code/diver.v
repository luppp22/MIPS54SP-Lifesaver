`timescale 1ns / 1ps

module DIVer(
    input wire [31:0] iDividend,
    input wire [31:0] iDivisor,
    input wire start,
    input wire clk,
    input wire rst,
    input wire sign,
    output wire [31:0] oQ,
    output wire [31:0] oR,
    output reg rBusy
    );

    reg [4:0] rCount;
    reg [31:0] rQ;
    reg [31:0] rR;
    reg [31:0] rB;
    reg rSign;
    reg rReady;
    
    wire [31:0] aQ = rQ;
    wire [31:0] aR = rSign ? rR + rB : rR;

    wire [32:0] subAdd = rSign ? ({rR, rQ[31]} + {1'b0, rB}) : ({rR, rQ[31]} - {1'b0, rB});

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            rCount <= 5'b0;
            rBusy <= 0;
            rSign <= 0;
            rReady <= 0;
            rQ <= 32'b0;
            rR <= 32'b0;
            rB <= 32'b0;
        end
        else begin
            if(start) begin
                rR <= 32'b0;
                rSign <= 0;
                rQ <= (sign && iDividend[31]) ? -iDividend : iDividend;
                rB <= (sign && iDivisor[31]) ? -iDivisor : iDivisor;
                rCount <= 5'b0;
                rBusy <= 1;
            end
            else if(rBusy) begin
                rR <= subAdd[31:0];
                rSign <= subAdd[32];
                rQ <= {rQ[30:0], ~subAdd[32]};
                rCount <= rCount + 5'b1;
                if(rCount == 5'h1f) begin
                    rBusy <= 0;
                    rReady <= 1;
                end
            end
            else if(rReady) rReady <= 0;
        end
    end

    assign oQ = rReady ? ((sign && (iDividend[31] ^ iDivisor[31])) ? -aQ : aQ) : 32'bz;
    assign oR = rReady ? ((sign && iDividend[31]) ? -aR : aR) : 32'bz;

endmodule

