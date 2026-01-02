module PC32Bit (
    input logic Clk,
    input logic Rst,
    input logic [31:0] NewPC,
    output logic [31:0] CurPC
);
    always_ff @(posedge Clk or posedge Rst) begin
        
        if (Rst) begin
            CurPC <= 32'h0;
        end
        else begin
            CurPC <= NewPC;
        end
    end
endmodule
//Good
