`timescale 1ns / 1ps

module RV32I (
    input logic clk,
    input logic reset
);

    logic [31:0] w_InstrMemAddr, w_InstrMemData;
    logic w_dataMem_wr_en;
    logic [31:0] w_dataMemRAddr, w_dataMemRData, w_dataMemWData;

    CPU_Core U_CPU_Core (
        .clk(clk),
        .reset(reset),
        .machineCode(w_InstrMemData),
        .dataMemRData(w_dataMemRData),

        .instrMemRAddr(w_InstrMemAddr),
        .dataMemRAddr (w_dataMemRAddr),
        .dataMemWData (w_dataMemWData),
        .dataMem_wr_en(w_dataMem_wr_en)
    );

    DataMemory U_RAM (
        .clk  (clk),
        .wr_en(w_dataMem_wr_en),
        .addr (w_dataMemRAddr),
        .wdata(w_dataMemWData),

        .rdata(w_dataMemRData)
    );

    InstructionMemory U_ROM (  // only Read
        .addr(w_InstrMemAddr),

        .data(w_InstrMemData)
    );

endmodule
