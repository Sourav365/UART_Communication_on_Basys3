`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2023 19:21:01
// Design Name: 
// Module Name: uart_receiver
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

/*
*  Idle->Start->...Data.....->Stop->Idle
*   _____                      ______________
*        |_|-|-||-|-||-|-||-|-|
*/

module uart_receiver #(parameter DATA_BITS = 8, STOP_TICK = 16) //stop_tick=16(1-stop bit) or 32(2-stop bits)
    (
    input clk, rst,
    input rx_data,
    input sample_tick,
    output [DATA_BITS-1:0] data_out,
    output reg data_ready
    );

    //States
    localparam [1:0] idle  = 2'b00,
                     start = 2'b01,
                     data  = 2'b10,
                     stop  = 2'b11;
    
    //Temp reg.
    reg [1:0] state, state_next;            //In which state
    reg [3:0] tick_reg, tick_next;          //No. of ticks received
    reg [2:0] nbits_reg, nbits_next;        //No. of bits received
    reg [DATA_BITS-1:0] data_reg, data_next;//Reassembled data word
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= idle;
            tick_reg  <= 0;
            nbits_reg <= 0;
            data_reg  <= 0;
        end
        
        else begin
            state     <= state_next;
            tick_reg  <= tick_next;
            nbits_reg <= nbits_next;
            data_reg  <= data_next;
        end
    end
    
    always @ (*) begin
        //Initializing
        state_next = state;     
        tick_next  = tick_reg;
        nbits_next = nbits_reg;
        data_next  = data_reg;
        data_ready = 1'b0;
        
        case (state)
            idle :
                if(rx_data == 0) begin //Start condition--> data=0
                    state_next = start;
                    tick_next  = 0;
                end 
                
            start:
                if (sample_tick) begin
                    if(tick_reg == 7) begin     /// 7 is For setup time???????? check mid of start 
                        state_next = data;
                        tick_next  = 0;
                        nbits_next = 0;
                    end
                    else tick_next  = tick_reg+1;
                end
                
            data :
                if(sample_tick) begin
                    if(tick_reg == 15) begin        // check at mid of data
                        tick_next  = 0;
                        data_next  = {rx_data, data_reg[DATA_BITS-1:1]};    //SIPO shift reg.
                        if(nbits_reg == (DATA_BITS-1))      //When all bits are received 
                            state_next = stop;
                        else
                            nbits_next = nbits_reg+1;       //Increase no of bits count
                    end
                    else tick_next  = tick_reg+1;           //Increase count value of tick
                end
                
            stop :
                if (sample_tick) begin
                    if(tick_reg == (STOP_TICK-1)) begin     //Check for end of stop bit
                        state_next = idle;
                        data_ready = 1'b1;
                    end
                    else tick_next  = tick_reg+1;
                end
        endcase
    end
    
    //Final output
    assign data_out = data_reg;
endmodule
