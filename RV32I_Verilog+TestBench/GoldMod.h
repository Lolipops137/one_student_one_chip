#include "cstdint"
#include "vector"


class sCPU{
public:
    sCPU();

    void LoadInst(const std::vector<uint32_t>& words);

    void SetPC(uint32_t pc);

    int GetPC();

    bool ExecuteInst(uint32_t& written_reg, uint32_t& written_value);

private:
    uint32_t pc_;
    uint32_t regs_[32];

    std::vector<uint8_t> imem_;
};
