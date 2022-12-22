// Copyright (c) 2022 Austin Annestrand
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <cstdio>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <gtest/gtest.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vdrop32.h"
#include "Vdrop32__Syms.h"
#include "drop32.hh"
#include "common.hh"

namespace {
// Embed the test programs binaries here
#include "add.inc"
#include "addi.inc"
#include "and.inc"
#include "andi.inc"
#include "auipc.inc"
#include "beq.inc"
#include "bge.inc"
#include "bgeu.inc"
#include "blt.inc"
#include "bltu.inc"
#include "bne.inc"
#include "j.inc"
#include "jal.inc"
#include "jalr.inc"
#include "lb.inc"
#include "lbu.inc"
#include "lh.inc"
#include "lhu.inc"
#include "lui.inc"
#include "lw.inc"
#include "or.inc"
#include "ori.inc"
#include "sb.inc"
#include "sh.inc"
#include "simple.inc"
#include "sll.inc"
#include "slli.inc"
#include "slt.inc"
#include "slti.inc"
#include "sra.inc"
#include "srai.inc"
#include "srl.inc"
#include "srli.inc"
#include "sub.inc"
#include "sw.inc"
#include "xor.inc"
#include "xori.inc"
}

extern int g_dumpLevel;

#define FUNCTIONAL_TEST(name, memsize, timeout, dumplvl)                                                            \
TEST(functional, name) {                                                                                            \
    constexpr int memSize = memsize;                                                                                \
    drop32 dut = drop32(timeout, dumplvl);                                                                          \
    if (!dut.create(new Vdrop32(), "build/vcd/" #name ".vcd")) { FAIL(); }                                          \
    if (!dut.createMemory(memSize,                                                                                  \
        build_external_riscv_tests_ ## name ## _hex, build_external_riscv_tests_ ## name ## _hex_len)) { FAIL(); }  \
    dut.m_cpu->i_ifValid    = 1;                                                                                    \
    dut.m_cpu->i_memValid   = 1;                                                                                    \
    dut.writeRegfile(SP, memSize-1);                                                                                \
    dut.writeRegfile(FP, memSize-1);                                                                                \
    while (!dut.end()) {                                                                                            \
        if (!dut.instructionUpdate())    { FAIL(); }                                                                \
        if (!dut.loadStoreUpdate())      { FAIL(); }                                                                \
        dut.tick();                                                                                                 \
    }                                                                                                               \
    char resultStr[4] = {0};                                                                                        \
    resultStr[0] = (char)dut.readRegfile(A1);                                                                       \
    resultStr[1] = (char)dut.readRegfile(A2);                                                                       \
    resultStr[2] = (char)dut.readRegfile(A3);                                                                       \
    EXPECT_EQ(std::strcmp(resultStr, "OK"), 0) << "resultStr: \"" << resultStr << "\"";                             \
}

// FUNCTIONAL_TEST(name, memsize, timeout, dumplvl)
// ====================================================================================================================
FUNCTIONAL_TEST(add,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(addi,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(and,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(andi,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(auipc,  0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(beq,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(bge,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(bgeu,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(blt,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(bltu,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(bne,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(j,      0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(jal,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(jalr,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lb,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lbu,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lh,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lhu,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lui,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(lw,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(or,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(ori,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sb,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sh,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(simple, 0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sll,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(slli,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(slt,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(slti,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sra,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(srai,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(srl,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(srli,   0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sub,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(sw,     0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(xor,    0x4000, 1000, g_dumpLevel)
FUNCTIONAL_TEST(xori,   0x4000, 1000, g_dumpLevel)
