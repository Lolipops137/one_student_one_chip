module CtrlUnit (
    input logic [6:0] OpCode,

    output logic RegWrite, MemRead, MemWrite, Branch, Jump, JumpReg, ALUSrcA, ALUSrcB,
    output logic [1:0] ResultSrc, ALUOp,
    output logic [2:0] immSrc
);
    
    always_comb begin
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Jump = 1'b0;
        JumpReg = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 1'b0;
        ResultSrc = 2'b00; 
        ALUOp = 2'b00;
        immSrc = 3'b000;

        case(OpCode)
            7'h33: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ALUOp = 2'b10;
            end
            7'h13: begin
                RegWrite = 1'b1;
                ALUOp = 2'b11;
            end
            7'h03: begin
                RegWrite = 1'b1;
                MemRead = 1'b1;
                ResultSrc = 2'b01;
            end
            7'h23: begin
                MemWrite = 1'b1;
                immSrc = 3'b001;
            end
            7'h63: begin
                Branch = 1'b1;
                ALUSrcB = 1'b1;
                ALUOp = 2'b01;
                immSrc = 3'b010;
            end
            7'h6f: begin
                RegWrite = 1'b1;
                Jump = 1'b1;
                ALUSrcA = 1'b1;
                ResultSrc = 2'b10;
                immSrc = 3'b100;
            end
            7'h67: begin
                RegWrite = 1'b1;
                JumpReg = 1'b1;
                ResultSrc = 2'b10;
            end
            7'h37: begin
                RegWrite = 1'b1;
                ResultSrc = 2'b11;
                immSrc = 3'b011;
            end
            7'h17: begin
                RegWrite = 1'b1;
                ALUSrcA = 1'b1;
                immSrc = 3'b011;
            end
            default begin
            end
        endcase
    end
endmodule
//Good
