`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2024 11:25:46 PM
// Design Name: 
// Module Name: row_column_fetcher_vector_tb
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


module row_column_fetcher_vector_tb;

localparam MATRIX_A_MEM_DEPTH = 16;
localparam MATRIX_A_ROWS      = 2; 
localparam MATRIX_A_COLUMNS   = 8; 
localparam MATRIX_B_MEM_DEPTH = 8;
localparam MATRIX_B_ROWS      = 8; 
localparam MATRIX_B_COLUMNS   = 1;  
localparam MATRIX_MEM_WIDTH   = 32;

logic clk, rst_n;
logic memory_filled;

// Matirx A memory
logic [MATRIX_MEM_WIDTH-1:0] memory_a [MATRIX_A_MEM_DEPTH-1:0];
logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] rd_address_a;
logic [MATRIX_MEM_WIDTH-1:0] read_data_a;

// Matirx B memory
logic [MATRIX_MEM_WIDTH-1:0] memory_b [MATRIX_B_MEM_DEPTH-1:0];
logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] rd_address_b;
logic [MATRIX_MEM_WIDTH-1:0] read_data_b;

//Mult 
logic [MATRIX_MEM_WIDTH-1:0] mult_a;
logic [MATRIX_MEM_WIDTH-1:0] mult_b;
logic mult_start;
logic [MATRIX_MEM_WIDTH-1:0] mult_out;
logic mult_done;

assign read_data_a = memory_a[rd_address_a];
assign read_data_b = memory_b[rd_address_b];

initial begin
        $readmemh("memory_C.mem", memory_a);
        $readmemh("memory_D_vector.mem", memory_b);
        
        rst_n <= 0; memory_filled <= 0; #10;
        rst_n <= 1; #10;
        
        memory_filled <= 1; #10;
        memory_filled <= 0; #10;
        
end



always begin
    clk <= 1; #5;
    clk <= 0; #5;
end




// Instantiate row_column_fetcher
row_column_fetcher #(
    .MATRIX_A_MEM_DEPTH(MATRIX_A_MEM_DEPTH), 
    .MATRIX_A_ROWS(MATRIX_A_ROWS), 
    .MATRIX_A_COLUMNS(MATRIX_A_COLUMNS), 
    .MATRIX_B_MEM_DEPTH(MATRIX_B_MEM_DEPTH), 
    .MATRIX_B_ROWS(MATRIX_B_ROWS), 
    .MATRIX_B_COLUMNS(MATRIX_B_COLUMNS), 
    .MATRIX_MEM_WIDTH(MATRIX_MEM_WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .memory_filled(memory_filled),
    .rd_address_a(rd_address_a),
    .read_data_a(read_data_a),
    .rd_address_b(rd_address_b),
    .read_data_b(read_data_b),
    .mult_a(mult_a),
    .mult_b(mult_b),
    .mult_start(mult_start),
    .mult_out(mult_out),
    .mult_done(mult_done)
);


endmodule
