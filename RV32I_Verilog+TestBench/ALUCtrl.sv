module ALUCtrl (
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [3:0] ALUCtrlOut
);
    /* verilator lint_off UNUSED */
    logic [5:0] unused_funct7 = {funct7[6],funct7[4:0]};
    /* verilator lint_on UNUSED */
    always_comb begin
        ALUCtrlOut = 4'b0000;
        case(ALUOp)
            2'b00: ALUCtrlOut = 4'b0000;
            2'b01: begin
                case(funct3)
                    3'b000: ALUCtrlOut = 4'b0001;
                    3'b100: ALUCtrlOut = 4'b1000;
                    3'b101: ALUCtrlOut = 4'b1000;
                    3'b110: ALUCtrlOut = 4'b1001;
                    3'b111: ALUCtrlOut = 4'b1001;
                    default begin
                    end
                endcase
            end
            2'b10: begin
                case(funct3)
                    3'b000: ALUCtrlOut = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                    3'b111: ALUCtrlOut = 4'b0010;
                    3'b110: ALUCtrlOut = 4'b0011;
                    3'b100: ALUCtrlOut = 4'b0100;
                    3'b001: ALUCtrlOut = 4'b0101;
                    3'b101: ALUCtrlOut = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                    3'b010: ALUCtrlOut = 4'b1000;
                    3'b011: ALUCtrlOut = 4'b1001;
                    default begin
                    end
                endcase
            end
            2'b11: begin
                case(funct3)
                    3'b000: ALUCtrlOut = 4'b0000;
                    3'b111: ALUCtrlOut = 4'b0010;
                    3'b110: ALUCtrlOut = 4'b0011;
                    3'b100: ALUCtrlOut = 4'b0100;
                    3'b001: ALUCtrlOut = 4'b0101;
                    3'b101: ALUCtrlOut = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110;
                    3'b010: ALUCtrlOut = 4'b1000;
                    3'b011: ALUCtrlOut = 4'b1001;
                    default begin
                    end
                endcase
            end
            default begin
            end
        endcase
    end
endmodule
//Good
