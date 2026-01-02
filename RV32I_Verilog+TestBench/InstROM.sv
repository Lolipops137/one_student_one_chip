module InstROM (
    input  logic [31:0] sel,
    output logic [31:0] Inst
);
    /* verilator lint_off UNUSED */
    logic [7:0] unused_sel = sel[31:24];
    /* verilator lint_on UNUSED */

    logic [23:0] ssel = sel[23:0];
    // память 256 x 32
    logic [31:0] mem [0:16777215];

    // инициализация из файла
    initial begin
        $readmemh("mem_out.txt", mem);
    end

    // асинхронное чтение
    assign Inst = mem[ssel >> 2];
endmodule
