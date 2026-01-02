module top_module (
    input logic Rst,
    input logic Clk,
    output logic [31:0] rs1equal, rs2equal, trwd, tCurPC, twdata, tReadVal1,
    output logic commit,
    output logic [4:0] trd
);
    
    logic [31:0] tNewPC, tCurPC4, tInst, timmI, timmB, timmJ, timmU, timmS, tReadVal2, tA, tB;

    /* verilator lint_off UNOPTFLAT */
    logic [31:0] tALUOut;
    /* verilator lint_on UNOPTFLAT */

    logic [31:0] tWMemData, tDataRead, timm;
    logic [6:0] tOpCode, tfunct7;
    logic [4:0] trs1, trs2;
    logic [3:0] tALUCtrlOut, twmask;
    logic [2:0] tfunct3, timmSrc;
    logic [1:0] tResultSrc, tALUOp;
    logic tBranch, tJump, tJumpReg, tRegWrite, tMemWrite, tMemRead, tALUSrcA, tALUSrcB, tZero, tTakeBranch;

    assign rs1equal = tReadVal1;
    assign rs2equal = tReadVal2;

    always_comb begin
        timm  = 32'b0;
        tA    = 32'b0;
        tB    = 32'b0;
        twdata = 32'b0;
        case(timmSrc)
            3'b000: timm = timmI;
            3'b001: timm = timmS;
            3'b010: timm = timmB;
            3'b011: timm = timmU;
            3'b100: timm = timmJ;
            default: timm = 32'b0;
        endcase

        case(tResultSrc)
            2'b00: twdata = tALUOut;
            2'b01: twdata = tDataRead;
            2'b10: twdata = tCurPC4;
            2'b11: twdata = timm;
            default: twdata = 32'b0;
        endcase

        case(tALUSrcA)
            1'b0: tA = tReadVal1;
            1'b1: tA = tCurPC;
            default: tA = 32'b0;
        endcase

        case(tALUSrcB)
            1'b0: tB = timm;
            1'b1: tB = tReadVal2;
            default: tB = 32'b0;
        endcase

    end

    always_ff @(posedge Clk) begin
        commit  <= tRegWrite && (trd != 0);
    end

    PC32Bit Programm_Counter(
        .Clk(Clk),
        .Rst(Rst),
        .NewPC(tNewPC),

        .CurPC(tCurPC)
    );

    PCCtrl Next_PC(
        .CurPC(tCurPC),
        .immI(timmI),
        .immB(timmB),
        .immJ(timmJ),
        .ReadVal1(tReadVal1),
        .Branch(tTakeBranch),
        .Jump(tJump),
        .JumpReg(tJumpReg),

        .NewPC(tNewPC),
        .CurPC4(tCurPC4)
    );

    InstROM Instructions(
        .sel(tCurPC),

        .Inst(tInst)
    );

    Decoder1 Decode1(
        .Inst(tInst),

        .OpCode(tOpCode),
        .rd(trd),
        .funct3(tfunct3),
        .rs1(trs1),
        .rs2(trs2),
        .funct7(tfunct7),
        .immI(timmI),
        .immS(timmS),
        .immB(timmB),
        .immU(timmU),
        .immJ(timmJ)
    );

    RegisterFile RegFile(
        .Clk(Clk),
        .Rst(Rst),
        .RegWrite(tRegWrite),
        .wdata(twdata),
        .rd(trd),
        .rs1(trs1),
        .rs2(trs2),
        
        .ReadVal1(tReadVal1),
        .ReadVal2(tReadVal2),
        .regfilevalue(trwd)
    );

    CtrlUnit CtrlU(
        .OpCode(tOpCode),

        .RegWrite(tRegWrite),
        .MemWrite(tMemWrite),
        .MemRead(tMemRead),
        .Branch(tBranch),
        .Jump(tJump),
        .JumpReg(tJumpReg),
        .ALUSrcA(tALUSrcA),
        .ALUSrcB(tALUSrcB),
        .ResultSrc(tResultSrc),
        .immSrc(timmSrc),
        .ALUOp(tALUOp)
    );

    ALUCtrl ALUControl(
        .ALUOp(tALUOp),
        .funct3(tfunct3),
        .funct7(tfunct7),

        .ALUCtrlOut(tALUCtrlOut)
    );

    ALU ALU1(
        .inA(tA),
        .inB(tB),
        .ALUCtrlOut(tALUCtrlOut),

        .ALUOut(tALUOut),
        .Zero(tZero)
    );

    BranchConditionUnit BCU(
        .Zero(tZero),
        .Branch(tBranch),
        .ALUResult(tALUOut),
        .funct3(tfunct3),

        .TakeBranch(tTakeBranch)
    );

    LoadStoreUnit LSU(
        .rs(tReadVal2),
        .size(tfunct3[1:0]),
        .whichbit(tALUOut[1:0]),

        .wmask(twmask),
        .WMemData(tWMemData)
    );

    DataMemory DataMem(
        .Clk(Clk),
        .size(tfunct3[1:0]),
        .SiUned(tfunct3[2]),
        .MemWrite(tMemWrite),
        .MemRead(tMemRead),
        .WMemData(tWMemData),
        .wmask(twmask),
        .addr(tALUOut),

        .DataRead(tDataRead)
    );
endmodule
