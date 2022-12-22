# Copyright (c) 2022 Austin Annestrand
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# --- Jump/Branch tests ---
#   (Fails if s1 is non-zero)

    li    s3, 1
    li    s1, 0
    j     L0
    addi  s1, s1, 1
L0: jalr  zero, zero, 24    # Jump to "beq" below
    addi  s1, s1, 1
    beq   zero, zero, L1
    addi  s1, s1, 1
L1: bne   s1, s3, L2
    addi  s1, s1, 1
L2: blt   zero, s3, L3
    addi  s1, s1, 1
L3: bge   s3, zero, L4
    addi  s1, s1, 1
L4: bltu  zero, s3, L5
    addi  s1, s1, 1
L5: bgeu  s3, zero, STALL
    addi  s1, s1, 1

STALL:  ebreak
        # Add some NOP padding
        nop
        nop
        nop
        nop
        j STALL
