module Decoder1 (
    input logic [31:0] Inst,

    output logic [6:0] OpCode,
    output logic [4:0] rd,
    output logic [2:0] funct3,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [6:0] funct7,

    output logic [31:0] immI,
    output logic [31:0] immS,
    output logic [31:0] immB,
    output logic [31:0] immU,
    output logic [31:0] immJ
);
    assign OpCode = Inst[6:0];
    assign rd = Inst[11:7];
    assign funct3 = Inst[14:12];
    assign rs1 = Inst[19:15];
    assign rs2 = Inst[24:20];
    assign funct7 = Inst[31:25];

    assign immI = {{20{Inst[31]}}, Inst[31:20]};
    assign immS = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
    assign immB = {{19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0};
    assign immU = {Inst[31:12], {12{1'b0}}};
    assign immJ = {{11{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0};

endmodule
//Good
