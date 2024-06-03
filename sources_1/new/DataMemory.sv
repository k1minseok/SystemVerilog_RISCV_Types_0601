// `timescale 1ns / 1ps

// module DataMemory (     // RAM
//     input logic        clk,
//     input logic        wr_en,
//     input logic [31:0] addr,
//     input logic [31:0] wdata,

//     output logic [31:0] rdata
// );
//     logic [31:0] ram[0:63];

//     initial begin
//         int i;
//         for (i = 0; i < 64; i++) begin
//             ram[i] = 100 + i;
//         end
//         ram[62] = 32'h8765_4321;   // 0xf0f0 f0f0
//         ram[63] = -252645136;   // 0xf0f0 f0f0
//     end
//     assign rdata = ram[addr[31:2]];

//     always_ff @(posedge clk) begin
//         if (wr_en) ram[addr[31:2]] <= wdata;
//     end
// endmodule


`timescale 1ns / 1ps
`include "defines.sv"

module DataMemory (  // RAM
    input logic        clk,
    input logic        ce,
    input logic        wr_en,
    input logic [ 7:0] addr,
    input logic [31:0] wdata,
    input logic [ 1:0] storeType,
    input logic [ 2:0] loadType,

    output logic [31:0] rdata
);
    logic [31:0] ram[0:2**6-1];

    initial begin  // initial for test
        int i;
        for (i = 0; i < 2 ** 6; i++) begin
            ram[i] = 100 + i;
        end
        ram[58] = 32'h9999_9999;
        ram[59] = 32'h9999_9999;
        ram[60] = 32'h9999_9999;
        ram[62] = 32'h8765_4321;  // 0xf0f0 f0f0
        ram[63] = -252645136;  // 0xf0f0 f0f0
    end


    // write
    always_ff @(posedge clk) begin
        // if (wr_en & ce) begin
        if (wr_en) begin
            case (storeType)  // s-type
                // `SB:     ram[addr[7:2]] <= {24'b0, wdata[7:0]};
                // `SH:     ram[addr[7:2]] <= {16'b0, wdata[15:0]};
                // `SW:     ram[addr[7:2]] <= wdata[31:0];
                `SB:     ram[addr[7:2]][7:0] <= wdata[7:0];
                `SH:     ram[addr[7:2]][15:0] <= wdata[15:0];
                `SW:     ram[addr[7:2]] <= wdata[31:0];
                2'bxx:   ram[addr[7:2]] <= wdata;
                default: ram[addr[7:2]] <= 32'bx;
            endcase
        end
    end

    // read
    // assign rdata = ram[addr[7:2]];

    always_comb begin
        case (loadType)
            `LB:     rdata = {{25{ram[addr[7:2]][7]}}, ram[addr[7:2]][6:0]};
            // {{25{rdata[7]}}, rdata[6:0]};
            // `LH: extReadData = {{17{rdata[15]}}, rdata[14:0]};
            // `LW: extReadData = rdata[31:0];
            // `LBU: extReadData = {24'b0, rdata[7:0]};  // 0-extend
            // `LHU: extReadData = {16'b0, rdata[15:0]};
            // default: extReadData = 32'bx;
            `LH:     rdata = {{17{ram[addr[7:2]][15]}}, ram[addr[7:2]][14:0]};
            `LW:     rdata = ram[addr[7:2]][31:0];
            `LBU:    rdata = {24'b0, ram[addr[7:2]][7:0]};  // 0-extend
            `LHU:    rdata = {16'b0, ram[addr[7:2]][15:0]};
            3'bxxx:  rdata = ram[addr[7:2]];
            default: rdata = 32'bx;
        endcase
    end
endmodule


// module DataMemory (
//     input logic        clk,
//     input logic        ce,
//     input logic        wr_en,
//     input logic [ 7:0] addr,
//     input logic [31:0] wdata,
//     input logic [ 1:0] trncType,  // 추가된 입력
//     input logic [ 2:0] extType,   // 추가된 입력

//     output logic [31:0] rdata,
//     output logic [31:0] extReadData  // 추가된 출력
// );
//     logic [31:0] ram[0:2**6-1];
//     logic [31:0] trncWriteData;  // 내부 신호

//     // 초기화 블록 (테스트용)
//     initial begin
//         int i;
//         for (i = 0; i < 2 ** 6; i++) begin
//             ram[i] = 100 + i;
//         end
//         ram[62] = 32'h8765_4321;  // 0xf0f0 f0f0
//         ram[63] = -252645136;  // 0xf0f0 f0f0
//     end

//     // 쓰기 데이터 변환 (truncate)
//     always_comb begin
//         case (trncType)
//             `SB: trncWriteData = {24'b0, wdata[7:0]};
//             `SH: trncWriteData = {16'b0, wdata[15:0]};
//             `SW: trncWriteData = wdata[31:0];
//             default: trncWriteData = 32'bx;
//         endcase
//     end

//     // 데이터 메모리 읽기
//     assign rdata = ram[addr[7:2]];

//     // 읽기 데이터 확장 (extend)
//     always_comb begin
//         case (extType)
//             `LB: extReadData = {{25{rdata[7]}}, rdata[6:0]};
//             `LH: extReadData = {{17{rdata[15]}}, rdata[14:0]};
//             `LW: extReadData = rdata[31:0];
//             `LBU: extReadData = {24'b0, rdata[7:0]};  // 0-extend
//             `LHU: extReadData = {16'b0, rdata[15:0]};
//             default: extReadData = 32'bx;
//         endcase
//     end

//     // 메모리 쓰기
//     always_ff @(posedge clk) begin
//         if (wr_en & ce) ram[addr[7:2]] <= trncWriteData;
//     end
// endmodule
