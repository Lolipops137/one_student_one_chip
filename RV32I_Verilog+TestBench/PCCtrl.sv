module PCCtrl (
    input logic [31:0] CurPC, immB, immJ, immI, ReadVal1,
    input logic Branch, Jump, JumpReg,

    output logic [31:0] CurPC4, NewPC
);
    logic [1:0] sel;
    always_comb begin
        if (JumpReg)
            sel = 2'b11;
        else if (Jump)
            sel = 2'b10;
        else if (Branch)
            sel = 2'b01;
        else
            sel = 2'b00;

        case(sel)
            2'b00: NewPC = CurPC + 32'h4;
            2'b01: NewPC = CurPC + (immB);
            2'b10: NewPC = CurPC + (immJ);
            2'b11: NewPC = (ReadVal1) + (immI);
            default begin end
        endcase
        CurPC4 = CurPC + 32'h4;
    end
endmodule
//Good
