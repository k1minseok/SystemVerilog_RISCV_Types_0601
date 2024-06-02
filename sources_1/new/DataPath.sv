`timescale 1ns / 1ps

`include "defines.sv"

module DataPath (
    input logic        clk,
    input logic        reset,
    input logic [31:0] machineCode,
    input logic        regFile_wr_en,
    input logic [ 3:0] ALUControl,
    input logic [31:0] dataMemRData,
    input logic [ 2:0] extType,
    input logic        AluSrcMuxSel,
    input logic [ 1:0] RFWriteDataSrcMuxSel,
    input logic        Bbranch,
    input logic        Jbranch,
    input logic        JIbranch,

    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData
);

    logic [31:0] w_ALUResult, w_RegFileRData1, w_RegFileRData2, w_PCAdderOut;
    logic [31:0] w_extendOut, w_AluSrcMuxOut, w_RFWirteDataSrcMuxOut;
    logic [31:0] w_PCAdderSrcMuxOut, w_PC_Data;
    logic [31:0] w_extendPcAddOut, w_ExtendPcAdderSrcMuxOut;
    logic w_PCAdderSrcMuxSel, w_btaken;


    assign dataMemRAddr = w_ALUResult;
    assign dataMemWData = w_RegFileRData2;

    Register U_ProgramCounter (  // prgram counter
        .clk  (clk),
        .reset(reset),
        .d    (w_PC_Data),

        .q(instrMemRAddr)
    );

    assign w_PCAdderSrcMuxSel = Jbranch | (Bbranch & w_btaken);
    mux_2x1 U_MUX_PCAdderSrc (
        .sel(w_PCAdderSrcMuxSel),
        .a  (32'd4),
        .b  (w_extendOut),

        .y(w_PCAdderSrcMuxOut)
    );

    adder U_Adder_ProgramCounter (
        .a(w_PCAdderSrcMuxOut),
        .b(instrMemRAddr),

        .y(w_PCAdderOut)
    );

    mux_2x1 U_MUX_PCSrc (
        .sel(JIbranch),
        .a  (w_PCAdderOut),
        .b  (w_ALUResult),

        .y(w_PC_Data)
    );

    RegisterFile U_RegisterFile (
        .clk   (clk),
        .wr_en (regFile_wr_en),
        .RAddr1(machineCode[19:15]),
        .RAddr2(machineCode[24:20]),
        .WAddr (machineCode[11:7]),
        .WData (w_RFWirteDataSrcMuxOut),

        .RData1(w_RegFileRData1),
        .RData2(w_RegFileRData2)
    );

    mux_2x1 U_MUX_ALUSrc (
        .sel(AluSrcMuxSel),
        .a  (w_RegFileRData2),
        .b  (w_extendOut),

        .y(w_AluSrcMuxOut)
    );

    ALU U_ALU (
        .a         (w_RegFileRData1),
        .b         (w_AluSrcMuxOut),
        .ALUControl(ALUControl),

        .btaken(w_btaken),
        .result(w_ALUResult)
    );

    mux_4x1 U_RFWriteDataSrcMux (
        .sel(RFWriteDataSrcMuxSel),
        .a  (w_ALUResult),
        .b  (dataMemRData),
        .c  (w_extendOut),
        .d  (w_extendPcAddOut),

        .y(w_RFWirteDataSrcMuxOut)
    );

    extend_imm U_Extend (
        .instr  (machineCode[31:7]),
        // .instr  (machineCode),
        .extType(extType),

        .immext(w_extendOut)
    );

    mux_2x1 U_MUX_ExtendPcAdderSrc (
        .sel(Jbranch),
        .a  (w_extendOut),
        .b  (32'd4),

        .y(w_ExtendPcAdderSrcMuxOut)
    );

    adder U_Adder_ExtendPc (
        .a(w_ExtendPcAdderSrcMuxOut),
        .b(instrMemRAddr),

        .y(w_extendPcAddOut)
    );
endmodule


module RegisterFile (
    input logic        clk,
    input logic        wr_en,
    input logic [ 4:0] RAddr1,
    input logic [ 4:0] RAddr2,
    input logic [ 4:0] WAddr,
    input logic [31:0] WData,

    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:31];  // 32bit 저장공간 32개

    initial begin  // 임의 초기값
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
    end

    always_ff @(posedge clk) begin
        if (wr_en) RegFile[WAddr] <= WData;
    end

    // address 0이면 0반환
    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;
endmodule


module Register (
    input logic        clk,
    input logic        reset,
    input logic [31:0] d,

    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin : register  // Flip-Flop형태
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end : register
    // : register -> 주석같은 느낌, 여기가 always문 끝이라는걸 나타냄, 없어도됨
endmodule


module ALU (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [ 3:0] ALUControl,

    output logic        btaken,
    output logic [31:0] result
);
    always_comb begin
        case (ALUControl)
            `ADD: result = a + b;
            `SUB: result = a - b;
            `SLL: result = a << b;
            `SRL: result = a >> b;
            `SRA: result = $signed(a) >>> b;
            // a를 sign으로 캐스팅하여 MSB 복제
            `SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU: result = (a < b) ? 1 : 0;
            `XOR: result = a ^ b;
            `OR: result = a | b;
            `AND: result = a & b;
            default: result = 32'bx;
        endcase
    end

    always_comb begin : comparator
        case (ALUControl[2:0])  // B-Type에서 funct3만 보면 됨
            3'b000:  btaken = (a == b);  // BEQ
            3'b001:  btaken = (a != b);  // BNE
            3'b100:  btaken = ($signed(a) < $signed(b));  // BLT
            3'b101:  btaken = ($signed(a) >= $signed(b));  // BGE
            3'b110:  btaken = (a < b);  // BLTU
            3'b111:  btaken = (a >= b);  //BGEU
            default: btaken = 1'bx;
        endcase
    end
endmodule


module adder (
    input logic [31:0] a,
    input logic [31:0] b,

    output logic [31:0] y
);
    assign y = a + b;
endmodule


// opcode제외 모든 신호 받아 imm bit만 빼내고 이 신호를 32비트로 늘림
module extend_imm (
    input logic [31:7] instr,
    input logic [ 2:0] extType,

    output logic [31:0] immext
);
    always_comb begin
        case (extType)
            3'b000: begin
                if ((instr[14:12] == 3'b001) || (instr[14:12] == 3'b101))
                    immext = {{27{instr[31]}}, instr[24:20]};  // I-Type shift
                else
                    immext = {
                        {21{instr[31]}}, instr[30:20]
                    };  // I-Type           
            end
            3'b001:
            immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-Type   
            3'b010:
            immext = {
                {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
            };  // B-Type
            3'b011:
            immext = {instr[31:12], 12'b0};  // U, UA-Type                     
            3'b100:
            immext = {
                {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0
            };  // J-Type               
            default: immext = 32'bx;
        endcase
    end
    // sign bit(최상위 bit) 확장
    // 양수이면 0으로 확장되고 음수이면 1로 확장됨
endmodule


module extend_dataMemWdata (
    input logic [31:7] instr,
    input logic [ 2:0] extType,

    output logic [31:0] immext
);
    always_comb begin
        case (extType)
            3'b000: begin
                if ((instr[14:12] == 3'b001) || (instr[14:12] == 3'b101))
                    immext = {{27{instr[31]}}, instr[24:20]};  // I-Type shift
                else
                    immext = {
                        {21{instr[31]}}, instr[30:20]
                    };  // I-Type           
            end
            3'b001:
            immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-Type   
            3'b010:
            immext = {
                {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
            };  // B-Type
            3'b011:
            immext = {instr[31:12], 12'b0};  // U, UA-Type                     
            3'b100:
            immext = {
                {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0
            };  // J-Type               
            default: immext = 32'bx;
        endcase
    end
    // sign bit(최상위 bit) 확장
    // 양수이면 0으로 확장되고 음수이면 1로 확장됨
endmodule


module mux_2x1 (
    input logic        sel,
    input logic [31:0] a,
    input logic [31:0] b,

    output logic [31:0] y
);
    always_comb begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 32'bx;
        endcase
    end
endmodule


module mux_4x1 (
    input logic [ 1:0] sel,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    input logic [31:0] d,

    output logic [31:0] y
);
    always_comb begin
        case (sel)
            2'b00:   y = a;
            2'b01:   y = b;
            2'b10:   y = c;
            2'b11:   y = d;
            default: y = 32'bx;
        endcase
    end
endmodule
