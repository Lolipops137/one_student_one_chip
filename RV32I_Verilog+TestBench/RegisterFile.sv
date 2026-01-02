module RegisterFile (
    input logic Clk, Rst, RegWrite,
    input logic [31:0] wdata,
    input logic [4:0] rd, rs1, rs2,

    output logic [31:0] ReadVal1, ReadVal2, regfilevalue
);
    // массив из 32 регистров по 32 бита
    logic [31:0] regs [31:0];

    // чтение — асинхронное
    assign ReadVal1 = (rs1 != 0) ? regs[rs1] : 32'b0; // x0 всегда = 0
    assign ReadVal2 = (rs2 != 0) ? regs[rs2] : 32'b0;

    // запись — синхронная
    always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            // обнуляем все регистры
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end else if (RegWrite && (rd != 0)) begin
            regs[rd] <= wdata;
            regfilevalue <= regs[rd];
        end
    end
endmodule
