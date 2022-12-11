#include <cstdio>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <gtest/gtest.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vboredcore.h"
#include "Vboredcore__Syms.h"
#include "boredcore.hh"
#include "common.hh"

namespace {
// Embed the test programs binaries here
#include "binsearch.inc"
#include "fibonacci.inc"
#include "mergesort.inc"
}

extern int g_dumpLevel;

// ====================================================================================================================
TEST(algorithms, fibonacci) {
    constexpr int memSize = 0x4000;
    boredcore dut = boredcore(1000000, g_dumpLevel);
    if (!dut.create(new Vboredcore(), "obj_dir/fibonacci.vcd"))                                 { FAIL(); }
    if (!dut.createMemory(memSize, build_tests_fibonacci_hex, build_tests_fibonacci_hex_len))   { FAIL(); }

    dut.m_cpu->i_ifValid        = 1;    // Always valid since we assume combinatorial read/write for test memory
    dut.m_cpu->i_memValid       = 1;    // Always valid since we assume combinatorial read/write for test memory
    // Init stack and frame pointers
    dut.writeRegfile(SP, memSize-1);
    dut.writeRegfile(FP, memSize-1);

    while (!dut.end()) {
        if (!dut.instructionUpdate())    { FAIL(); }
        if (!dut.loadStoreUpdate())      { FAIL(); }
        dut.tick(); // Evaluate
    }

    // Check results
    std::function<int(int)> fibonacci = [&](int x) {
        if (x <= 1) { return x; }
        return fibonacci(x - 1) + fibonacci(x - 2);
    };
    EXPECT_EQ(dut.readRegfile(S6), fibonacci(6));
    EXPECT_EQ(dut.readRegfile(S7), fibonacci(7));
    EXPECT_EQ(dut.readRegfile(S8), fibonacci(8));
    EXPECT_EQ(dut.readRegfile(S9), fibonacci(9));
    EXPECT_EQ(dut.readRegfile(S10), fibonacci(10));
}
// ====================================================================================================================
TEST(algorithms, binsearch) {
    constexpr int memSize = 0x4000;
    boredcore dut = boredcore(1000000, g_dumpLevel);
    if (!dut.create(new Vboredcore(), "obj_dir/binsearch.vcd"))                                 { FAIL(); }
    if (!dut.createMemory(memSize, build_tests_binsearch_hex, build_tests_binsearch_hex_len))   { FAIL(); }

    dut.m_cpu->i_ifValid        = 1;    // Always valid since we assume combinatorial read/write for test memory
    dut.m_cpu->i_memValid       = 1;    // Always valid since we assume combinatorial read/write for test memory
    // Init stack and frame pointers
    dut.writeRegfile(SP, memSize-1);
    dut.writeRegfile(FP, memSize-1);

    while (!dut.end()) {
        if (!dut.instructionUpdate())    { FAIL(); }
        if (!dut.loadStoreUpdate())      { FAIL(); }
        dut.tick(); // Evaluate
    }

    // Check results
    EXPECT_EQ(dut.readRegfile(S1),   1); // Testing valid binsearch result
    EXPECT_EQ(dut.readRegfile(S2),   1); // Testing valid binsearch result
    EXPECT_EQ(dut.readRegfile(S3),   1); // Testing valid binsearch result
    EXPECT_EQ(dut.readRegfile(S4),   0); // Testing invalid binsearch result
}
// ====================================================================================================================
TEST(algorithms, mergesort) {
    constexpr int memSize = 0x4000;
    boredcore dut = boredcore(1000000, g_dumpLevel);
    if (!dut.create(new Vboredcore(), "obj_dir/mergesort.vcd"))                                 { FAIL(); }
    if (!dut.createMemory(memSize, build_tests_mergesort_hex, build_tests_mergesort_hex_len))   { FAIL(); }

    dut.m_cpu->i_ifValid        = 1;    // Always valid since we assume combinatorial read/write for test memory
    dut.m_cpu->i_memValid       = 1;    // Always valid since we assume combinatorial read/write for test memory
    // Init stack and frame pointers
    dut.writeRegfile(SP, memSize-1);
    dut.writeRegfile(FP, memSize-1);

    while (!dut.end()) {
        if (!dut.instructionUpdate())    { FAIL(); }
        if (!dut.loadStoreUpdate())      { FAIL(); }
        dut.tick(); // Evaluate
    }

    // Check results
    int arrLen      = dut.readRegfile(S8);
    int origArr     = dut.readRegfile(S9);
    int sortedArr   = dut.readRegfile(S10);
    for (int i=0; i<arrLen; ++i) {
        int goldVal, actualVal;
        dut.peekMem(sortedArr+(i*4), goldVal);
        dut.peekMem(origArr+(i*4), actualVal);
        EXPECT_EQ(goldVal, actualVal);
    }
}
