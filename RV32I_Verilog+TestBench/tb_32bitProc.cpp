#include <stdlib.h>
#include <iostream>
#include <fstream>
#include "GoldMod.h"

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop_module.h"
#include "Vtop_module___024root.h"

#define MAX_SIM_TIME 100000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vtop_module *dut = new Vtop_module;
    sCPU *Golddut = new sCPU;

    std::vector<uint32_t> instlist;
    std::ifstream f("mem_out.txt");
    std::string line;
    while (std::getline(f, line)) {
        if (line.empty()) continue;
        uint32_t val = std::stoul(line, nullptr, 16); // hex → число
        instlist.push_back(val);
    }

    Golddut -> LoadInst(instlist);
    Golddut -> SetPC(dut->tCurPC);


    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    uint32_t kuda = 0;
    uint32_t chto = 0;

    // начальные значения
    dut->Clk = 0;
    dut->Rst = 1;   // активируем reset сразу

    // один такт сброса
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // снимаем reset
    dut->Rst = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut->Clk = 0;
        dut->eval();
        m_trace->dump(sim_time++);
        std::cout << "PC is " << Golddut -> GetPC() << "\n";
    
        
        if(Golddut -> ExecuteInst(kuda, chto)){
            std::cout << std::hex << (int)dut->tCurPC << "\n";
            std::cout << "dut=" << (int)dut->trd << " GoldMod=" << (int)kuda << "\n";

            if ((int)dut->trd != kuda) {
                std::cout << "TEST1 FAILED at time " << sim_time << "\n";
                std::cout << "dut=" << (int)dut->trd << " GoldMod=" << (int)kuda << "\n";
                exit(1);
            }

            if((int)dut->trd == 0){
                dut->twdata = 0;
            }

            std::cout << "wdata=" << (int)dut->twdata << " GoldMod=" << (int)chto << "\n";
            if ((int)dut->twdata != chto) {
                std::cout << "TEST2 FAILED at time " << sim_time << "\n";
                std::cout << "wdata=" << (int)dut->twdata << " GoldMod=" << (int)chto << "\n";
                exit(1);
            }
            std::cout << "\n" ;
            dut->Clk = 1;
            dut->eval();
            m_trace->dump(sim_time++);
            std::cout << "\n" ;
        } else {
            std::cout << std::hex << (int)dut->tCurPC << "\n";
            dut->Clk = 1;
            dut->eval();
            m_trace->dump(sim_time++);
            
        }

    }
    std::cout << "TEST PASSED" << "\n"; 
    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}