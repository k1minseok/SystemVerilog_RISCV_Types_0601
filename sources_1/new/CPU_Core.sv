`timescale 1ns / 1ps


module CPU_Core (
    input logic        clk,
    input logic        reset,
    input logic [31:0] machineCode,
    input logic [31:0] dataMemRData,

    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData,
    output logic dataMem_wr_en
);

    logic w_regFile_wr_en, w_AluSrcMuxSel;
    logic [1:0] w_RFWriteDataSrcMuxSel;
    logic [3:0] w_ALUControl;
    logic [2:0] w_extType;
    logic w_Bbranch, w_Jbranch, w_JIbranch;

    ControlUnit U_ControlUnit (  // only Read
        .op    (machineCode[6:0]),
        .funct3(machineCode[14:12]),
        .funct7(machineCode[31:25]),

        .regFile_wr_en       (w_regFile_wr_en),
        .AluSrcMuxSel        (w_AluSrcMuxSel),
        .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
        .dataMem_wr_en       (dataMem_wr_en),
        .extType             (w_extType),
        .Bbranch             (w_Bbranch),
        .Jbranch             (w_Jbranch),
        .JIbranch            (w_JIbranch),
        .ALUControl          (w_ALUControl)
    );

    DataPath U_DataPath (
        .clk                 (clk),
        .reset               (reset),
        .machineCode         (machineCode),
        .regFile_wr_en       (w_regFile_wr_en),
        .ALUControl          (w_ALUControl),
        .dataMemRData        (dataMemRData),
        .AluSrcMuxSel        (w_AluSrcMuxSel),
        .extType             (w_extType),
        .Bbranch             (w_Bbranch),
        .Jbranch             (w_Jbranch),
        .JIbranch            (w_JIbranch),
        .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),

        .instrMemRAddr(instrMemRAddr),
        .dataMemRAddr (dataMemRAddr),
        .dataMemWData (dataMemWData)
    );
endmodule
