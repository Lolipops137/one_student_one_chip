module ALU (
    input logic [31:0] inA,
    input logic [31:0] inB,
    input logic [3:0] ALUCtrlOut,

    output logic [31:0] ALUOut,
    output logic Zero
);
    logic signed [31:0] sa, sb;
    always_comb begin
        sa = $signed(inA);
        sb = $signed(inB);
        ALUOut = 0;
        case(ALUCtrlOut)
            4'b0000: ALUOut = sa + sb;
            4'b0001: ALUOut = sa - sb;
            4'b0010: ALUOut = inA & inB;
            4'b0011: ALUOut = inA | inB;
            4'b0100: ALUOut = inA ^ inB;
            4'b0101: ALUOut = inA << inB[4:0];
            4'b0110: ALUOut = inA >> inB[4:0];
            4'b0111: ALUOut = inA >>> inB[4:0];
            4'b1000: ALUOut = (sa < sb) ? 32'h1 : 32'h0;
            4'b1001: ALUOut = (inA < inB) ? 32'h1 : 32'h0;
            default begin end
        endcase
        Zero = (inA - inB == 32'h0) ? 1'b1 : 1'b0;
    end
endmodule
//Good
