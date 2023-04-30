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


module fifo #(parameter DATA_SIZE = 8, ADDR_SIZE_EXP = 4)(
    input  clk, rst,
    input  rd_from_fifo, wr_to_fifo,
    input  [DATA_SIZE-1:0] wr_data_in,
    output [DATA_SIZE-1:0] rd_data_out,
    output empty, full
    );
    
    //Memory reg bank RAM
    reg [DATA_SIZE-1:0] mem [2**ADDR_SIZE_EXP-1:0];
    
    reg [ADDR_SIZE_EXP-1:0] curr_wr_addr, curr_wr_addr_buff, next_wr_addr;
    reg [ADDR_SIZE_EXP-1:0] curr_rd_addr, curr_rd_addr_buff, next_rd_addr;
    reg fifo_full, fifo_empty, full_buff, empty_buff;
    wire write_en;
    
    
    //Memory Write
    always @(posedge clk)
        if(write_en) mem[curr_wr_addr] <= wr_data_in;
        
    //Memory Read
    assign rd_data_out = mem[curr_rd_addr];   
    
    //reite_en active when write_to_fifo active AND fifo is not full
    assign write_en = wr_to_fifo & (~fifo_full);
    
    
    /////////////////////////////////////////////////////////
    always @(posedge clk or posedge rst)
        if (rst) begin
            curr_wr_addr <= 0;
            curr_rd_addr <= 0;
            fifo_full    <= 1'b0; //not full
            fifo_empty   <= 1'b1; //empty
        end
        else begin
            curr_wr_addr <= curr_wr_addr_buff;
            curr_rd_addr <= curr_rd_addr_buff;
            fifo_full    <= full_buff; 
            fifo_empty   <= empty_buff;
        end
    
    always @ (*) begin
        next_wr_addr = curr_wr_addr + 1;
        next_rd_addr = curr_rd_addr + 1;
        
        // default: keep old values
		curr_wr_addr_buff = curr_wr_addr;
		curr_rd_addr_buff = curr_rd_addr;
		full_buff  = fifo_full;
		empty_buff = fifo_empty;
		
		//Condition on Write-Read enable 
		case({wr_to_fifo, rd_from_fifo})
		  //2'b00: //No enable signal!--> Do nothing
		  2'b01: //Read enabled
		      if(~fifo_empty) begin                   //Some data is present in FIFO
		          curr_rd_addr_buff = next_rd_addr;
		          full_buff = 1'b0;                   //After read, FIFO not full
		          if(next_rd_addr == curr_wr_addr)    //Empty Condition
		              empty_buff = 1'b1; 
		      end
		      
		  2'b10: //Write enabled
		      if(~fifo_full) begin                     //Some space is present in FIFO to write
		          curr_wr_addr_buff = next_wr_addr;
		          empty_buff = 1'b0;                   //After write, FIFO not empty
		          if(next_wr_addr == curr_rd_addr)     //Full Condition
		              full_buff = 1'b1; 
		      end
		      
		  2'b11: //Both Write and Read enabled
		      begin
		      curr_wr_addr_buff = next_wr_addr;
		      curr_rd_addr_buff = next_rd_addr;
		      end
		endcase
    end
    
    //Output
    assign full  = fifo_full;
    assign empty = fifo_empty;
endmodule
