////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// NOTICE!
//
// The following code/file was generated by: [ core_gen.py ]
//
// (Do not attempt to edit this file. Regenerate using above script instead.)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TYPES_VH
`define TYPES_VH

// RV32I Opcode types
`define R                   7'b0110011
`define I_JUMP              7'b1100111
`define I_LOAD              7'b0000011
`define I_ARITH             7'b0010011
`define I_SYS               7'b1110011
`define I_FENCE             7'b0001111
`define S                   7'b0100011
`define B                   7'b1100011
`define U_LUI               7'b0110111
`define U_AUIPC             7'b0010111
`define J                   7'b1101111

// Instruction fields
`define OPCODE(x)           x[6:0]
`define RD(x)               x[11:7]
`define FUNCT3(x)           x[14:12]
`define RS1(x)              x[19:15]
`define RS2(x)              x[24:20]
`define FUNCT7(x)           x[31:25]

// Forward select
`define NO_FWD              2'b00
`define FWD_MEM             2'b01
`define FWD_WB              2'b10
`define FWD_REG_RDW         2'b11   // Back-to-back regfile Read-During-Writes (RDW) hazard

// EXEC operand select
`define REG                 1'b0
`define PC                  1'b1    // Operand A
`define IMM                 1'b1    // Operand B

// Yes/No bit macros
`define Y                   1'b1
`define N                   1'b0

// ALU OP
`define ALU_OP_R            4'b0000
`define ALU_OP_I_JUMP       4'b0001
`define ALU_OP_I_LOAD       4'b0010
`define ALU_OP_I_ARITH      4'b0011
`define ALU_OP_I_SYS        4'b0100
`define ALU_OP_I_FENCE      4'b0101
`define ALU_OP_S            4'b0110
`define ALU_OP_B            4'b0111
`define ALU_OP_U_LUI        4'b1000
`define ALU_OP_U_AUIPC      4'b1001
`define ALU_OP_J            4'b1010

// ALU EXEC Types
`define OP_ADD              5'b0_0000
`define OP_PASSB            5'b0_0001
`define OP_ADD4A            5'b0_0010
`define OP_XOR              5'b0_0011
`define OP_SRL              5'b0_0100
`define OP_SRA              5'b0_0101
`define OP_OR               5'b0_0110
`define OP_AND              5'b0_0111
`define OP_SUB              5'b0_1000
`define OP_SLL              5'b0_1001
`define OP_EQ               5'b0_1010
`define OP_NEQ              5'b0_1011
`define OP_SLT              5'b0_1100
`define OP_SLTU             5'b0_1101
`define OP_SGTE             5'b0_1110
`define OP_SGTEU            5'b0_1111

// Load/Store op type
`define LS_B_OP             3'b000
`define LS_H_OP             3'b001
`define LS_W_OP             3'b010
`define LS_BU_OP            3'b100
`define LS_HU_OP            3'b101

// Opcode-type controls
//                          | ALU_OP          | EXEC_A | EXEC_B | MEM_W | REG_W | MEM2REG | BRA | JMP |
`define R_CTRL              { `ALU_OP_R,        `REG,    `REG,    `N,     `Y,     `N,       `N,   `N  }
`define I_JUMP_CTRL         { `ALU_OP_I_JUMP,   `PC,     `REG,    `N,     `Y,     `N,       `N,   `Y  }
`define I_LOAD_CTRL         { `ALU_OP_I_LOAD,   `REG,    `IMM,    `N,     `Y,     `Y,       `N,   `N  }
`define I_ARITH_CTRL        { `ALU_OP_I_ARITH,  `REG,    `IMM,    `N,     `Y,     `N,       `N,   `N  }
`define I_SYS_CTRL          { `ALU_OP_I_SYS,    `REG,    `IMM,    `N,     `N,     `N,       `N,   `N  }
`define I_FENCE_CTRL        { `ALU_OP_I_FENCE,  `REG,    `IMM,    `N,     `N,     `N,       `N,   `N  }
`define S_CTRL              { `ALU_OP_S,        `REG,    `IMM,    `Y,     `N,     `N,       `N,   `N  }
`define B_CTRL              { `ALU_OP_B,        `REG,    `REG,    `N,     `N,     `N,       `Y,   `N  }
`define U_LUI_CTRL          { `ALU_OP_U_LUI,    `REG,    `IMM,    `N,     `Y,     `N,       `N,   `N  }
`define U_AUIPC_CTRL        { `ALU_OP_U_AUIPC,  `PC,     `IMM,    `N,     `Y,     `N,       `N,   `N  }
`define J_CTRL              { `ALU_OP_J,        `PC,     `REG,    `N,     `Y,     `N,       `N,   `Y  }

`define ENDIAN_SWP_32(x)    {x[7:0],x[15:8],x[23:16],x[31:24]}
`define IS_SHIFT_IMM(x)     (~x[13] && x[12])

`endif // TYPES_VH

// ====================================================================================================================

module ImmGen (
    input       [31:0]      i_instr,
    output reg  [XLEN-1:0]  o_imm
);
    parameter XLEN = 32;

    wire isShiftImm = `IS_SHIFT_IMM(i_instr);
    always @* begin
        case (`OPCODE(i_instr))
            default  : o_imm = 32'hffffffff;
        // Immediate cases
            `I_JUMP,
            `I_LOAD  : o_imm = {{21{i_instr[31]}}, i_instr[30:20]};
            `I_ARITH : o_imm = isShiftImm ? {{27{i_instr[31]}}, i_instr[24:20]} : {{21{i_instr[31]}}, i_instr[30:20]};
            `S       : o_imm = {{21{i_instr[31]}}, i_instr[30:25], i_instr[11:8], i_instr[7]};
            `B       : o_imm = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'd0};
            `U_LUI,
            `U_AUIPC : o_imm = {i_instr[31], i_instr[30:20], i_instr[19:12], 12'd0};
            `J       : o_imm = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:25], i_instr[24:21], 1'd0};
        endcase
    end
endmodule

// ====================================================================================================================

module ControlUnit (
    input       [6:0]   i_opcode,
    output  reg [3:0]   o_aluOp,
    output  reg         o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp
);
    // Main ctrl. signals
    always @* begin
        case (i_opcode)
            // Invalid opcode - set all lines to 0
            default     : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = 11'd0;
            // Instruction formats
            `R          : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `R_CTRL;
            `I_JUMP     : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `I_JUMP_CTRL;
            `I_LOAD     : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `I_LOAD_CTRL;
            `I_ARITH    : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `I_ARITH_CTRL;
            `I_SYS      : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `I_SYS_CTRL;
            `I_FENCE    : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `I_FENCE_CTRL;
            `S          : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `S_CTRL;
            `B          : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `B_CTRL;
            `U_LUI      : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `U_LUI_CTRL;
            `U_AUIPC    : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `U_AUIPC_CTRL;
            `J          : {o_aluOp, o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp} = `J_CTRL;
        endcase
    end
endmodule

// ====================================================================================================================

module Writeback (
    input       [2:0]       i_funct3,
    input       [XLEN-1:0]  i_dataIn,
    output reg  [XLEN-1:0]  o_dataOut
);
    parameter XLEN = 32;

    // Just output load-type (w/ - w/o sign-ext) for now
    always @(*) begin
        case (i_funct3)
            `LS_B_OP    : o_dataOut = {{24{i_dataIn[31]}}, i_dataIn[7:0]};
            `LS_H_OP    : o_dataOut = {{16{i_dataIn[31]}}, i_dataIn[15:0]};
            `LS_W_OP    : o_dataOut = i_dataIn;
            `LS_BU_OP   : o_dataOut = {24'd0, i_dataIn[7:0]};
            `LS_HU_OP   : o_dataOut = {16'd0, i_dataIn[15:0]};
            default     : o_dataOut = i_dataIn;
        endcase
    end
endmodule

// ====================================================================================================================
module DualPortRam (
    input                           i_clk, i_we,
    input       [(XLEN-1):0]        i_dataIn,
    input       [(ADDR_WIDTH-1):0]  i_rAddr, i_wAddr,
    output reg  [(XLEN-1):0]        o_q
);
    parameter XLEN = 32;
    parameter ADDR_WIDTH = 5;
    reg [XLEN-1:0] ram [2**ADDR_WIDTH-1:0];

    integer i;
    initial begin
        for (i=0; i<(2**ADDR_WIDTH-1); i=i+1) begin
            ram[i] = {XLEN{1'b0}};
        end
    end

    always @ (posedge i_clk) begin
        if (i_we) begin
            ram[i_wAddr] <= i_dataIn;
        end
        o_q <= ram[i_rAddr];
    end
endmodule

// ====================================================================================================================

module boredcore (
    input                       i_clk, i_rst, i_ifValid, i_memValid,
    input   [INSTR_WIDTH-1:0]   i_instr,
    input          [XLEN-1:0]   i_dataIn,
    output                      o_storeReq, o_loadReq,
    output         [XLEN-1:0]   o_pcOut, o_dataAddr, o_dataOut
);
    // CPU configs
    parameter         PC_START              = 0;
    parameter         REGFILE_ADDR_WIDTH    = 5;    //  4 for RV32E (otherwise 5)
    parameter         INSTR_WIDTH           = 32;   // 16 for RV32C (otherwise 32)
    parameter         XLEN                  = 32;
    // Helper Aliases
    localparam  [4:0] REG_0                 = 5'b00000; // Register x0
    // Init values
    initial begin
        PC = PC_START;
    end

    // Pipeline regs (p_*)
    localparam  EXEC = 0;
    localparam  MEM  = 1;
    localparam  WB   = 2;
    reg [XLEN-1:0]  p_rs1       [EXEC:WB];
    reg [XLEN-1:0]  p_rs2       [EXEC:WB];
    reg [XLEN-1:0]  p_aluOut    [EXEC:WB];
    reg [XLEN-1:0]  p_readData  [EXEC:WB];
    reg [XLEN-1:0]  p_PC        [EXEC:WB];
    reg [XLEN-1:0]  p_IMM       [EXEC:WB];
    reg      [6:0]  p_funct7    [EXEC:WB];
    reg      [4:0]  p_rs1Addr   [EXEC:WB];
    reg      [4:0]  p_rs2Addr   [EXEC:WB];
    reg      [4:0]  p_rdAddr    [EXEC:WB];
    reg      [3:0]  p_aluOp     [EXEC:WB];
    reg      [2:0]  p_funct3    [EXEC:WB];
    reg             p_mem_w     [EXEC:WB];
    reg             p_reg_w     [EXEC:WB];
    reg             p_mem2reg   [EXEC:WB];
    reg             p_exec_a    [EXEC:WB];
    reg             p_exec_b    [EXEC:WB];
    reg             p_bra       [EXEC:WB];
    reg             p_jmp       [EXEC:WB];
    // Internal wires/regs
    reg  [XLEN-1:0] PC, PCReg, instrReg;
    wire [XLEN-1:0] IMM, aluOut, jumpAddr, loadData, rs1Out, rs2Out, rdDataSave, rs2FwdOut;
    wire      [3:0] aluOp;
    wire            exec_a, exec_b, mem_w, reg_w, mem2reg, bra, jmp, fwdRdwRs1, fwdRdwRs2;
    wire [XLEN-1:0] WB_result       = p_mem2reg[WB] ? loadData : p_aluOut[WB];
    wire            braMispredict   = p_bra[EXEC] && aluOut[0];                 // Assume branch not-taken
    wire            writeRd         = `RD(instrReg) != REG_0 ? reg_w : 1'b0;    // Skip regfile write for x0
    wire            pcJump          = braMispredict || p_jmp[EXEC];
    //          (Forwarding logic)
    wire            RS1_fwd_mem     = p_reg_w[MEM] && (p_rs1Addr[EXEC] == p_rdAddr[MEM]);
    wire            RS1_fwd_wb      = ~RS1_fwd_mem && p_reg_w[WB] && (p_rs1Addr[EXEC] == p_rdAddr[WB]);
    wire            RS1_fwd_reg_rdw = ~RS1_fwd_wb  && fwdRdwRs1;
    wire            RS2_fwd_mem     = p_reg_w[MEM] && (p_rs2Addr[EXEC] == p_rdAddr[MEM]);
    wire            RS2_fwd_wb      = ~RS2_fwd_mem && p_reg_w[WB] && (p_rs2Addr[EXEC] == p_rdAddr[WB]);
    wire            RS2_fwd_reg_rdw = ~RS2_fwd_wb  && fwdRdwRs2;
    wire      [1:0] fwdRs1          = RS1_fwd_reg_rdw ? `FWD_REG_RDW : {RS1_fwd_wb, RS1_fwd_mem},
                    fwdRs2          = RS2_fwd_reg_rdw ? `FWD_REG_RDW : {RS2_fwd_wb, RS2_fwd_mem};
    //          (Stall and flush logic)
    wire            load_hazard     = p_mem2reg[EXEC] && (
                                        (`RS1(instrReg) == p_rdAddr[EXEC]) || (`RS2(instrReg) == p_rdAddr[EXEC])
                                    );
    wire            load_wait       = o_loadReq && ~i_memValid;
    wire            FETCH_stall     = ~i_ifValid || EXEC_stall || MEM_stall || load_hazard;
    wire            EXEC_stall      = MEM_stall;
    wire            MEM_stall       = load_wait;
    wire            FETCH_flush     = i_rst || braMispredict || p_jmp[EXEC];
    wire            EXEC_flush      = i_rst || braMispredict || p_jmp[EXEC] || load_hazard /* bubble */;
    wire            MEM_flush       = i_rst;
    wire            WB_flush        = i_rst || load_wait /* bubble */;

    // Core submodules
    FetchDecode #(.XLEN(XLEN)) FETCH_DECODE_unit(
        .i_instr              (instrReg),
        .o_imm                (IMM),
        .o_aluOp              (aluOp),
        .o_exec_a             (exec_a),
        .o_exec_b             (exec_b),
        .o_mem_w              (mem_w),
        .o_reg_w              (reg_w),
        .o_mem2reg            (mem2reg),
        .o_bra                (bra),
        .o_jmp                (jmp)
    );
    Execute #(.XLEN(XLEN)) EXECUTE_unit (
        .i_funct7             (p_funct7[EXEC]),
        .i_funct3             (p_funct3[EXEC]),
        .i_aluOp              (p_aluOp[EXEC]),
        .i_fwdRs1             (fwdRs1),
        .i_fwdRs2             (fwdRs2),
        .i_aluSrcA            (p_exec_a[EXEC]),
        .i_aluSrcB            (p_exec_b[EXEC]),
        .i_EXEC_rs1           (p_rs1[EXEC]),
        .i_EXEC_rs2           (p_rs2[EXEC]),
        .i_MEM_rd             (p_aluOut[MEM]),
        .i_WB_rd              (WB_result),
        .i_rdDataSave         (rdDataSave),
        .i_PC                 (p_PC[EXEC]),
        .i_IMM                (p_IMM[EXEC]),
        .o_aluOut             (aluOut),
        .o_addrGenOut         (jumpAddr),
        .o_rs2FwdOut          (rs2FwdOut)
    );
    Memory #(.XLEN(XLEN)) MEMORY_unit(
        .i_funct3             (p_funct3[MEM]),
        .i_dataIn             (p_rs2[MEM]),
        .o_dataOut            (o_dataOut)
    );
    Writeback #(.XLEN(XLEN)) WRITEBACK_unit(
        .i_funct3             (p_funct3[WB]),
        .i_dataIn             (p_readData[WB]),
        .o_dataOut            (loadData)
    );
    Regfile #(.XLEN(XLEN), .ADDR_WIDTH(REGFILE_ADDR_WIDTH)) REGFILE_unit (
        .i_clk          (i_clk),
        .i_wrEn         (p_reg_w[WB]),
        .i_rs1Addr      (`RS1(i_instr)),
        .i_rs2Addr      (`RS2(i_instr)),
        .i_rdAddr       (p_rdAddr[WB]),
        .i_rdData       (WB_result),
        .o_rs1Data      (rs1Out),
        .o_rs2Data      (rs2Out),
        .o_rdDataSave   (rdDataSave),
        .o_fwdRdwRs1    (fwdRdwRs1),
        .o_fwdRdwRs2    (fwdRdwRs2)
    );

    // Pipeline CTRL reg assignments
    always @(posedge i_clk) begin
        // --- Execute ---
        p_aluOp    [EXEC]  <= EXEC_flush ? 4'd0 : EXEC_stall ? p_aluOp   [EXEC] : aluOp;
        p_mem_w    [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_mem_w   [EXEC] : mem_w;
        p_reg_w    [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_reg_w   [EXEC] : writeRd;
        p_mem2reg  [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_mem2reg [EXEC] : mem2reg;
        p_exec_a   [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_exec_a  [EXEC] : exec_a;
        p_exec_b   [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_exec_b  [EXEC] : exec_b;
        p_bra      [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_bra     [EXEC] : bra;
        p_jmp      [EXEC]  <= EXEC_flush ? 1'd0 : EXEC_stall ? p_jmp     [EXEC] : jmp;
        // --- Memory ---
        p_mem_w    [MEM]   <= MEM_flush ? 1'd0 : MEM_stall ? p_mem_w    [MEM] : p_mem_w   [EXEC];
        p_reg_w    [MEM]   <= MEM_flush ? 1'd0 : MEM_stall ? p_reg_w    [MEM] : p_reg_w   [EXEC];
        p_mem2reg  [MEM]   <= MEM_flush ? 1'd0 : MEM_stall ? p_mem2reg  [MEM] : p_mem2reg [EXEC];
        // --- Writeback ---
        p_reg_w    [WB]    <= WB_flush ? 1'd0 : p_reg_w   [MEM];
        p_mem2reg  [WB]    <= WB_flush ? 1'd0 : p_mem2reg [MEM];
    end
    // Pipeline DATA reg assignments
    always @(posedge i_clk) begin
        // --- Execute ---
        p_rs1      [EXEC]  <= EXEC_stall ? p_rs1     [EXEC] : rs1Out;
        p_rs2      [EXEC]  <= EXEC_stall ? p_rs2     [EXEC] : rs2Out;
        p_IMM      [EXEC]  <= EXEC_stall ? p_IMM     [EXEC] : IMM;
        p_PC       [EXEC]  <= EXEC_stall ? p_PC      [EXEC] : PCReg;
        p_funct7   [EXEC]  <= EXEC_stall ? p_funct7  [EXEC] : `FUNCT7(instrReg);
        p_funct3   [EXEC]  <= EXEC_stall ? p_funct3  [EXEC] : `FUNCT3(instrReg);
        p_rs1Addr  [EXEC]  <= EXEC_stall ? p_rs1Addr [EXEC] : `RS1(instrReg);
        p_rs2Addr  [EXEC]  <= EXEC_stall ? p_rs2Addr [EXEC] : `RS2(instrReg);
        p_rdAddr   [EXEC]  <= EXEC_stall ? p_rdAddr  [EXEC] : `RD(instrReg);
        // --- Memory ---
        p_rs2      [MEM]   <= MEM_stall ? p_rs2    [MEM] : rs2FwdOut;
        p_rdAddr   [MEM]   <= MEM_stall ? p_rdAddr [MEM] : p_rdAddr  [EXEC];
        p_funct3   [MEM]   <= MEM_stall ? p_funct3 [MEM] : p_funct3  [EXEC];
        p_aluOut   [MEM]   <= MEM_stall ? p_aluOut [MEM] : aluOut;
        // --- Writeback ---
        p_aluOut   [WB]    <= p_aluOut  [MEM];
        p_rdAddr   [WB]    <= p_rdAddr  [MEM];
        p_funct3   [WB]    <= p_funct3  [MEM];
        p_readData [WB]    <= i_dataIn;
    end

    // Fetch/Decode reg assignments
    always @(posedge i_clk) begin
        PC          <=  i_rst       ?   {(XLEN){1'b0}}  :
                        FETCH_stall ?   PC              :
                        pcJump      ?   jumpAddr        :
                                        PC + 32'd4;
        // Buffer PC reg to balance the 1cc BRAM-based regfile read
        PCReg       <=  FETCH_flush ?   {(XLEN){1'b0}}  :
                        FETCH_stall ?   PCReg           :
                                        PC;
        // Buffer instruction fetch to balance the 1cc BRAM-based regfile read
        instrReg    <=  FETCH_flush ?   {(XLEN){1'b0}}  :
                        FETCH_stall ?   instrReg        :
                                        i_instr;
    end

    // CPU outputs
    assign o_pcOut      = PC;
    assign o_dataAddr   = p_aluOut[MEM];
    assign o_storeReq   = p_mem_w[MEM];
    assign o_loadReq    = p_mem2reg[MEM];

endmodule

// ====================================================================================================================

module Regfile (
    input                       i_clk, i_wrEn,
    input   [(ADDR_WIDTH-1):0]  i_rs1Addr, i_rs2Addr, i_rdAddr,
    input   [(XLEN-1):0]        i_rdData,
    output  [(XLEN-1):0]        o_rs1Data, o_rs2Data, o_rdDataSave,
    output                      o_fwdRdwRs1, o_fwdRdwRs2
);
    parameter XLEN          = 32;
    parameter ADDR_WIDTH    = 5;

    // Need to forward when accessing new value as it is being written to in Regfile (Read-During-Write (RDW))
    reg                 r_fwdRs1En, r_fwdRs2En, r_fwdRs1En2, r_fwdRs2En2;
    reg  [(XLEN-1):0]   r_rdDataSave;
    wire [(XLEN-1):0]   w_rs1PortOut, w_rs2PortOut;

    /*
        NOTE:   Infer 2 copied/synced 32x32 (2048 KBits) BRAMs (i.e. one BRAM per read-port)
                rather than just 1 32x32 (1024 KBits) BRAM. This is somewhat wasteful but is
                simpler. Alternate approach is to have the 2 "banks" configured as 2 32x16
                BRAMs w/ additional banking logic for wr_en and output forwarding
                (no duplication with this approach but adds some more Tpcq at the output).
    */
    DualPortRam #(
        .XLEN(XLEN),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) RS1_PORT (
        .i_clk                (i_clk),
        .i_we                 (i_wrEn),
        .i_dataIn             (i_rdData),
        .i_rAddr              (i_rs1Addr),
        .i_wAddr              (i_rdAddr),
        .o_q                  (w_rs1PortOut)
    );
    DualPortRam #(
        .XLEN(XLEN),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) RS2_PORT (
        .i_clk                (i_clk),
        .i_we                 (i_wrEn),
        .i_dataIn             (i_rdData),
        .i_rAddr              (i_rs2Addr),
        .i_wAddr              (i_rdAddr),
        .o_q                  (w_rs2PortOut)
    );

    always @(posedge i_clk) begin
        r_fwdRs1En      <= (i_rs1Addr == i_rdAddr) && i_wrEn;
        r_fwdRs1En2     <= r_fwdRs1En;
        r_fwdRs2En      <= (i_rs2Addr == i_rdAddr) && i_wrEn;
        r_fwdRs2En2     <= r_fwdRs2En;
        r_rdDataSave    <= i_rdData;
    end
    assign o_rs1Data    = r_fwdRs1En ? r_rdDataSave : w_rs1PortOut;
    assign o_rs2Data    = r_fwdRs2En ? r_rdDataSave : w_rs2PortOut;

    /*
        NOTE:   We need to also output these regfile forwarding bits/data to CPU forwarding logic
                in EXEC stage to resolve another hazard of back-to-back Read-During-Write (RDW) accesses
    */
    assign o_rdDataSave = r_rdDataSave;
    assign o_fwdRdwRs1  = r_fwdRs1En && r_fwdRs1En2;
    assign o_fwdRdwRs2  = r_fwdRs2En && r_fwdRs2En2;

endmodule

// ====================================================================================================================

module ALU (
  input         [XLEN-1:0]          i_a, i_b,
  input         [ALU_OP_WIDTH-1:0]  i_op,
  output reg    [XLEN-1:0]          o_result
);
    parameter   XLEN            = 32;
    localparam  ALU_OP_WIDTH    = 5;

    reg  [XLEN-1:0] B_in;
    reg             ALU_SLT;
    reg             SUB;
    wire            cflag; // Catch unsigned overflow for SLTU/SGTEU cases
    wire [XLEN-1:0] ALU_ADDER_result;
    wire [XLEN-1:0] ALU_XOR_result  = i_a ^ i_b;
    wire [XLEN-1:0] CONST_4         = {{(XLEN-3){1'b0}}, 3'd4};

    // Add/Sub logic
    assign {cflag, ALU_ADDER_result[XLEN-1:0]} = i_a + B_in + {{(XLEN){1'b0}}, SUB};

    always @(*) begin
        // --- ALU internal op setup ---
        case (i_op)
            `OP_SUB,
            `OP_SLT,
            `OP_SLTU,
            `OP_SGTE,
            `OP_SGTEU   : begin B_in = ~i_b; SUB = 1;       end
            `OP_ADD4A   : begin B_in = CONST_4; SUB = 0;    end
            default     : begin B_in = i_b; SUB = 0;        end
        endcase
        // --- SLT setup ---
        case ({i_a[XLEN-1], i_b[XLEN-1]})
            2'b00       : ALU_SLT = ALU_ADDER_result[31];
            2'b01       : ALU_SLT = 1'b0; // a > b since a is pos.
            2'b10       : ALU_SLT = 1'b1; // a < b since a is neg.
            2'b11       : ALU_SLT = ALU_ADDER_result[31];
        endcase
        // --- Main operations ---
        case (i_op)
            default     : o_result = ALU_ADDER_result;
            `OP_ADD     : o_result = ALU_ADDER_result;
            `OP_SUB     : o_result = ALU_ADDER_result;
            `OP_AND     : o_result = i_a & i_b;
            `OP_OR      : o_result = i_a | i_b;
            `OP_XOR     : o_result = ALU_XOR_result;
            `OP_SLL     : o_result = i_a << i_b;
            `OP_SRL     : o_result = i_a >> i_b;
            `OP_SRA     : o_result = $signed(i_a) >>> i_b;
            `OP_PASSB   : o_result = i_b;
            `OP_ADD4A   : o_result = ALU_ADDER_result;
            `OP_EQ      : o_result = {31'd0, ~|ALU_XOR_result};
            `OP_NEQ     : o_result = {31'd0, ~(~|ALU_XOR_result)};
            `OP_SLT     : o_result = {31'd0,  ALU_SLT};
            `OP_SGTE    : o_result = {31'd0, ~ALU_SLT};
            `OP_SLTU    : o_result = {31'd0, ~cflag};
            `OP_SGTEU   : o_result = {31'd0,  cflag};
        endcase
    end
endmodule

// ====================================================================================================================

module Memory (
    input       [2:0]       i_funct3,
    input       [XLEN-1:0]  i_dataIn,
    output reg  [XLEN-1:0]  o_dataOut
);
    parameter XLEN = 32;

    // Just output store-type (w/ - w/o sign-ext) for now
    always @(*) begin
        case (i_funct3)
            `LS_B_OP    : o_dataOut = {{24{i_dataIn[31]}}, i_dataIn[7:0]};
            `LS_H_OP    : o_dataOut = {{16{i_dataIn[31]}}, i_dataIn[15:0]};
            `LS_W_OP    : o_dataOut = i_dataIn;
            `LS_BU_OP   : o_dataOut = {24'd0, i_dataIn[7:0]};
            `LS_HU_OP   : o_dataOut = {16'd0, i_dataIn[15:0]};
            default     : o_dataOut = i_dataIn;
        endcase
    end
endmodule

// ====================================================================================================================

module FetchDecode (
    input   [31:0]      i_instr,
    output  [XLEN-1:0]  o_imm,
    output  [3:0]       o_aluOp,
    output              o_exec_a, o_exec_b, o_mem_w, o_reg_w, o_mem2reg, o_bra, o_jmp
);
    parameter XLEN = 32;

    ImmGen #(.XLEN(XLEN)) IMMGEN_unit(
        .i_instr    (i_instr),
        .o_imm      (o_imm)
    );
    ControlUnit CTRL_unit(
        .i_opcode   (`OPCODE(i_instr)),
        .o_aluOp    (o_aluOp),
        .o_exec_a   (o_exec_a),
        .o_exec_b   (o_exec_b),
        .o_mem_w    (o_mem_w),
        .o_reg_w    (o_reg_w),
        .o_mem2reg  (o_mem2reg),
        .o_bra      (o_bra),
        .o_jmp      (o_jmp)
    );
endmodule

// ====================================================================================================================

module Execute (
    input   [6:0]   i_funct7,
    input   [2:0]   i_funct3,
    input   [3:0]   i_aluOp,
    input   [1:0]   i_fwdRs1, i_fwdRs2,
    input           i_aluSrcA, i_aluSrcB,
    input   [31:0]  i_EXEC_rs1, i_EXEC_rs2, i_MEM_rd, i_WB_rd, i_rdDataSave,
    input   [31:0]  i_PC, i_IMM,
    output  [31:0]  o_aluOut, o_addrGenOut, o_rs2FwdOut
);
    parameter XLEN = 32;

    // Datapath for register forwarding
    reg [31:0] rs1Out, rs2Out;
    always@(*) begin
        case (i_fwdRs1)
            `NO_FWD         : rs1Out = i_EXEC_rs1;
            `FWD_MEM        : rs1Out = i_MEM_rd;
            `FWD_WB         : rs1Out = i_WB_rd;
            `FWD_REG_RDW    : rs1Out = i_rdDataSave;
            default         : rs1Out = i_EXEC_rs1;
        endcase
        case (i_fwdRs2)
            `NO_FWD         : rs2Out = i_EXEC_rs2;
            `FWD_MEM        : rs2Out = i_MEM_rd;
            `FWD_WB         : rs2Out = i_WB_rd;
            `FWD_REG_RDW    : rs2Out = i_rdDataSave;
            default         : rs2Out = i_EXEC_rs2;
        endcase
    end

    // Datapath for ALU srcs
    wire [31:0] aluSrcAin = (i_aluSrcA == `PC ) ? i_PC  : rs1Out;
    wire [31:0] aluSrcBin = (i_aluSrcB == `IMM) ? i_IMM : rs2Out;

    // ALU/ALU_Control
    wire [4:0]  aluControl;
    ALU_Control ALU_CTRL_unit (
        .i_aluOp        (i_aluOp),
        .i_funct7       (i_funct7),
        .i_funct3       (i_funct3),
        .o_aluControl   (aluControl)
    );
    ALU #(.XLEN(XLEN)) alu_unit (
        .i_a      (aluSrcAin),
        .i_b      (aluSrcBin),
        .i_op     (aluControl),
        .o_result (o_aluOut)
    );

    assign o_addrGenOut = i_PC + i_IMM;
    assign o_rs2FwdOut  = rs2Out;

endmodule

// ====================================================================================================================

module ALU_Control (
    input       [3:0] i_aluOp,
    input       [6:0] i_funct7,
    input       [2:0] i_funct3,
    output reg  [4:0] o_aluControl
);
    localparam SRAI = 5;
    always @* begin
        case (i_aluOp)
            // ~~~ U/J-Type formats ~~~
            `ALU_OP_J           : o_aluControl = `OP_ADD4A;
            `ALU_OP_U_LUI       : o_aluControl = `OP_PASSB;
            `ALU_OP_U_AUIPC     : o_aluControl = `OP_ADD;
            // ~~~ I/S/B-Type formats ~~~
            `ALU_OP_S           : o_aluControl = `OP_ADD;
            `ALU_OP_I_SYS       : o_aluControl = `OP_ADD;
            `ALU_OP_I_LOAD      : o_aluControl = `OP_ADD;
            `ALU_OP_I_JUMP      : o_aluControl = `OP_ADD4A;
            `ALU_OP_I_FENCE     : o_aluControl = `OP_ADD;
            `ALU_OP_B           : case (i_funct3)
                3'b000          : o_aluControl = `OP_EQ;
                3'b001          : o_aluControl = `OP_NEQ;
                3'b100          : o_aluControl = `OP_SLT;
                3'b101          : o_aluControl = `OP_SGTE;
                3'b110          : o_aluControl = `OP_SLTU;
                3'b111          : o_aluControl = `OP_SGTEU;
                default         : o_aluControl = 5'b00000;
            endcase
            `ALU_OP_I_ARITH     : case (i_funct3)
                3'b000          : o_aluControl = `OP_ADD;
                3'b010          : o_aluControl = `OP_SLT;
                3'b011          : o_aluControl = `OP_SLTU;
                3'b100          : o_aluControl = `OP_XOR;
                3'b110          : o_aluControl = `OP_OR;
                3'b111          : o_aluControl = `OP_AND;
                3'b001          : o_aluControl = `OP_SLL;
                3'b101          : o_aluControl =  i_funct7[SRAI] ? `OP_SRA : `OP_SRL;
                default         : o_aluControl = 5'b00000;
            endcase
            // ~~~ R-Type format ~~~
            default             : case ({i_funct7, i_funct3})
                10'b0000000_000 : o_aluControl = `OP_ADD;
                10'b0100000_000 : o_aluControl = `OP_SUB;
                10'b0000000_001 : o_aluControl = `OP_SLL;
                10'b0000000_010 : o_aluControl = `OP_SLT;
                10'b0000000_011 : o_aluControl = `OP_SLTU;
                10'b0000000_100 : o_aluControl = `OP_XOR;
                10'b0000000_101 : o_aluControl = `OP_SRL;
                10'b0100000_101 : o_aluControl = `OP_SRA;
                10'b0000000_110 : o_aluControl = `OP_OR;
                10'b0000000_111 : o_aluControl = `OP_AND;
                default         : o_aluControl = 5'b00000;
            endcase
        endcase
    end
endmodule

// ====================================================================================================================

// Core Config:
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     ISA config           : rv32i
//     Interface protocol   : none
//     PC start value       : 0x0
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module CPU (
    input i_clk,
    input i_rst,
    input i_ifValid,
    input i_memValid,
    input [31:0] i_instr,
    input [31:0] i_dataIn,
    output o_storeReq,
    output o_loadReq,
    output [31:0] o_pcOut,
    output [31:0] o_dataAddr,
    output [31:0] o_dataOut
);
    // Instantiate and configure CPU
    boredcore #(
        .PC_START           (0),
        .REGFILE_ADDR_WIDTH (5),
        .INSTR_WIDTH        (32),
        .XLEN               (32)
    ) boredcore_unit (
        .i_clk              (i_clk     ),
        .i_rst              (i_rst     ),
        .i_ifValid          (i_ifValid ),
        .i_memValid         (i_memValid),
        .i_instr            (i_instr   ),
        .i_dataIn           (i_dataIn  ),
        .o_storeReq         (o_storeReq),
        .o_loadReq          (o_loadReq ),
        .o_pcOut            (o_pcOut   ),
        .o_dataAddr         (o_dataAddr),
        .o_dataOut          (o_dataOut )
    );
endmodule
