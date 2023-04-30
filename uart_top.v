`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2023 15:17:40
// Design Name: 
// Module Name: uart_top
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
* For 9600 baud with 100MHz FPGA clock: 
* 9600 * 16 = 153,600
* 100 * 10^6 / 153,600 = ~651      
* log2(651) = 10   
********* System clk = 100MHz************
______________________________________________
| Baudrate || BR_COUNT || BR_BITS=log2(COUNT) |
-----------||--------- ||---------------------
* 9600          651             10
* 19200         326             9
* 115200        52              6
* 1500          4167            13
*_____________________________________________
*/

module uart_top #(parameter
    DATA_BITS = 8,
    STOP_TICK = 16,
    BR_COUNT  = 651,
    BR_BITS   = 10,
    FIFO_EXP  = 4)(
    
    input clk, rst, 
    input read_uart, write_uart,         //Control signals
    input rx_data_in,                    //Serial in data
    input [DATA_BITS-1:0] write_data,    //Parallel Data from Tx-FIFO---> Display on 7-segment
    
    output rx_full, rx_empty, //tx_full,   //LEDs
    output tx_data_out,                  //Serial out data
    output [DATA_BITS-1:0] read_data     //Parallel Data to Rx-FIFO <---Switches 
    );
    
    //Interconnect wires
    wire tick;
    wire rx_done, tx_done;
    wire tx_fifo_empty, tx_fifo_not_empty;
    wire [DATA_BITS-1:0] tx_fifo_out, rx_fifo_in;
    
    //Connecting all modules
    baud_rate_generator #(.N(BR_BITS), .COUNT(BR_COUNT)) 
    baud_rate_gen_module (.clk(clk), .rst(rst), .tick(tick));
    
    uart_transmitter    #(.DATA_BITS(DATA_BITS), .STOP_TICK(STOP_TICK)) 
    uart_tx_module       (.clk(clk), .rst(rst), .tx_start(tx_fifo_not_empty), .sample_tick(tick), 
                          .data_in(tx_fifo_out), .tx_done(tx_done), .tx_data(tx_data_out));
                          
    uart_receiver       #(.DATA_BITS(DATA_BITS), .STOP_TICK(STOP_TICK)) 
    uart_rx_module       (.clk(clk), .rst(rst), .rx_data(rx_data_in), .sample_tick(tick), 
                          .data_out(rx_fifo_in), .data_ready(rx_done));
                          
    fifo                #(.DATA_SIZE(DATA_BITS), .ADDR_SIZE_EXP(FIFO_EXP)) 
    fifo_tx_module       (.clk(clk), .rst(rst), .rd_from_fifo(tx_done), .wr_to_fifo(write_uart),
                          .wr_data_in(write_data), .rd_data_out(tx_fifo_out), .empty(tx_fifo_empty), .full(tx_full));
    
    fifo                #(.DATA_SIZE(DATA_BITS), .ADDR_SIZE_EXP(FIFO_EXP)) 
    fifo_rx_module       (.clk(clk), .rst(rst), .rd_from_fifo(read_uart), .wr_to_fifo(rx_done),
                          .wr_data_in(rx_fifo_in), .rd_data_out(read_data), .empty(rx_empty), .full(rx_full));
    
    assign tx_fifo_not_empty = ~tx_fifo_empty;
    
endmodule
