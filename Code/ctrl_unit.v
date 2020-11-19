`timescale 1ns / 1ps

`include "definition.vh"

module CtrlUnit(
    input wire [31:0] idInstr,
    input wire [31:0] exInstr,
    input wire [31:0] meInstr,
    input wire [31:0] wbInstr,
    input wire [31:0] cp0Status,
    input wire halt,
    input wire beq,
    input wire eq0,
    input wire divBusy,
    output reg hiWena,
    output reg loWena,
    output reg cp0Mfc0,
    output reg cp0Mtc0,
    output reg cp0Exce,
    output reg cp0Eret,
    output reg [31:0] cp0Cause,
    output reg rfWena,
    output reg ext16Sign,
    output reg divStart,
    output reg divSign,
    output reg mulSign,
    output reg [`ALUCW-1:0] aluCtrl,
    output reg dmemWena,
    output reg [`WCONVW-1:0] conv1Wtype,
    output reg [`WCONVW-1:0] conv2Wtype,
    output reg conv2Sign,
    output reg [`MUXW_PC-1:0] muxPCSel,
    output reg [`MUXW_HI-1:0] muxHiSel,
    output reg [`MUXW_LO-1:0] muxLoSel,
    output reg [`MUXW_ALUA-1:0] muxAluASel,
    output reg [`MUXW_ALUB-1:0] muxAluBSel,
    output reg [`MUXW_DATA-1:0] muxDataSel,
    output reg [`MUXW_ADDR-1:0] muxAddrSel,
    output reg [`CTRL_STALLW-1:0] stall
    );

    // ID部分译码
    wire [5:0] idOp = idInstr[31:26];
    wire [4:0] idRs = idInstr[25:21];
    wire [4:0] idRt = idInstr[20:16];
    wire [5:0] idFunc = idInstr[5:0];
    wire idOpAddi = (idOp == `OP_ADDI);
    wire idOpAddiu = (idOp == `OP_ADDIU);
    wire idOpAndi = (idOp == `OP_ANDI);
    wire idOpOri = (idOp == `OP_ORI);
    wire idOpSltiu = (idOp == `OP_SLTIU);
    wire idOpLui = (idOp == `OP_LUI);
    wire idOpXori = (idOp == `OP_XORI);
    wire idOpSlti = (idOp == `OP_SLTI);
    wire idOpAddu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_ADDU);
    wire idOpAnd = (idOp == `OP_SPECIAL && idFunc == `FUNCT_AND);
    wire idOpBeq = (idOp == `OP_BEQ);
    wire idOpBne = (idOp == `OP_BNE);
    wire idOpJ = (idOp == `OP_J);
    wire idOpJal = (idOp == `OP_JAL);
    wire idOpJr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_JR);
    wire idOpLw = (idOp == `OP_LW);
    wire idOpXor = (idOp == `OP_SPECIAL && idFunc == `FUNCT_XOR);
    wire idOpNor = (idOp == `OP_SPECIAL && idFunc == `FUNCT_NOR);
    wire idOpOr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_OR);
    wire idOpSll = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLL && idInstr != 32'b0);
    wire idOpSllv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLLV);
    wire idOpSltu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLTU);
    wire idOpSra = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRA);
    wire idOpSrl = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRL);
    wire idOpSubu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SUBU);
    wire idOpSw = (idOp == `OP_SW);
    wire idOpAdd = (idOp == `OP_SPECIAL && idFunc == `FUNCT_ADD);
    wire idOpSub = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SUB);
    wire idOpSlt = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLT);
    wire idOpSrlv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRLV);
    wire idOpSrav = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRAV);
    wire idOpClz = (idOp == `OP_SPECIAL2 && idFunc == `FUNCT_CLZ);
    wire idOpDivu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_DIVU);
    wire idOpEret = (idOp == `OP_COP0 && idFunc == `FUNCT_ERET);
    wire idOpJalr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_JALR);
    wire idOpLb = (idOp == `OP_LB);
    wire idOpLbu = (idOp == `OP_LBU);
    wire idOpLhu = (idOp == `OP_LHU);
    wire idOpSb = (idOp == `OP_SB);
    wire idOpSh = (idOp == `OP_SH);
    wire idOpLh = (idOp == `OP_LH);
    wire idOpMfc0 = (idOp == `OP_COP0 && idRs == `RS_MF);
    wire idOpMfhi = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MFHI);
    wire idOpMflo = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MFLO);
    wire idOpMtc0 = (idOp == `OP_COP0 && idRs == `RS_MT);
    wire idOpMthi = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MTHI);
    wire idOpMtlo = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MTLO);
    wire idOpMul = (idOp == `OP_SPECIAL2 && idFunc == `FUNCT_MUL);
    wire idOpMultu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MULTU);
    wire idOpSyscall = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SYSCALL);
    wire idOpTeq = (idOp == `OP_SPECIAL && idFunc == `FUNCT_TEQ);
    wire idOpBgez = (idOp == `OP_REGIMM && idRt == `RT_BGEZ);
    wire idOpBreak = (idOp == `OP_SPECIAL && idFunc == `FUNCT_BREAK);
    wire idOpDiv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_DIV);

    // EX部分译码
    wire [5:0] exOp = exInstr[31:26];
    wire [5:0] exFunc = exInstr[5:0];
    wire [5:0] exRs = exInstr[25:21];
    wire [4:0] exRt = exInstr[20:16];
    wire [4:0] exRd = exInstr[15:11];
    wire exOpAddi = (exOp == `OP_ADDI);
    wire exOpAddiu = (exOp == `OP_ADDIU);
    wire exOpAndi = (exOp == `OP_ANDI);
    wire exOpOri = (exOp == `OP_ORI);
    wire exOpSltiu = (exOp == `OP_SLTIU);
    wire exOpLui = (exOp == `OP_LUI);
    wire exOpXori = (exOp == `OP_XORI);
    wire exOpSlti = (exOp == `OP_SLTI);
    wire exOpAddu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_ADDU);
    wire exOpAnd = (exOp == `OP_SPECIAL && exFunc == `FUNCT_AND);
    wire exOpBeq = (exOp == `OP_BEQ);
    wire exOpBne = (exOp == `OP_BNE);
    wire exOpJ = (exOp == `OP_J);
    wire exOpJal = (exOp == `OP_JAL);
    wire exOpJr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_JR);
    wire exOpLw = (exOp == `OP_LW);
    wire exOpXor = (exOp == `OP_SPECIAL && exFunc == `FUNCT_XOR);
    wire exOpNor = (exOp == `OP_SPECIAL && exFunc == `FUNCT_NOR);
    wire exOpOr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_OR);
    wire exOpSll = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLL && exInstr != 32'b0);
    wire exOpSllv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLLV);
    wire exOpSltu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLTU);
    wire exOpSra = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRA);
    wire exOpSrl = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRL);
    wire exOpSubu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SUBU);
    wire exOpSw = (exOp == `OP_SW);
    wire exOpAdd = (exOp == `OP_SPECIAL && exFunc == `FUNCT_ADD);
    wire exOpSub = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SUB);
    wire exOpSlt = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLT);
    wire exOpSrlv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRLV);
    wire exOpSrav = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRAV);
    wire exOpClz = (exOp == `OP_SPECIAL2 && exFunc == `FUNCT_CLZ);
    wire exOpDivu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_DIVU);
    wire exOpEret = (exOp == `OP_COP0 && exFunc == `FUNCT_ERET);
    wire exOpJalr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_JALR);
    wire exOpLb = (exOp == `OP_LB);
    wire exOpLbu = (exOp == `OP_LBU);
    wire exOpLhu = (exOp == `OP_LHU);
    wire exOpSb = (exOp == `OP_SB);
    wire exOpSh = (exOp == `OP_SH);
    wire exOpLh = (exOp == `OP_LH);
    wire exOpMfc0 = (exOp == `OP_COP0 && exRs == `RS_MF);
    wire exOpMfhi = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MFHI);
    wire exOpMflo = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MFLO);
    wire exOpMtc0 = (exOp == `OP_COP0 && exRs == `RS_MT);
    wire exOpMthi = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MTHI);
    wire exOpMtlo = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MTLO);
    wire exOpMul = (exOp == `OP_SPECIAL2 && exFunc == `FUNCT_MUL);
    wire exOpMultu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MULTU);
    wire exOpSyscall = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SYSCALL);
    wire exOpTeq = (exOp == `OP_SPECIAL && exFunc == `FUNCT_TEQ);
    wire exOpBgez = (exOp == `OP_REGIMM && exRt == `RT_BGEZ);
    wire exOpBreak = (exOp == `OP_SPECIAL && exFunc == `FUNCT_BREAK);
    wire exOpDiv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_DIV);

    // ME部分译码
    wire [5:0] meOp = meInstr[31:26];
    wire [5:0] meFunc = meInstr[5:0];
    wire [5:0] meRs = meInstr[25:21];
    wire [4:0] meRt = meInstr[20:16];
    wire [4:0] meRd = meInstr[15:11];
    wire meOpAddi = (meOp == `OP_ADDI);
    wire meOpAddiu = (meOp == `OP_ADDIU);
    wire meOpAndi = (meOp == `OP_ANDI);
    wire meOpOri = (meOp == `OP_ORI);
    wire meOpSltiu = (meOp == `OP_SLTIU);
    wire meOpLui = (meOp == `OP_LUI);
    wire meOpXori = (meOp == `OP_XORI);
    wire meOpSlti = (meOp == `OP_SLTI);
    wire meOpAddu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_ADDU);
    wire meOpAnd = (meOp == `OP_SPECIAL && meFunc == `FUNCT_AND);
    wire meOpBeq = (meOp == `OP_BEQ);
    wire meOpBne = (meOp == `OP_BNE);
    wire meOpJ = (meOp == `OP_J);
    wire meOpJal = (meOp == `OP_JAL);
    wire meOpJr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_JR);
    wire meOpLw = (meOp == `OP_LW);
    wire meOpXor = (meOp == `OP_SPECIAL && meFunc == `FUNCT_XOR);
    wire meOpNor = (meOp == `OP_SPECIAL && meFunc == `FUNCT_NOR);
    wire meOpOr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_OR);
    wire meOpSll = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLL && meInstr != 32'b0);
    wire meOpSllv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLLV);
    wire meOpSltu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLTU);
    wire meOpSra = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRA);
    wire meOpSrl = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRL);
    wire meOpSubu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SUBU);
    wire meOpSw = (meOp == `OP_SW);
    wire meOpAdd = (meOp == `OP_SPECIAL && meFunc == `FUNCT_ADD);
    wire meOpSub = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SUB);
    wire meOpSlt = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLT);
    wire meOpSrlv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRLV);
    wire meOpSrav = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRAV);
    wire meOpClz = (meOp == `OP_SPECIAL2 && meFunc == `FUNCT_CLZ);
    wire meOpDivu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_DIVU);
    wire meOpEret = (meOp == `OP_COP0 && meFunc == `FUNCT_ERET);
    wire meOpJalr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_JALR);
    wire meOpLb = (meOp == `OP_LB);
    wire meOpLbu = (meOp == `OP_LBU);
    wire meOpLhu = (meOp == `OP_LHU);
    wire meOpSb = (meOp == `OP_SB);
    wire meOpSh = (meOp == `OP_SH);
    wire meOpLh = (meOp == `OP_LH);
    wire meOpMfc0 = (meOp == `OP_COP0 && meRs == `RS_MF);
    wire meOpMfhi = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MFHI);
    wire meOpMflo = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MFLO);
    wire meOpMtc0 = (meOp == `OP_COP0 && meRs == `RS_MT);
    wire meOpMthi = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MTHI);
    wire meOpMtlo = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MTLO);
    wire meOpMul = (meOp == `OP_SPECIAL2 && meFunc == `FUNCT_MUL);
    wire meOpMultu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MULTU);
    wire meOpSyscall = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SYSCALL);
    wire meOpTeq = (meOp == `OP_SPECIAL && meFunc == `FUNCT_TEQ);
    wire meOpBgez = (meOp == `OP_REGIMM && meRt == `RT_BGEZ);
    wire meOpBreak = (meOp == `OP_SPECIAL && meFunc == `FUNCT_BREAK);
    wire meOpDiv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_DIV);

    // 用于处理数据相关
    reg rRsId;  // ID段是否读了RF[rs]
    reg rRtId;
    reg rHiId;  // ID段是否读了HI
    reg rLoId;
    reg rCp0Id;  // ID段是否读了Cp0

    reg wRegEx;  // EX段是否写了RF
    reg wHiEx;
    reg wLoEx;
    reg wCp0Ex;
    reg [4:0] wAddrEx;  // EX段写RF的地址

    reg wRegMe;
    reg wHiMe;
    reg wLoMe;
    reg wCp0Me;
    reg [4:0] wAddrMe;





    // ID段产生控制信号
    always @ * begin
        hiWena = 0;
        loWena = 0;
        cp0Mfc0 = 0;
        cp0Mtc0 = 0;
        cp0Exce = 0;
        cp0Eret = 0;
        cp0Cause = 32'b0;
        rfWena = 0;
        ext16Sign = 0;
        divStart = 0;
        divSign = 0;
        mulSign = 0;
        aluCtrl = `ALU_OP_NOP;
        dmemWena = 0;
        conv1Wtype = 2'b0;
        conv2Wtype = 2'b0;
        conv2Sign = 0;
        muxPCSel = `MUX_PC_NPC;  // todo: check
        muxHiSel = `MUXW_HI'b0;
        muxLoSel = `MUXW_LO'b0;
        muxAluASel = `MUXW_ALUA'b0;
        muxAluBSel = `MUXW_ALUB'b0;
        muxDataSel = `MUXW_DATA'b0;
        muxAddrSel = `MUXW_ADDR'b0;
        if (idOpAddi) begin
            muxAluASel = `MUX_ALUA_RS;
            ext16Sign = 1;
            muxAluBSel = `MUX_ALUB_EXT16;
            aluCtrl = `ALU_OP_ADD;
            muxDataSel = `MUX_DATA_ALU;
            muxAddrSel = `MUX_ADDR_RT;
            rfWena = 1;
        end
        else if (idOpBeq) begin
            if (beq) begin
                muxPCSel = `MUX_PC_BRANCH;
            end
        end
        else if (idOpLw) begin
            muxAluASel = `MUX_ALUA_RS;
            ext16Sign = 1;
            muxAluBSel = `MUX_ALUB_EXT16;
            aluCtrl = `ALU_OP_ADD;
            conv2Wtype = `WCONV_WORD;
            muxDataSel = `MUX_DATA_MD;
            muxAddrSel = `MUX_ADDR_RT;
            rfWena = 1;
        end
        else if (idOpSw) begin
            muxAluASel = `MUX_ALUA_RS;
            ext16Sign = 1;
            muxAluBSel = `MUX_ALUB_EXT16;
            aluCtrl = `ALU_OP_ADD;
            conv1Wtype = `WCONV_WORD;
            dmemWena = 1;
        end
        else if (idOpEret) begin
            cp0Eret = 1;
            muxPCSel = `MUX_PC_EPC;
        end
        else if (idOpMfc0) begin
            cp0Mfc0 = 1;
            muxAluASel = `MUX_ALUA_CP0;
            aluCtrl = `ALU_OP_PASSA;
            muxDataSel = `MUX_DATA_ALU;
            muxAddrSel = `MUX_ADDR_RT;
            rfWena = 1;
        end
        else if (idOpMtc0) begin
            muxAluBSel = `MUX_ALUB_RT;
            aluCtrl = `ALU_OP_PASSB;
            muxDataSel = `MUX_DATA_ALU;
            muxAddrSel = `MUX_ADDR_RD;
            cp0Mtc0 = 1;
        end
        else if (idOpSyscall) begin  // todo: check
            if (cp0Status[0] && cp0Status[`CP0_SYSCALL_POS]) begin
                cp0Exce = 1;
                cp0Cause = `CP0_CAUSE_SYSCALL;
            end
        end
        // ...
    end




    // 检测ID段是否读寄存器
    always @ * begin
        rRsId = 0;
        rRtId = 0;
        rHiId = 0;
        rLoId = 0;
        rCp0Id = 0;
        if (
            idOpAddi    || idOpAddiu    || idOpAndi     || idOpOri      ||
            idOpSltiu   // ...
        ) begin
            rRsId = 1;
        end
        if (
            idOpAddu    || idOpAnd      || idOpBeq      || idOpBne      ||
            idOpXor     // ...
        ) begin
            rRtId = 1;
        end
        if (idOpMfhi) begin
            rHiId = 1;
        end
        if (idOpMflo) begin
            rLoId = 1;
        end
        if (idOpMfc0) begin
            rCp0Id = 1;
        end
    end





    // 检测EX段是否写寄存器
    always @ * begin
        wRegEx = 0;
        wHiEx = 0;
        wLoEx = 0;
        wCp0Ex = 0;
        wAddrEx = 5'b0;
        if (
            exOpAddi    || exOpAddiu    || exOpAndi     || exOpOri      ||
            exOpSltiu   // ...
        ) begin
            wRegEx = 1;
            wAddrEx = exRt;
        end
        if (
            exOpAddu    || exOpAnd      || exOpXor      || exOpNor      ||
            exOpOr      // ...
        ) begin
            wRegEx = 1;
            wAddrEx = exRd;
        end
        if (exOpJal) begin
            wRegEx = 1;
            wAddrEx = 5'b11111;
        end
        if (
            exOpMthi    || exOpDiv      || exOpDivu     || exOpMultu
        ) begin
            wHiEx = 1;
        end
        if (
            exOpMtlo    || exOpDiv      || exOpDivu     || exOpMultu
        ) begin
            wLoEx = 1;
        end
        if (exOpMtc0) begin
            wCp0Ex = 1;
        end

    end





    // 检测ME段是否写寄存器
    always @ * begin
        wRegMe = 0;
        wHiMe = 0;
        wLoMe = 0;
        wCp0Me = 0;
        wAddrMe = 5'b0;
        if (
            meOpAddi    || meOpAddiu    || meOpAndi     || meOpOri      ||
            meOpSltiu   // ...
        ) begin
            wRegMe = 1;
            wAddrMe = meRt;
        end
        if (
            meOpAddu    || meOpAnd      || meOpXor      || meOpNor      ||
            meOpOr      // ...
        ) begin
            wRegMe = 1;
            wAddrMe = meRd;
        end
        if (meOpJal) begin
            wRegMe = 1;
            wAddrMe = 5'b11111;
        end
        if (
            meOpMthi    || meOpDiv      || meOpDivu     || meOpMultu
        ) begin
            wHiMe = 1;
        end
        if (
            meOpMtlo    || meOpDiv      || meOpDivu     || meOpMultu
        ) begin
            wLoMe = 1;
        end
        if (meOpMtc0) begin
            wCp0Me = 1;
        end
    end





    // 流水线暂停的情况
    always @ * begin
        stall = `CTRL_STALLW'b0;
        if (halt) begin
            stall = `CTRL_STALL_ALL;
        end
        else if (wRegEx) begin
            if (
                (rRsId && wAddrEx == idRs) ||
                (rRtId && wAddrEx == idRt)
            ) begin
                stall = `CTRL_STALL_ID;    
            end
        end
        else if (wHiEx && rHiId) begin
            stall = `CTRL_STALL_ID;
        end
        else if (wLoEx && rLoId) begin
            stall = `CTRL_STALL_ID;    
        end
        else if (wCp0Ex && rCp0Id) begin
            stall = `CTRL_STALL_ID;    
        end
        else if (wRegMe) begin
            if (
                (rRsId && wAddrMe == idRs) ||
                (rRtId && wAddrMe == idRt)
            ) begin
                stall = `CTRL_STALL_ID;
            end
        end
        else if (wHiMe && rHiId) begin
            stall = `CTRL_STALL_ID;    
        end
        else if (wLoMe && rLoId) begin
            stall = `CTRL_STALL_ID;    
        end
        else if (wCp0Me && rCp0Id) begin
            stall = `CTRL_STALL_ID;    
        end
        else if (exOpDiv || exOpDivu) begin
            if (divBusy) begin
                stall = `CTRL_STALL_EX;
            end
        end
    end

endmodule
