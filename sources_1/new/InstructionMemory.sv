`timescale 1ns / 1ps

// storing Machine Code
module InstructionMemory (  // only Read
    input logic [31:0] addr,

    output logic [31:0] data
);

    logic [31:0] rom[0:63];

    initial begin
        rom[0]  = 32'h00520333;  // add x6, x4, x5
        rom[1]  = 32'h402184b3;  // sub x9, x3, x2 => 1
        rom[2]  = 32'h00602503;  // lw x10, x0, 6
        rom[3]  = 32'h00a02583;  // lw x11, x0, 10
        rom[4]  = 32'h00A08193;  // addi x3, x0, 10
        rom[5]  = 32'h00502223;  // sw x0, 4, x5
        rom[6]  = 32'h00108463;  // beq x1, x1, 8
        rom[7]  = 32'hx;
        rom[8]  = 32'h00108163;  // beq x1, x1, 1
        rom[9]  = 32'h00008637;  // lui x12, 8 => store rd 8000
        rom[10] = 32'h00008697;  // auipc x13, 8
        rom[11] = 32'h0080076F;  //  jal x14, 8
        rom[12] = 32'hx;  // 
        // rom[13] = 32'h004207E7;  // jalr x15, x4, 4 => x2 실행
        rom[13] = 32'h034207e7;  // jalr x15, x4, 52 => x14 실행
        rom[14] = 32'hf00001b7;  // LUI x3 0xf_0000
        rom[15] = 32'h00a22393;  // SLTI x7, x4, 10
        rom[16] = 32'h00421413;  // SLLI x8, x4, 4
        rom[17] = 32'h00425493;  // SRLI x9, x4, 4
        rom[18] = 32'h4041d393;  // SRAI x7, x3, 4
        rom[19] = 32'hfff00093;  // addi x1 x0 -1
        rom[20] = 32'h00100113;  // addi x2 x0 1
        rom[21] = 32'h0020a733;  // SLT x14, x1, x2
        rom[22] = 32'h0020b7b3;  // SLTU x15, x1, x2
        rom[23] = 32'h0010a813;  // SLTI x16, x1, 1
        rom[24] = 32'h0010b893;  // SLTIU x17, x1, 1
        rom[25] = 32'h0FC01903;  // LH x18, 252, x0 => RAM[63]의 -1 가져와서 저장
        rom[26] = 32'h0FC05983;  // LHU x19, 252, x0
        rom[27] = 32'h0f802a03;  // LW x20, 248, x0
        rom[28] = 32'h0F400423;  // SB x20, 232, x0(rs2 : x20)
        rom[29] = 32'h0f401623;  // SH x20, 236, x0
        rom[30] = 32'h0f402823;  // SW x20, 240, x0
        rom[31] = 32'hx;  // 
    end

    assign data = rom[addr[31:2]];
endmodule
