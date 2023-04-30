`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2023 09:37:23
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_rate_generator #(parameter N=10, COUNT=651)(//count=100MHz_clk/(16*9600)=651-->Min bit required = 10 
    input clk, rst,
    output tick
    );
    
    //Count reg.
    reg [N-1:0]  count_value;
    wire [N-1:0] count_next;
    
    always @(posedge clk or posedge rst) begin
        if(rst) count_value <= 0;
        else    count_value <= count_next;
    end
    
    assign count_next = (count_value == (COUNT-1)) ? 0 : (count_value + 1);
    assign tick = (count_value == (COUNT-1)) ? 1'b1 : 1'b0;
    
endmodule
