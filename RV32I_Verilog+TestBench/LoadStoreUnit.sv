module LoadStoreUnit (
    input logic [31:0] rs,
    input logic [1:0] size, whichbit,

    output logic [3:0] wmask,
    output logic [31:0] WMemData
);
    always_comb begin
        WMemData = {4{rs[7:0]}};
        wmask = 4'b0000;
        case(size)
            2'b00: begin
                WMemData = {4{rs[7:0]}};
                case(whichbit)
                    2'b00: wmask = 4'b0001;
                    2'b01: wmask = 4'b0010;
                    2'b10: wmask = 4'b0100;
                    2'b11: wmask = 4'b1000;
                endcase
            end
            2'b01: begin
                WMemData = {2{rs[15:8], rs[7:0]}};
                case(whichbit[1])
                    1'b0: wmask = 4'b0011;
                    1'b1: wmask = 4'b1100;
                endcase
            end
            2'b10: begin
                WMemData = rs;
                wmask = 4'b1111;
            end
            default begin end
        endcase
    end
endmodule
//Good
