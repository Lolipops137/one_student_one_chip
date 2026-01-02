module DataMemory (
    input  logic Clk, SiUned,
    input  logic MemWrite, MemRead,
    input  logic [1:0]  size,
    /* verilator lint_off UNUSED */
    input  logic [3:0]  wmask,
    /* verilator lint_on UNUSED */
    input  logic [31:0] addr,           // адрес
    input  logic [31:0] WMemData,
    output logic [31:0] DataRead
);
    /* verilator lint_off UNUSED */
    logic [5:0] unused_addr = addr[31:26];
    /* verilator lint_on UNUSED */
    // память: 1024 слов по 32 бита (можно менять размер)

    localparam MEM_SIZE_WORDS = 1 << 24;

    logic [7:0] mem [0:67108863];
    logic [31:0] mem_words [0:16777215];
    integer i;
    reg [31:0] tmp;
    initial begin
        for (i = 0; i < 67108864; i = i + 1)
            mem[i] = 8'b0;
        for (i = 0; i < 16777216; i = i + 1)
            mem_words[i] = 32'b0;
        $readmemh("mem_out.txt", mem_words); // mem_words — временный массив слов
        for (i = 0; i < MEM_SIZE_WORDS; i = i + 1) begin
            tmp = mem_words[i];
            mem[i*4 + 0] = tmp[7:0];    // младший байт
            mem[i*4 + 1] = tmp[15:8];
            mem[i*4 + 2] = tmp[23:16];
            mem[i*4 + 3] = tmp[31:24];  // старший байт
        end
    end

    // синхронная запись
    always_ff @(posedge Clk) begin
        if (MemWrite) begin

            case(size)
                2'b00: begin
                    mem[addr[25:0]] <= WMemData[7:0];
                end
                2'b01: begin
                    mem[addr[25:0]] <= WMemData[7:0];
                    mem[addr[25:0]+1] <= WMemData[15:8];
                end
                2'b10: begin
                    mem[addr[25:0] + 0] <= WMemData[7:0];
                    mem[addr[25:0] + 1] <= WMemData[15:8];
                    mem[addr[25:0] + 2] <= WMemData[23:16];
                    mem[addr[25:0] + 3] <= WMemData[31:24];
                end
                default begin end
            endcase
        end
    end

    // асинхронное чтение
    always_comb begin
        if (MemRead) begin
            case(size)
                2'b00: begin
                    case(SiUned)
                        1'b0: DataRead = { {24{mem[addr[25:0]][7]}}, mem[addr[25:0]] };
                        1'b1: DataRead = { 24'b0, mem[addr[25:0]] };
                    endcase
                end
                2'b01: begin
                    case(SiUned)
                        1'b0: DataRead = { {16{mem[addr[25:0]+1][7]}}, mem[addr[25:0]+1], mem[addr[25:0]] };
                        1'b1: DataRead = { 16'b0, mem[addr[25:0]+1], mem[addr[25:0]] };
                    endcase
                end
                2'b10: DataRead = { mem[addr[25:0]+3], mem[addr[25:0]+2], mem[addr[25:0]+1], mem[addr[25:0]] };
                default begin end
            endcase
        end
        else begin
            DataRead = 32'b0;
        end
    end

endmodule
