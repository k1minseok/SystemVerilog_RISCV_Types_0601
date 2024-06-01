`timescale 1ns / 1ps

// storing Machine Code
module InstructionMemory (  // only Read
    input logic [31:0] addr,

    output logic [31:0] data
);

    logic [31:0] rom[0:63];

    initial begin
        rom[0]  = 32'h00520333;  // add x6, x4, x5
        rom[1]  = 32'h401184b3;  // sub x9, x3, x2 => 1
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
        rom[13] = 32'h004207E7;  // jalr x15, x4, 4
        rom[14] = 32'hx;  // 
        rom[15] = 32'hx;  // 
    end

    assign data = rom[addr[31:2]];
endmodule
