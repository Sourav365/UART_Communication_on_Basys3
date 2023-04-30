`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2023 00:47:05
// Design Name: 
// Module Name: uart_transmitter
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

module uart_transmitter #(parameter DATA_BITS = 8, STOP_TICK = 16) //stop_tick=16(1-stop bit) or 32(2-stop bits)
    (
    input clk, rst,
    input tx_start, // Extra signal
    input sample_tick,
    input [DATA_BITS-1:0] data_in,
    output reg tx_done,
    output tx_data
    );

    //States
    localparam [1:0] idle  = 2'b00,
                     start = 2'b01,
                     data  = 2'b10,
                     stop  = 2'b11;
    
    //Temp reg.
    reg [1:0] state, state_next;            //In which state
    reg [3:0] tick_reg, tick_next;          //No. of ticks received from baud-rate generator
    reg [2:0] nbits_reg, nbits_next;        //No. of bits transmitted in data state
    reg [DATA_BITS-1:0] data_reg, data_next;//Assembled data word to transmitt serially
    reg tx_reg, tx_next;                    //Intermideate output data
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= idle;
            tick_reg  <= 0;
            nbits_reg <= 0;
            data_reg  <= 0;
            tx_reg    <= 1'b1; //Ideal case--> 1
        end
        
        else begin
            state     <= state_next;
            tick_reg  <= tick_next;
            nbits_reg <= nbits_next;
            data_reg  <= data_next;
            tx_reg    <= tx_next;
        end
    end
    
    always @ (*) begin
        //Initialize 
        state_next  = state;
        tick_next   = tick_reg;
        nbits_next  = nbits_reg;
        data_next   = data_reg;
        tx_next     = tx_reg;
        tx_done     = 1'b0;
        
        case (state)
            idle : begin
                tx_next = 1'b1;             //transmit Idle-->1
                if(tx_start) begin          //When FIFO not empty!
                    state_next = start;
                    tick_next  = 0;
                    data_next  = data_in;   //Store data from FIFO
                end
            end
            
            start: begin
                tx_next = 1'b0;             //Start bit --> 0
                if(sample_tick) begin
                    if(tick_reg == 15) begin    //Check for 16th ticks
                        state_next = data;
                        tick_next  = 0;
                        nbits_next = 0;
                    end
                    else tick_next = tick_reg + 1;
                end
            end
            
            data : begin
                tx_next = data_reg[0];                      //0th position data is taken from parallel data
                if(sample_tick) begin
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = data_reg >> 1;          //Parallel data is shifted
                        if(nbits_reg == (DATA_BITS-1))
                            state_next = stop;
                        else
                            nbits_next = nbits_reg + 1;
                    end
                    else tick_next = tick_reg + 1;
                end
            end
            
            stop : begin
                tx_next = 1'b1;     //Stop bit --> 1
                if(sample_tick) begin
                    if(tick_reg == (STOP_TICK-1)) begin
                        state_next = idle;
                        tx_done    = 1'b1;
                    end
                    else tick_next = tick_reg + 1;
                end
            end
        endcase
    end
    
    //Final output
    assign tx_data = tx_reg;
endmodule