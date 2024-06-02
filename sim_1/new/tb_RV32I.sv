`timescale 1ns / 1ps

module tb_RV32I ();

    logic clk;
    logic reset;


    RV32I dut (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1'b1;
        #40 reset = 1'b0;
    end
endmodule



// module ALU_test;

//     // Inputs
//     reg [31:0] a;
//     reg [31:0] b;
//     reg [3:0] ALUControl;

//     // Outputs
//     wire [31:0] result;
//     wire btaken;

//     // Instantiate the ALU
//     ALU uut (
//         .a(a), 
//         .b(b), 
//         .ALUControl(ALUControl), 
//         .btaken(btaken), 
//         .result(result)
//     );

//     initial begin
//         // Initialize Inputs
//         a = 32'hf0000000;
//         b = 32'd4;
//         ALUControl = 4'b1101;

//         // Wait for the result
//         #10;
//         $display("Result: %h", result);

//         // Finish the simulation
//         $finish;
//     end
// endmodule
