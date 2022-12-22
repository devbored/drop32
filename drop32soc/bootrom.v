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

module bootrom (
    input                           i_clk, i_en,
    input       [ADDR_WIDTH-1:0]    i_addr,
    output reg  [DATA_WIDTH-1:0]    o_data
);
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 5;
    parameter MEMFILE = "init.mem";
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    // Load mem file values into "synchronous ROM" - then read if enabled
    initial $readmemh(MEMFILE, rom);
    always @(posedge i_clk) begin if(i_en) o_data <= rom[i_addr]; end

endmodule