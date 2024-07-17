`timescale 1ns / 1ps
module dual_port_ram #(
    parameter  MEM_DEPTH = 256,
    parameter  MEM_WIDTH = 32
)(
    input logic wr_clk,
    input logic rd_clk,
    input logic reset,
    input logic [$clog2(MEM_DEPTH)-1:0] wr_address,
    input logic [$clog2(MEM_DEPTH)-1:0] rd_address,
    input logic [MEM_WIDTH-1:0] write_data,
    output logic [MEM_WIDTH-1:0] read_data,
    input logic write_en

);

// Memory array    
logic [MEM_WIDTH-1:0] memory [MEM_DEPTH];

always @(posedge  wr_clk) begin
    if(write_en) begin
    memory[wr_address] <= write_data;
    end
end // always

always @(posedge rd_clk) begin
    read_data <= memory[rd_address];
end //always 

endmodule

