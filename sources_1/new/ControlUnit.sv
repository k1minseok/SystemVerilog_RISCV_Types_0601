`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (  // only Read
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output logic       regFile_wr_en,
    output logic       AluSrcMuxSel,
    output logic [1:0] RFWriteDataSrcMuxSel,
    output logic       dataMem_wr_en,
    output logic [2:0] immExtType,
    output logic [1:0] dataMemWDataTrncType,
    output logic [2:0] dataMemRDataExtType,
    output logic       Bbranch,
    output logic       Jbranch,
    output logic       JIbranch,
    output logic [3:0] ALUControl
);
    logic [15:0] controls;
    // logic [1:0] w_AluOp;

    assign {regFile_wr_en, AluSrcMuxSel, RFWriteDataSrcMuxSel, dataMem_wr_en, immExtType,
        Bbranch, Jbranch, JIbranch, dataMemWDataTrncType, dataMemRDataExtType} = controls;

    always_comb begin : main_decoder
        case (op)
            // regFile_wr_en(1), AluSrcMuxSel(1), RFWriteDataSrcMuxSel(2), dataMem_wr_en(1),
            // immExtType(3), Bbranch(1), Jbranch(1), JI branch(1), dataMemWDataTrncType(2), dataMemRDataExtType(3)
            `OP_TYPE_R:
            controls = 16'b1_0_00_0_xxx_0_0_0_xx_xxx;  // rd = rs1 <연산> rs2
            `OP_TYPE_IL:
            controls = {13'b1_1_01_0_000_0_0_0_xx, funct3};  // rd = M[rs1+imm]  
            `OP_TYPE_I:
            controls = 16'b1_1_00_0_001_0_0_0_xx_xxx;  // rd = rs1 <연산> imm
            `OP_TYPE_S:
            controls = {11'b0_1_xx_1_010_0_0_0, funct3[1:0], 3'bxxx};  // M[rs1+imm] = rs2   
            `OP_TYPE_B:
            controls = 16'b0_0_xx_0_011_1_0_0_xx_xxx;  // if(rs1==rs2) PC += imm
            `OP_TYPE_U:
            controls = 16'b1_x_10_0_100_0_0_0_xx_xxx;  // rd = imm << 12     
            `OP_TYPE_UA:
            controls = 16'b1_x_11_0_100_0_0_0_xx_xxx;  // rd = PC + (imm << 12)
            `OP_TYPE_J:
            controls = 16'b1_x_11_0_101_0_1_0_xx_xxx;  // rd = PC + 4; PC+= imm
            `OP_TYPE_JI:
            controls = 16'b1_1_11_0_000_0_1_1_xx_xxx;  // rd = PC + 4; PC = rs1 + imm
            default: controls = 10'b0;
        endcase
    end

    always_comb begin : ALU_Control_Signal
        case (op)
            `OP_TYPE_R: begin  // R Type ALU operation
                ALUControl = {funct7[5], funct3};
                // 각 타입별로 ALU 동작이 funct7[5]와 funct3에 따라 달라짐
                // funct7, funct3 없는 type은 ALU 미사용
                /* case ({
                    funct7[5], funct3
                })
                    4'b0000: ALUControl = `ADD;
                    4'b1000: ALUControl = `SUB;
                    4'b0001: ALUControl = `SLL;
                    4'b0101: ALUControl = `SRL;
                    4'b1101: ALUControl = `SRA;
                    4'b0010: ALUControl = `SLT;
                    4'b0011: ALUControl = `SLTU;
                    4'b0100: ALUControl = `XOR;
                    4'b0110: ALUControl = `OR;
                    4'b0111: ALUControl = `AND;
                endcase */
            end
            `OP_TYPE_IL:
            ALUControl = {1'b0, 3'b000};  // IL-Type은 무조건 덧셈
            `OP_TYPE_I: begin       // I-Type Shift 연산과 산술,논리 연산 구분
                if ((funct3 == 3'b001) || (funct3 == 3'b101))  // Shift 연산
                    ALUControl = {funct7[5], funct3};
                else ALUControl = {1'b0, funct3};
            end
            `OP_TYPE_S:
            ALUControl = {1'b0, 3'b000};  // S-Type은 무조건 덧셈
            `OP_TYPE_B: ALUControl = {1'b0, funct3};
            `OP_TYPE_JI: ALUControl = {1'b0, funct3};
            default: ALUControl = 4'bx;
        endcase
    end
endmodule
