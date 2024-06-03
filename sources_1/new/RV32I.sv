`timescale 1ns / 1ps

module RV32I (
    input logic clk,
    input logic reset
);

    logic [31:0] w_InstrMemAddr, w_InstrMemData;
    logic w_dataMem_wr_en;
    logic [31:0] w_dataMemRAddr, w_dataMemRData, w_dataMemWData;
    logic [1:0] w_storeType;
    logic [2:0] w_loadType;

    CPU_Core U_CPU_Core (
        .clk(clk),
        .reset(reset),
        .machineCode(w_InstrMemData),
        .dataMemRData(w_dataMemRData),

        .instrMemRAddr(w_InstrMemAddr),
        .dataMemRAddr (w_dataMemRAddr),
        .dataMemWData (w_dataMemWData),
        .storeType(w_storeType),
        .loadType(w_loadType),
        .dataMem_wr_en(w_dataMem_wr_en)
    );

    DataMemory U_RAM (
        .clk  (clk),
        .wr_en(w_dataMem_wr_en),
        .addr (w_dataMemRAddr),
        .wdata(w_dataMemWData),
        .storeType(w_storeType),
        .loadType(w_loadType),

        .rdata(w_dataMemRData)
    );

    InstructionMemory U_ROM (  // only Read
        .addr(w_InstrMemAddr),

        .data(w_InstrMemData)
    );

endmodule

// `timescale 1ns / 1ps

// module RV32I (
//     input logic clk,
//     input logic reset,

//     output logic [3:0] outPortA
// );

//     logic [31:0] w_InstrMemAddr, w_InstrMemData;
//     logic w_wr_en;
//     logic [31:0] w_Addr, w_dataMemRData, w_WData;
//     logic [31:0] w_MasterRData, w_GpoRData;
//     logic [2:0] w_slave_sel;
//     wire w_div_clk;

//     logic [1:0] w_storeType;
//     logic [2:0] w_loadType;


//     clkDiv #(
//         .HERZ(1_000_000)
//     ) U_ClkDiv (
//         .clk  (clk),
//         .reset(reset),

//         .o_clk(w_div_clk)
//     );

//     CPU_Core U_CPU_Core (
//         .clk(w_div_clk),
//         .reset(reset),
//         .machineCode(w_InstrMemData),
//         .dataMemRData(w_MasterRData),

//         .instrMemRAddr(w_InstrMemAddr),
//         .dataMemRAddr(w_Addr),
//         .dataMemWData(w_WData),
//         .storeType(w_storeType),
//         .loadType(w_loadType),
//         .dataMem_wr_en(w_wr_en)
//     );

//     BUS_Interconnector U_BUS_InterCon (
//         .address(w_Addr),
//         .slave_rdata1(w_dataMemRData),
//         .slave_rdata2(w_GpoRData),
//         .slave_rdata3(),

//         .slave_sel(w_slave_sel),  //Chip-enable
//         .master_rdata(w_MasterRData)
//     );

//     DataMemory U_RAM (  //slave 0
//         .clk  (w_div_clk),
//         .ce   (w_slave_sel[0]),
//         .wr_en(w_wr_en),
//         .addr (w_Addr[7:0]),
//         .wdata(w_WData),
//         .storeType(w_storeType),
//         .loadType(w_loadType),

//         .rdata(w_dataMemRData)
//     );

//     GPO U_GPO (  // slave 1
//         .clk  (w_div_clk),
//         .reset(reset),
//         .ce   (w_slave_sel[1]),
//         .wr_en(w_wr_en),
//         .addr (w_Addr[1:0]),
//         .wdata(w_WData),

//         .rdata(w_GpoRData),
//         .outPort(outPortA)  // 4 ports
//     );

//     InstructionMemory U_ROM (  // only Read
//         .addr(w_InstrMemAddr),

//         .data(w_InstrMemData)
//     );

// endmodule



// module clkDiv #(
//     parameter HERZ = 100
// ) (
//     input clk,
//     input reset,

//     output o_clk
// );

//     reg [$clog2(100_000_000/HERZ)-1 : 0] counter;
//     reg r_clk;

//     assign o_clk = r_clk;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             counter <= 0;
//             r_clk   <= 1'b0;
//         end else begin
//             if (counter == (100_000_000 / HERZ - 1)) begin
//                 counter <= 0;
//                 r_clk   <= 1'b1;
//             end else begin
//                 counter <= counter + 1;
//                 r_clk   <= 1'b0;
//             end
//         end
//     end

// endmodule
