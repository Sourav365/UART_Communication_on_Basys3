`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2023 09:45:41
// Design Name: 
// Module Name: uart_test
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


module uart_test(
    input clk,       // basys 3 FPGA clock signal
    input reset,            // btnR    
    input rx,               // USB-RS232 Rx
    input btn,              // btnL (read and write FIFO operation)
    output tx,              // USB-RS232 Tx
    output [15:14] led1,    // FIFO full/Empty state indicator
    output [7:0] led        // data byte display
    );
    
    // Connection Signals
    wire rx_full, rx_empty, btn_tick;
    wire [7:0] rec_data, rec_data1;
    
    // Complete UART Core
    uart_top UART_UNIT
        (
        .clk(clk), .rst(reset), 
        .read_uart(btn_tick), .write_uart(btn_tick),         
        .rx_data_in(rx),                    
        .write_data(rec_data1),    
   
        .rx_full(rx_full), .rx_empty(rx_empty),// .tx_full(),   
        .tx_data_out(tx),                  
        .read_data(rec_data)
        );
    
    // Button Debouncer
    btn_debouncing BUTTON_DEBOUNCER
        (
            .clk(clk),
            .reset(reset),
            .btn(btn),         
            .db_level(),  
            .db_tick(btn_tick)
        );
    
    // Signal Logic    
    assign rec_data1 = rec_data;// Receive Same char as typed in tx window.
    
    // Output Logic
    assign led = rec_data;              // data byte received displayed on LEDs
    
    assign led1[14] = rx_full;
    assign led1[15] = rx_empty;
    
endmodule
