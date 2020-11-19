`timescale 1ns / 1ps

`include "definition.vh"

module CPU(
    input wire clk,
    input wire rst,
    input wire halt,
    input wire [31:0] iImemData,
    input wire [31:0] iDmemData,
    output wire [31:0] oImemAddr,
    output wire [31:0] oDmemAddr,
    output wire [31:0] oDmemData,
    output wire oDmemWena,
    output wire [`WCONVW-1:0] oConv1Wtype,
    output wire [`WCONVW-1:0] oConv2Wtype,
    output wire oConv2Sign
    );




    // IF段信号声明
    wire [31:0] ifMuxPCOut;
    wire [31:0] ifPCOut;
    wire [31:0] ifImemOut;

    // IF/ID段信号声明
    reg [31:0] ifidNPC;
    reg [31:0] ifidIR;
    
    // ID段信号声明
    wire idBeq;
    wire idEq0;
    wire [31:0] idCp0Status;
    wire idHiWena;
    wire idLoWena;
    wire idCp0Mfc0;
    wire idCp0Mtc0;
    wire idCp0Exce;
    wire idCp0Eret;
    wire [31:0] idCp0Cause;
    wire idRfWena;
    wire idExt16Sign;
    wire idDivStart;
    wire idDivSign;
    wire idMulSign;
    wire [`ALUCW-1:0] idAluCtrl;
    wire idDmemWena;
    wire [`WCONVW-1:0] idConv1Wtype;
    wire [`WCONVW-1:0] idConv2Wtype;
    wire idConv2Sign;
    wire [`MUXW_PC-1:0] idMuxPCSel;  // todo: check
    wire [`MUXW_HI-1:0] idMuxHiSel;
    wire [`MUXW_LO-1:0] idMuxLoSel;
    wire [`MUXW_ALUA-1:0] idMuxAluASel;
    wire [`MUXW_ALUB-1:0] idMuxAluBSel;
    wire [`MUXW_DATA-1:0] idMuxDataSel;
    wire [`MUXW_ADDR-1:0] idMuxAddrSel;
    wire [31:0] idOffsetShift;
    wire [31:0] idHiOut;
    wire [31:0] idLoOut;
    wire [31:0] idEpcOut;
    wire [31:0] idCp0Out;
    wire [31:0] idRfData1;
    wire [31:0] idRfData2;
    wire [31:0] idExt16Out;
    wire [31:0] idExt5Out;
    wire [31:0] idMuxAluAout;
    wire [31:0] idMuxAluBOut;

    // ID/EX段信号声明
    reg [31:0] idexAluA;
    reg [31:0] idexAluB;
    reg [31:0] idexRdata;
    reg [31:0] idexIR;
    reg idexHiWena;
    reg idexLoWena;
    reg idexRfWena;
    reg idexCp0Mtc0;
    reg idexDivStart;
    reg idexDivSign;
    reg idexMulSign;
    reg [`ALUCW-1:0] idexAluCtrl;
    reg idexDmemWena;
    reg [`WCONVW-1:0] idexConv1Wtype;
    reg [`WCONVW-1:0] idexConv2Wtype;
    reg idexConv2Sign;
    reg [`MUXW_HI-1:0] idexMuxHiSel;
    reg [`MUXW_LO-1:0] idexMuxLoSel;
    reg [`MUXW_DATA-1:0] idexMuxDataSel;
    reg [`MUXW_ADDR-1:0] idexMuxAddrSel;

    // EX段信号声明
    wire exDivBusy;
    wire [31:0] exDiverQ;
    wire [31:0] exDiverR;
    wire [63:0] exMulerZ;
    wire [31:0] exAluOut;

    // EX/ME段信号声明
    reg [31:0] exmeQ;
    reg [31:0] exmeR;
    reg [63:0] exmeZ;
    reg [31:0] exmeAluO;
    reg [31:0] exmeRdata;
    reg [31:0] exmeIR;
    reg exmeHiWena;
    reg exmeLoWena;
    reg exmeRfWena;
    reg exmeCp0Mtc0;
    reg exmeDmemWena;
    reg [`WCONVW-1:0] exmeConv1Wtype;
    reg [`WCONVW-1:0] exmeConv2Wtype;
    reg exmeConv2Sign;
    reg [`MUXW_HI-1:0] exmeMuxHiSel;
    reg [`MUXW_LO-1:0] exmeMuxLoSel;
    reg [`MUXW_DATA-1:0] exmeMuxDataSel;
    reg [`MUXW_ADDR-1:0] exmeMuxAddrSel;
    
    // ME段信号声明
    wire [31:0] meDmemOut;

    // ME/WB段信号声明
    reg [31:0] mewbQ;
    reg [31:0] mewbR;
    reg [63:0] mewbZ;
    reg [31:0] mewbAluO;
    reg [31:0] mewbMdata;
    reg [31:0] mewbIR;
    reg mewbHiWena;
    reg mewbLoWena;
    reg mewbRfWena;
    reg mewbCp0Mtc0;
    reg [`MUXW_HI-1:0] mewbMuxHiSel;
    reg [`MUXW_LO-1:0] mewbMuxLoSel;
    reg [`MUXW_DATA-1:0] mewbMuxDataSel;
    reg [`MUXW_ADDR-1:0] mewbMuxAddrSel;

    // WB段信号声明
    wire [31:0] wbMuxHiOut;
    wire [31:0] wbMuxLoOut;
    wire [31:0] wbMuxDataOut;
    wire [4:0] wbMuxAddrOut;

    // 其他信号
    wire [`CTRL_STALLW-1:0] stall;
    




    // 控制模块
    CtrlUnit ctrlUnit(
        .idInstr(ifidIR),
        .exInstr(idexIR),
        .meInstr(exmeIR),
        .wbInstr(mewbIR),
        .cp0Status(idCp0Status),
        .halt(halt),
        .beq(idBeq),
        .eq0(idEq0),
        .divBusy(exDivBusy),
        .hiWena(idHiWena),
        .loWena(idLoWena),
        .cp0Mfc0(idCp0Mfc0),
        .cp0Mtc0(idCp0Mtc0),
        .cp0Exce(idCp0Exce),
        .cp0Eret(idCp0Eret),
        .cp0Cause(idCp0Cause),
        .rfWena(idRfWena),
        .ext16Sign(idExt16Sign),
        .divStart(idDivStart),
        .divSign(idDivSign),
        .mulSign(idMulSign),
        .aluCtrl(idAluCtrl),
        .dmemWena(idDmemWena),
        .conv1Wtype(idConv1Wtype),
        .conv2Wtype(idConv2Wtype),
        .conv2Sign(idConv2Sign),
        .muxPCSel(idMuxPCSel),
        .muxHiSel(idMuxHiSel),
        .muxLoSel(idMuxLoSel),
        .muxAluASel(idMuxAluASel),
        .muxAluBSel(idMuxAluBSel),
        .muxDataSel(idMuxDataSel),
        .muxAddrSel(idMuxAddrSel),
        .stall(stall)
    );
    

    

    

    // IF段
    MUX5 muxPC(
        // ...
    );
    Reg32 pc(
        .clk(clk),
        .rst(rst),
        .wena(~stall[`STAGE_IF]),
        .iData(ifMuxPCOut),
        .oData(ifPCOut)
    );
    assign oImemAddr = ifPCOut;
    assign ifImemOut = iImemData;





    // IF/ID段
    always @ (posedge clk or posedge rst) begin
        if (rst || (stall[`STAGE_IF] && !stall[`STAGE_ID])) begin
            ifidNPC <= 32'b0;
            ifidIR <= 32'b0;
        end
        else if (!stall[`STAGE_IF]) begin
            ifidNPC <= ifPCOut + 32'h4;
            ifidIR <= ifImemOut;
        end
    end





    // ID段
    Reg32 hi(
        // ..
    );
    Reg32 lo(
        // ..
    );
    CP0 cp0(
        // ...
    );
    RegFiles rf(
        // ...
    );
    EXT #(
        .IWIDTH(16)
    ) ext16(
        // ...
    );
    EXT #(
        .IWIDTH(5)
    ) ext5(
        // ...
    );
    MUX6 muxAluA(
        // ...
    );
    MUX3 muxAluB(
        // ...
    );
    assign idOffsetShift = {{(14){ifidIR[15]}}, ifidIR[15:0], 2'b0};
    assign idBeq = (idRfData1 == idRfData2);
    assign idEq0 = (idRfData1 == 32'h0);





    // ID/EX段
    always @ (posedge clk or posedge rst) begin
        if (rst || (stall[`STAGE_ID] && !stall[`STAGE_EX])) begin
            idexAluA <= 32'b0;
            idexAluB <= 32'b0;
            idexRdata <= 32'b0;
            idexIR <= 32'b0;
            idexHiWena <= 0;
            idexLoWena <= 0;
            idexRfWena <= 0;
            idexCp0Mtc0 <= 0;
            idexDivStart <= 0;
            idexDivSign <= 0;
            idexMulSign <= 0;
            idexAluCtrl <= `ALUCW'b0;
            idexDmemWena <= 0;
            idexConv1Wtype <= `WCONVW'b0;
            idexConv2Wtype <= `WCONVW'b0;
            idexConv2Sign <= 0;
            idexMuxHiSel <= `MUXW_HI'b0;
            idexMuxLoSel <= `MUXW_LO'b0;
            idexMuxDataSel <= `MUXW_DATA;
            idexMuxAddrSel <= `MUXW_ADDR;
        end
        else if (!stall[`STAGE_ID]) begin
            idexAluA <= idMuxAluAout;
            idexAluB <= idMuxAluBOut;
            idexRdata <= idRfData2;
            idexIR <= ifidIR;
            idexHiWena <= idHiWena;
            idexLoWena <= idLoWena;
            idexRfWena <= idRfWena;
            idexCp0Mtc0 <= idCp0Mtc0;
            idexDivStart <= idDivStart;
            idexDivSign <= idDivSign;
            idexMulSign <= idMulSign;
            idexAluCtrl <= idAluCtrl;
            idexDmemWena <= idDmemWena;
            idexConv1Wtype <= idConv1Wtype;
            idexConv2Wtype <= idConv2Wtype;
            idexConv2Sign <= idConv2Sign;
            idexMuxHiSel <= idMuxHiSel;
            idexMuxLoSel <= idMuxLoSel;
            idexMuxDataSel <= idMuxDataSel;
            idexMuxAddrSel <= idMuxAddrSel;
        end
    end





    // EX段
    DIVer diver(
        // ...
    );
    MULer muler(
        // ...
    );
    ALU alu(
        // ...
    );





    // EX/ME段
    always @ (posedge clk or posedge rst) begin
        if (rst || (stall[`STAGE_EX] && !stall[`STAGE_ME])) begin
            // ...
        end
        else if (!stall[`STAGE_EX]) begin
            // ...
        end
    end




    // ME段
    assign meDmemOut = iDmemData;
    assign oDmemAddr = exmeAluO;
    assign oDmemData = exmeRdata;
    assign oDmemWena = exmeDmemWena;
    assign oConv1Wtype = exmeConv1Wtype;
    assign oConv2Wtype = exmeConv2Wtype;
    assign oConv2Sign = exmeConv2Sign;




    // ME/WB段
    always @ (posedge clk or posedge rst) begin
        if (rst || (stall[`STAGE_ME] && !stall[`STAGE_WB])) begin
            // ...
        end
        else if (!stall[`STAGE_ME]) begin
            // ...
        end
    end





    // WB段
    MUX3 muxHi(
        // ...
    );
    MUX3 muxLo(
        // ...
    );
    MUX3 muxData(
        // ...
    );
    MUX3 #(
        .DATA_WIDTH(5)
    ) muxAddr(
        // ...
    );

endmodule
