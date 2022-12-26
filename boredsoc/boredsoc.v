// Really simple example SoC design
module boredsoc (
    input   i_clk, i_rst,
    output  o_led
);
    wire [31:0] pcOut, dataAddr, dataOut, bootRomOut, dataMemOut;
    reg  [31:0] dataIn;
    wire loadReq, storeReq, imem_data_sel, dmem_data_sel, led_data_sel;

    reg ifValid     = 1'b0; // Reading/Writing from DualPortRam takes 1cc (we can pipeline the reads after)
    reg memValid    = 1'b0; // Reading/Writing from DualPortRam takes 1cc

    // TODO: Add UART module
    // ...

    // IMEM ROM (bootrom.v)
    bootrom #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(10), // 1KB
        .MEMFILE("firmware.mem")
    ) IMEM (
        .i_clk                  (i_clk),
        .i_en                   (1'b1),
        .i_addr                 ({2'd0, pcOut[9:2]}),
        .o_data                 (bootRomOut)
    );
    // Data memory (core_generated.v)
    DualPortRam #(
        .XLEN(32),
        .ADDR_WIDTH(10) // 1KB
    ) DMEM (
        .i_clk                  (i_clk),
        .i_we                   (dmem_data_sel && storeReq),
        .i_dataIn               (dataOut),
        .i_rAddr                (dataAddr[10:0]),
        .i_wAddr                (dataAddr[10:0]),
        .o_q                    (dataMemOut)
    );
    // CPU (core_generated.v)
    CPU CPU_unit (
        .i_clk                  (i_clk),
        .i_rst                  (i_rst),
        .i_ifValid              (ifValid),
        .i_memValid             (memValid),
        .i_instr                (bootRomOut),
        .i_dataIn               (dataIn),
        .o_storeReq             (storeReq),
        .o_loadReq              (loadReq),
        .o_pcOut                (pcOut),
        .o_dataAddr             (dataAddr),
        .o_dataOut              (dataOut)
    );

    // Output MMIO led reg
    reg [31:0] ledReg = 32'd0;
    always @(posedge i_clk) begin
        ledReg <= i_rst ? 32'd0 : (storeReq && led_data_sel) ? dataOut : ledReg;
    end

    // Data memory valid logic on load/store requests (reset after each transaction)
    always @(posedge i_clk) begin
        memValid <= (i_rst || memValid) ? 1'b0 : (loadReq | storeReq);
    end
    // Instruction memory valid logic (need to wait 1cc per transaction)
    always @(posedge i_clk) begin
        ifValid <= i_rst ? 1'b0 : ~ifValid;
    end

    // Simple memory map controller
    // Address decoding logic
    // -------------------------------------------------------------------------
    // | Address Range             | Description                               |
    // | ------------------------- | ---------------------------------------   |
    // | 0x00000000 ... 0x000001FF | Internal IMEM ROM (BRAM) - 2KB (readonly) |
    // | 0x00000200 ... 0x000003FF | Internal DMEM (BRAM) - 2KB                |
    // | 0x00003000 ... 0x00003003 | Output LED                                |
    // -------------------------------------------------------------------------
    assign imem_data_sel    = ~dataAddr[12] & ~dataAddr[9];
    assign dmem_data_sel    = ~dataAddr[12] &  dataAddr[9];
    assign led_data_sel     =  dataAddr[12];
    always @* begin
        if (imem_data_sel) begin
            dataIn = bootRomOut;
        end else if (dmem_data_sel) begin
            dataIn = dataMemOut;
        end else if (led_data_sel) begin
            dataIn = ledReg;
        end else begin
            dataIn = 32'd0;
        end
    end

    // SoC I/O
    assign o_led = ledReg[0];

endmodule