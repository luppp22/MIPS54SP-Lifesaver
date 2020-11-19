//----------Instruction----------

`define INSTR_INDEX         25:0
`define INSTR_OFFSET        15:0
`define INSTR_IMM           15:0
`define INSTR_RS            25:21
`define INSTR_RT            20:16
`define INSTR_RD            15:11
`define INSTR_SA            10:6

//----------Operation----------

`define OP_ADDI             6'b001000
`define OP_ADDIU            6'b001001
`define OP_ANDI             6'b001100
`define OP_BEQ              6'b000100
`define OP_BNE              6'b000101
`define OP_COP0             6'b010000
`define OP_J                6'b000010
`define OP_JAL              6'b000011
`define OP_LUI              6'b001111
`define OP_LB               6'b100000
`define OP_LBU              6'b100100
`define OP_LH               6'b100001
`define OP_LHU              6'b100101
`define OP_LW               6'b100011
`define OP_ORI              6'b001101
`define OP_REGIMM           6'b000001
`define OP_SLTI             6'b001010
`define OP_SLTIU            6'b001011
`define OP_SPECIAL          6'b000000
`define OP_SPECIAL2         6'b011100
`define OP_SB               6'b101000
`define OP_SH               6'b101001
`define OP_SW               6'b101011
`define OP_XORI             6'b001110

`define FUNCT_ADD           6'b100000
`define FUNCT_ADDU          6'b100001
`define FUNCT_AND           6'b100100
`define FUNCT_BREAK         6'b001101
`define FUNCT_CLZ           6'b100000
`define FUNCT_DIV           6'b011010
`define FUNCT_DIVU          6'b011011
`define FUNCT_ERET          6'b011000
`define FUNCT_JALR          6'b001001
`define FUNCT_JR            6'b001000
`define FUNCT_MFHI          6'b010000
`define FUNCT_MFLO          6'b010010
`define FUNCT_MTHI          6'b010001
`define FUNCT_MTLO          6'b010011
`define FUNCT_MUL           6'b000010
`define FUNCT_MULTU         6'b011001
`define FUNCT_NOR           6'b100111
`define FUNCT_OR            6'b100101
`define FUNCT_SLL           6'b000000
`define FUNCT_SLLV          6'b000100
`define FUNCT_SLT           6'b101010
`define FUNCT_SLTU          6'b101011
`define FUNCT_SRA           6'b000011
`define FUNCT_SRAV          6'b000111
`define FUNCT_SRL           6'b000010
`define FUNCT_SRLV          6'b000110
`define FUNCT_SUB           6'b100010
`define FUNCT_SUBU          6'b100011
`define FUNCT_SYSCALL       6'b001100
`define FUNCT_TEQ           6'b110100
`define FUNCT_XOR           6'b100110

`define RS_MF               5'b00000
`define RS_MT               5'b00100
`define RT_BGEZ             5'b00001

//----------ALU----------

`define ALUCW               5   //control signal width

`define ALU_OP_NOP          5'b00000
`define ALU_OP_ADDU         5'b00001
`define ALU_OP_ADD          5'b00010
`define ALU_OP_SUBU         5'b00011
`define ALU_OP_SUB          5'b00100
`define ALU_OP_AND          5'b00101
`define ALU_OP_OR           5'b00110
`define ALU_OP_XOR          5'b00111
`define ALU_OP_NOR          5'b01000
`define ALU_OP_LUI          5'b01001
`define ALU_OP_SLT          5'b01010
`define ALU_OP_SLTU         5'b01011
`define ALU_OP_SRA          5'b01100
`define ALU_OP_SLL_SLA      5'b01101
`define ALU_OP_SRL          5'b01110
`define ALU_OP_CLZ          5'b01111
`define ALU_OP_PASSA        5'b10000
`define ALU_OP_PASSB        5'b10001

//----------CP0----------

`define CP0_CAUSE_SYSCALL   32'b1000
`define CP0_CAUSE_BREAK     32'b1001
`define CP0_CAUSE_TEQ       32'b1101

`define CP0_STATUS_ADDR     12
`define CP0_CAUSE_ADDR      13
`define CP0_EPC_ADDR        14

`define CP0_SYSCALL_POS     1
`define CP0_BREAK_POS       2
`define CP0_TEQ_POS         3

`define CP0_STATUS_INIT     32'b1111

//----------WidthConv----------

`define WCONVW              2
`define WCONV_WORD          2'b00
`define WCONV_HALF          2'b01
`define WCONV_BYTE          2'b10

//----------MUX----------

`define MUXW_PC             5
`define MUXW_ALUA           6
`define MUXW_ALUB           3
`define MUXW_HI             3
`define MUXW_LO             3
`define MUXW_DATA           3
`define MUXW_ADDR           3

`define MUX_PC_NPC          5'b00001
`define MUX_PC_JUMP         5'b00010
`define MUX_PC_BRANCH       5'b00100
`define MUX_PC_JREG         5'b01000
`define MUX_PC_EPC          5'b10000

`define MUX_ALUA_HI         6'b000001
`define MUX_ALUA_LO         6'b000010
`define MUX_ALUA_CP0        6'b000100
`define MUX_ALUA_NPC        6'b001000
`define MUX_ALUA_RS         6'b010000
`define MUX_ALUA_EXT5       6'b100000

`define MUX_ALUB_RT         3'b001
`define MUX_ALUB_EXT16      3'b010
`define MUX_ALUB_4          3'b100

`define MUX_HI_R            3'b001
`define MUX_HI_Z            3'b010
`define MUX_HI_ALU          3'b100

`define MUX_LO_Q            3'b001
`define MUX_LO_Z            3'b010
`define MUX_LO_ALU          3'b100

`define MUX_DATA_Z          3'b001
`define MUX_DATA_ALU        3'b010
`define MUX_DATA_MD         3'b100

`define MUX_ADDR_RT         3'b001
`define MUX_ADDR_RD         3'b010
`define MUX_ADDR_31         3'b100


//----------CtrlUnit----------

`define CTRL_STALLW         5
`define CTRL_STALL_ID       5'b00011
`define CTRL_STALL_EX       5'b00111
`define CTRL_STALL_ALL      5'b11111

//----------Others----------

`define STAGE_IF            0
`define STAGE_ID            1
`define STAGE_EX            2
`define STAGE_ME            3
`define STAGE_WB            4