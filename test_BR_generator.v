`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2023 22:25:26
// Design Name: 
// Module Name: test_BR_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_BR_generator();

    reg clk, rst;
    wire tick;
    baud_rate_generator uut (clk, rst, tick);
    
    always #5 clk = ~clk;
    initial begin
        clk=0; rst=1;
        #4; rst=0;
    end
endmodule
