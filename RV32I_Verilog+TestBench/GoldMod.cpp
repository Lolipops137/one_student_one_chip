#include "GoldMod.h"
#include <iostream>
#include <bitset>


sCPU::sCPU():pc_(0) {
    for(int i = 0; i < 32; i++){ // to clear register content
        regs_[i] = 0;
    }
}

void sCPU::LoadInst(const std::vector<uint32_t> & words){
    imem_.clear();
    for(auto w : words){ // enter data in memory
        imem_.push_back(w & 0xFF);
        imem_.push_back((w >> 8) & 0xFF);
        imem_.push_back((w >> 16) & 0xFF);
        imem_.push_back((w >> 24) & 0xFF);
    }
    imem_.resize(336000);
}

void sCPU::SetPC(uint32_t pc){
    pc_ = pc;
}

int sCPU::GetPC(){
    return pc_;
}

bool sCPU:: ExecuteInst(uint32_t& written_reg, uint32_t& written_value){

    // decoder
    uint32_t Inst = 
                (uint32_t)imem_[pc_] | 
                (uint32_t)(imem_[pc_ + 1] << 8) | 
                (uint32_t)(imem_[pc_ + 2] << 16) | 
                (uint32_t)(imem_[pc_ + 3] << 24);
    uint8_t OpCode = Inst & 0x7F;
    uint8_t rd = (Inst >> 7) & 0x1F;
    uint8_t funct3 = (Inst >> 12) & 0x7;
    uint8_t funct7 = (Inst >> 25) & 0x7F;
    uint8_t rs1 = (Inst >> 15) & 0x1F;
    uint8_t rs2 = (Inst >> 20) & 0x1F;
    int32_t immI = (int32_t)Inst >> 20;
    int32_t immS = ((Inst >> 25) & 0x7F) << 5 | ((Inst >> 7) & 0x1F);
    if (immS & 0x800) {          // если бит 11 = 1
        immS |= 0xFFFFF000;       // заполнить старшие 19 бит единицами
    }
    int32_t immB = ((Inst >> 31) & 0x1) << 12 | ((Inst >> 7) & 0x1) << 11 | 
                    ((Inst >> 25) & 0x3F) << 5 | ((Inst >> 8) & 0xF) << 1;
    if (immB & 0x1000) {          // если бит 12 = 1
        immB |= 0xFFFFE000;       // заполнить старшие 19 бит единицами
    }
    int32_t immU = (int32_t)(Inst & 0xFFFFF000);
    int32_t immJ = ((Inst >> 31) & 0x1) << 20 | ((Inst >> 12) & 0xFF) << 12 |
                    ((Inst >> 20) & 0x1) << 11 | ((Inst >> 21) & 0x3FF) << 1;
    if (immJ & 0x100000) {          // если бит 20 = 1
        immJ |= 0xFFE00000;       // заполнить старшие 11 бит единицами
    }
    // decoder


    regs_[0] = 0;
    bool has_write = false;
    switch (OpCode) { // ALU
            case 0x33: 
                switch(funct3) {
                    case 0x0:
                        switch(funct7) {
                            case 0x0: 
                                regs_[rd] = regs_[rs1] + regs_[rs2];
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                            case 0x20: 
                                regs_[rd] = regs_[rs1] - regs_[rs2];
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                        }
                        break;

                    case 0x1:
                        regs_[rd] = regs_[rs1] << (regs_[rs2] & 0x1F);
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;  

                    case 0x2:
                        regs_[rd] = ((int32_t)regs_[rs1] < (int32_t)regs_[rs2]) ? 1 : 0;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;  

                    case 0x3:
                        regs_[rd] = (regs_[rs1] < regs_[rs2]) ? 1 : 0;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;  

                    case 0x4:
                        regs_[rd] = regs_[rs1] ^ regs_[rs2];
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;  

                    case 0x5:
                        switch(funct7) {
                            case 0x0:   regs_[rd] = regs_[rs1] >> (regs_[rs2] & 0x1F);
                                        has_write = true;
                                        pc_ = pc_ + 4;
                                        break;
                            case 0x20:  regs_[rd] = (int32_t)regs_[rs1] >> (regs_[rs2] & 0x1F);
                                        has_write = true;
                                        pc_ = pc_ + 4;
                                        break;
                        }
                        break;

                    case 0x6:   
                        regs_[rd] = regs_[rs1] | regs_[rs2];
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;

                    case 0x7:   
                        regs_[rd] = regs_[rs1] & regs_[rs2];
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;
                }
                break;
                    
            case 0x13: // Imm ALU
                switch(funct3) {
                    case 0x0:
                        regs_[rd] = regs_[rs1] + immI;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;

                    case 0x1: 
                        switch(funct7) {
                            case 0x0:
                                regs_[rd] = regs_[rs1] << (immI & 0x1F);
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                        }
                        break;

                    case 0x2: 
                        regs_[rd] = ((int32_t)regs_[rs1] < (int32_t)immI) ? 1 : 0;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;

                    case 0x3: 
                        regs_[rd] = (regs_[rs1] < immI) ? 1 : 0;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;

                    case 0x4: 
                        regs_[rd] = regs_[rs1] ^ immI;
                        has_write = true;
                        pc_ = pc_ + 4;
                        break;

                    case 0x5: 
                        switch(funct7) {
                            case 0x0: 
                                regs_[rd] = regs_[rs1] >> (immI & 0x1F);
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;

                            case 0x20: 
                                regs_[rd] = (int32_t)regs_[rs1] >> (immI & 0x1F);
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                        }
                        break;

                        case 0x6: 
                            regs_[rd] = regs_[rs1] | immI;
                            has_write = true;
                            pc_ = pc_ + 4;
                            break;

                        case 0x7: 
                            regs_[rd] = regs_[rs1] & immI;
                            has_write = true;
                            pc_ = pc_ + 4;
                            break;
                }
                break;
                    
            case 0x3:{ // LOAD
                    int32_t addr = (int32_t)regs_[rs1] + immI;
                    switch(funct3) {
                        case 0x0: regs_[rd] = (int32_t)(int8_t)imem_[addr];
                                  has_write = true;
                                  pc_ = pc_ + 4;
                                  break;
                        case 0x1: 
                            if(addr%2==0){
                                int16_t val = (int16_t)((imem_[addr+1] << 8) | imem_[addr]);
                                regs_[rd] = (int32_t)val;
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                            }
                        case 0x2: 
                            if(addr%4==0){
                                regs_[rd] = (int32_t)(((uint32_t)imem_[addr+3] << 24) |
                                                       ((uint32_t)imem_[addr+2] << 16) |
                                                       ((uint32_t)imem_[addr+1] << 8)  |
                                                       (uint32_t)imem_[addr]);
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                            }
                        case 0x4: regs_[rd] = (uint32_t)imem_[addr];
                                  has_write = true;
                                  pc_ = pc_ + 4;
                                  break;
                        case 0x5:
                            if(addr%2==0){
                                uint16_t val = ((uint16_t)imem_[addr+1] << 8) | imem_[addr];
                                regs_[rd] = val;
                                has_write = true;
                                pc_ = pc_ + 4;
                                break;
                            }
                    }
                    break;
            }

            case 0x23: { //STORE
                    int32_t addr1 = (int32_t)regs_[rs1] + immS;
                    switch(funct3) {
                        case 0x0: 
                            imem_[addr1] = regs_[rs2] & 0xFF;
                            has_write = false;
                            pc_ = pc_ + 4;
                            printf("JALR_PC = %d\n", pc_);
                            break;
                        case 0x1: 
                            if(addr1%2==0){
                                imem_[addr1] = regs_[rs2] & 0xFF;
                                imem_[addr1+1] = (regs_[rs2] >> 8) & 0xFF;
                                has_write = false;
                                pc_ = pc_ + 4;
                                break;
                            }
                        case 0x2: 
                            if(addr1%4==0){
                                imem_[addr1] = regs_[rs2] & 0xFF;
                                imem_[addr1+1] = (regs_[rs2] >> 8) & 0xFF;
                                imem_[addr1+2] = (regs_[rs2] >> 16) & 0xFF;
                                imem_[addr1+3] = (regs_[rs2] >> 24) & 0xFF;
                                has_write = false;
                                pc_ = pc_ + 4;
                                break;
                            }
                    }
            break;
            }
                   
            case 0x63: // BRANCH
                    switch(funct3) {
                        case 0x0: pc_ = (regs_[rs1] == regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                        case 0x1: pc_ = (regs_[rs1] != regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                        case 0x4: pc_ = ((int32_t)regs_[rs1] < (int32_t)regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                        case 0x5: pc_ = ((int32_t)regs_[rs1] >= (int32_t)regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                        case 0x6: pc_ = (regs_[rs1] < regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                        case 0x7: pc_ = (regs_[rs1] >= regs_[rs2]) ? pc_ + immB : pc_ + 4;
                                  has_write = false;
                                  break;
                    }
                    break;
                    
            case 0x6f: regs_[rd] = pc_ + 4; // JAL
                       pc_ = pc_ + immJ;
                       has_write = true;
                       break;
            case 0x67: {
                    uint32_t temp_pc = pc_;
                    pc_ = (regs_[rs1] + immI);
                    regs_[rd] = temp_pc + 4; // JALR
                    has_write = true;
                    break;
            }
            case 0x37: regs_[rd] = immU; // LUI
                       has_write = true;
                       pc_ = pc_ + 4;
                       break;
            case 0x17: regs_[rd] = immU + pc_; // AUIPC
                       has_write = true;
                       pc_ = pc_ + 4;
                       break;
            
            default: return false;
    }
    regs_[0] = 0;
    if (has_write) {
        written_reg   = rd;
        written_value = regs_[rd];
    }
    return has_write;
}

