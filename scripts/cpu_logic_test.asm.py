#! /usr/bin/env python3

import random

from math import log
from common import *

logicVal1           = random.randint(Imm32Ranges.I_MIN.value//2, Imm32Ranges.I_MAX.value//2)
logicVal2           = random.randint(Imm32Ranges.I_MIN.value//2, Imm32Ranges.I_MAX.value//2)
logicRs1            = logicVal1
logicRs2            = logicVal2
logicRs3            = logicVal1 & logicVal2
logicRs4            = logicVal1 | logicVal2
logicRs5            = logicVal1 ^ logicVal2
logicTestProgram    = f'''
    # --- Logic tests ---
    #     (Fails if x30 is non-zero)
    addi  x30, x30, 1
    andi  x6, x1, {logicVal2}
    bne   x6, x3, FAIL
    addi  x30, x30, 1
    and   x6, x1, x2
    bne   x6, x3, FAIL
    addi  x30, x30, 1
    ori   x6, x1, {logicVal2}
    bne   x6, x4, FAIL
    addi  x30, x30, 1
    or    x6, x1, x2
    bne   x6, x4, FAIL
    addi  x30, x30, 1
    xori  x6, x1, {logicVal2}
    bne   x6, x5, FAIL
    addi  x30, x30, 1
    xor   x6, x1, x2
    bne   x6, x5, FAIL
    addi  x30, x30, 1
    jal   x29, STALL

    FAIL:   addi x6, x0, -1  # DONE
            add  x31, x0, x30
    STALL:  addi x6, x0, -1  # DONE
            jal  x0, STALL
            # Add some NOP padding
            nop
            nop
            nop
            nop
'''

if __name__ == "__main__":
    # Input test vectors
    outfile = f"{basenameNoExt(parseArgv(sys.argv).outDir, __file__)}.s"
    with open(outfile, 'w') as fp:
        print(logicTestProgram, file=fp)
    # Init regfile values:
    outfile = f"{basenameNoExt(parseArgv(sys.argv).outDir, __file__)}.regs"
    with open(outfile, 'w') as fp:
        print(logicRs1, file=fp)
        print(logicRs2, file=fp)
        print(logicRs3, file=fp)
        print(logicRs4, file=fp)
        print(logicRs5, file=fp)
        print(logicRs2, file=fp)
        print(logicRs3, file=fp)
        print(logicRs4, file=fp)
        print(logicRs5, file=fp)