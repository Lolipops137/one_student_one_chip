module BranchConditionUnit (
    input logic Zero, Branch,
    input logic [31:0] ALUResult,
    input logic [2:0] funct3,

    output logic TakeBranch
);
    /* verilator lint_off UNUSED */
    logic [30:0] unused_ALUR = ALUResult[31:1];
    /* verilator lint_on UNUSED */
    always_comb begin
        TakeBranch = Zero;
        case(funct3)
            3'b000: TakeBranch = Zero & Branch;
            3'b001: TakeBranch = ~Zero & Branch;
            3'b100: TakeBranch = ALUResult[0] & Branch;
            3'b101: TakeBranch = ~ALUResult[0] & Branch;
            3'b110: TakeBranch = ALUResult[0] & Branch;
            3'b111: TakeBranch = ~ALUResult[0] & Branch;
            default begin end
        endcase
    end
endmodule
//Good
