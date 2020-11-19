`timescale 1ns / 1ps

`include "definition.vh"

module ALU(
    input wire [31:0] iA,
    input wire [31:0] iB,
    input wire [`ALUCW-1:0] oprType,
    output wire [31:0] oResult,
    output wire oZero,
    output wire oCarry,
    output wire oNegative,
    output wire oOverflow
    );

    reg [32:0] rResult;
    reg rZero;
    reg rCarry;
    reg rNegative;
    reg rOverflow;

    reg [15:0] part16;
    reg [7:0] part8;
    reg [3:0] part4;
    reg [1:0] part2;

    always @ (*) begin
        case(oprType)
            `ALU_OP_ADDU: begin
                rResult = iA + iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rCarry = rResult[32];
                rNegative = rResult[31];
            end
            `ALU_OP_ADD: begin
                rResult = iA + iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
                if($signed(iA) > 0 && $signed(iB) > 0 && $signed(rResult[31:0]) < 0) rOverflow = 1;
                else if($signed(iA) < 0 && $signed(iB) < 0 && $signed(rResult[31:0]) > 0) rOverflow = 1;
                else rOverflow = 0;
            end
            `ALU_OP_SUBU: begin
                rResult = iA - iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rCarry = rResult[32];
                rNegative = rResult[31];
            end
            `ALU_OP_SUB: begin
                rResult = iA - iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
                if($signed(iA) > 0 && $signed(iB) < 0 && $signed(rResult[31:0]) < 0) rOverflow = 1;
                else if($signed(iA) < 0 && $signed(iB) > 0 && $signed(rResult[31:0]) > 0) rOverflow = 1;
                else rOverflow = 0;
            end
            `ALU_OP_AND: begin
                rResult = iA & iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_OR: begin
                rResult = iA | iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_XOR: begin
                rResult = iA ^ iB;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_NOR: begin
                rResult = ~(iA | iB);
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_LUI: begin
                rResult = {iB[15:0], 16'b0};
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_SLT: begin
                rResult = ($signed(iA) < $signed(iB) ? 32'b1 : 32'b0);
                rZero = (iA == iB ? 1'b1 : 1'b0);
                rNegative = ($signed(iA) < $signed(iB) ? 1'b1 : 1'b0);
            end
            `ALU_OP_SLTU: begin
                rResult = (iA < iB ? 32'b1 : 32'b0);
                rZero = (iA == iB ? 1'b1 : 1'b0);
                rCarry = (iA < iB ? 1'b1 : 1'b0);
                rNegative = rResult[31];
            end
            `ALU_OP_SRA: begin
                rResult[31:0] = ($signed(iB)) >>> iA;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rCarry = (iA == 0 ? 0 : iB[iA - 1]);
                rNegative = rResult[31];
            end
            `ALU_OP_SLL_SLA: begin
                rResult[31:0] = iB << iA;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rCarry = (iA == 0 ? 0 : iB[31 - iA + 1]);
                rNegative = rResult[31];
            end
            `ALU_OP_SRL: begin
                rResult[31:0] = iB >> iA;
                rZero = (rResult[31:0] == 32'b0 ? 1'b1 : 1'b0);
                rCarry = iB[iA - 1];
                rNegative = rResult[31];
            end
            `ALU_OP_CLZ: begin
                if(iA == 32'b0) rResult[31:0] = 32'h20;
                else begin
                    rResult[4] = (iA[31:16] == 16'b0);
                    part16 = rResult[4] ? iA[15:0] : iA[31:16];
                    rResult[3] = (part16[15:8] == 8'b0);
                    part8 = rResult[3] ? part16[7:0] : part16[15:8];
                    rResult[2] = (part8[7:4] == 4'b0);
                    part4 = rResult[2] ? part8[3:0] : part8[7:4];
                    rResult[1] = (part4[3:2] == 2'b0);
                    part2 = rResult[1] ? part4[1:0] : part4[3:2];
                    rResult[0] = (part2[1] == 1'b0);
                end
            end
            `ALU_OP_PASSA: begin
                rResult = iA;
                rZero = (rResult == 32'b0) ? 1'b1 : 1'b0;
                rNegative = rResult[31];
            end
            `ALU_OP_PASSB: begin
                rResult = iB;
                rZero = (rResult == 32'b0) ? 1'b1 : 1'b0;
                rNegative = rResult[31];
            end
            default: begin
                rResult = 33'b0;
                rZero = 0;
                rCarry = 0;
                rNegative = 0;
                rOverflow = 0;
            end
        endcase
    end

    assign oResult = rResult[31:0];
    assign oZero = rZero;
    assign oCarry = rCarry;
    assign oNegative = rNegative;
    assign oOverflow = rOverflow;

endmodule
