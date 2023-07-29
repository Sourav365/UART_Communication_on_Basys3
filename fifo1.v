`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2023 10:42:15
// Design Name: 
// Module Name: fifo
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

module fifo #(parameter DATA_BIT=8, ADDR_EXP=3)(
  input [DATA_BIT-1:0] data_in,
  input clk, rst, wr, rd,
  output reg [DATA_BIT-1:0] data_out,
  output full, empty);
  
  //Define FIFO_RAM
  reg [DATA_BIT-1:0] fifo_ram [0:2**ADDR_EXP-1];
  
  //other variables
  reg [ADDR_EXP-1:0] rd_ptr, wr_ptr;
  reg [ADDR_EXP:0] fifo_count; //One extra bit required to check full/empty condition
  
  /******1. Full/Empty block****/
  assign empty = (fifo_count==0);
  assign full  = (fifo_count==2**ADDR_EXP);
  
  /******2. Write block****/
  always @(posedge clk) begin
    if(wr && !full)   fifo_ram[wr_ptr] <= data_in;
    else if(wr && rd) fifo_ram[wr_ptr] <= data_in;
  end

  /******3. Read block****/
  always @(posedge clk) begin
    if(rd && !empty)  data_out <= fifo_ram[rd_ptr];
    else if(wr && rd) data_out <= fifo_ram[rd_ptr];
  end
  
  /******4. Read/Write Pointer block****/
  always @(posedge clk) begin
    if(rst) begin rd_ptr <= 0; wr_ptr <= 0; end
    else begin
      wr_ptr <= ((wr && !full)  || (wr && rd)) ? (wr_ptr+1) : wr_ptr;
      rd_ptr <= ((rd && !empty) || (wr && rd)) ? (rd_ptr+1) : rd_ptr;
  end
  
  /******5. Counter block****/
    always @(posedge clk) begin
      if(rst) fifo_count <= 0;
      else begin
        case({rd,wr})
          2'b00: fifo_count <= fifo_count;
          2'b01: fifo_count <= (fifo_count==8) ? 8 : (fifo_count+1);
          2'b10: fifo_count <= (fifo_count==0) ? 0 : (fifo_count-1);
          2'b11: fifo_count <= fifo_count;
        endcase
      end
    end
endmodule
