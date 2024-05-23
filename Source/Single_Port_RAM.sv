`timescale 1ns / 1ps
module Single_Port_RAM #(
    parameter  MEM_DEPTH = 256,
    parameter  MEM_WIDTH = 32
)(
    input logic clk,
    input logic reset,
    input logic [$clog2(MEM_DEPTH)-1:0] address,
    output logic [MEM_WIDTH-1:0] write_data, read_data,
    input logic write_en

);
    
logic [MEM_WIDTH-1:0] memory [MEM_DEPTH];

 
always @(posedge  clk) begin
    if(write_en) begin
    memory[address] <= write_data;
    end
    read_data <= memory[address];
end // always

endmodule

