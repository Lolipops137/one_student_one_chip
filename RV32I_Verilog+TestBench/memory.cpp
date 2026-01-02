#include <svdpi.h>
#include <vector>
#include <iostream>
#include <fstream>

#define MEM_SIZE (128 * 1024 * 1024)
// static std::vector<uint8_t> memory;
static uint8_t memory[MEM_SIZE];
static constexpr uint32_t BASE = 0x80000000;
extern "C" void LoadInstructions(const char* filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file.is_open()) {
        std::cout << "Failed to open file\n";
        return;
    }
    file.seekg(0, std::ios::end);
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);
    if (size <= 0) {
        std::cout << "Empty file\n";
        return;
    }
    if (size > MEM_SIZE) {
        std::cout << "Program is too large for memory\n";
        return;
    }
    file.read(reinterpret_cast<char*>(memory), size);
    if (!file) {
        std::cout << "Error reading file\n";
        return;
    }
    file.close();
}


extern "C" uint32_t mem_read(uint32_t raddr) {
    uint32_t address = (raddr - BASE) & ~0x3u;
    if(address + 3 > MEM_SIZE){
        return 0;
    }
    uint32_t ret =  (uint32_t)memory[address] |
           ((uint32_t)memory[address + 1] << 8) |
           ((uint32_t)memory[address + 2] << 16) |
           ((uint32_t)memory[address + 3] << 24);
    // printf("raddr = 0x%08x, ret = 0x%08x\n", raddr, ret);
    return ret;
}
    // Return the 4-byte data at address `raddr & ~0x3u`.
    // ...

extern "C" void mem_write(uint32_t waddr, uint32_t wdata, uint8_t wmask) {
    if (waddr == 0x10000000) { // write to UART
        fputc(wdata & 0xff, stderr); // in stdio.h
        return;
    } //ignore this if statement
    uint32_t base = (waddr - BASE) & ~0x3u;

    for (int i = 0; i < 4; i++) {
        if (wmask & (1 << i)) {
            memory[base + i] = (wdata >> (8 * i)) & 0xFF;
        }
    }
    // printf("%08x   |   %08x.     |.    %08x\n", waddr, wdata, wmask);
}
    // Write `wdata` according to `wmask` to the 4-byte data at address `waddr & ~0x3u`
    // Every bit in `wmask` represents the mask of 1-byte in `wdata`.
    // For example, `wmask = 0x3` means only writing to the lower 2 bytes,
    // with other bytes in memory unchanged.
    // ...