`timescale 1ns / 1ps
module matrix_multiplier #(parameter MATRIX_A_M = 8, MATRIX_A_N = 8, MATRIX_B_M = 8, MATRIX_B_N = 8)(
    input logic clk,
    input logic reset,
    
    // The Master will output the multipled matrix
    // The Slave will input the two source matrices 
    // Matrix A should be sent first left to right, up to down
    
    // AXI Master
    output logic m_axis_valid,
    input logic m_axis_ready,
    output logic m_axis_data,
    output logic m_axis_last,
    // AXI Slave
    input logic s_axis_valid,
    output logic s_axis_ready,
    input logic s_axis_data,
    input logic s_axis_last
);

// Matrix memory paramters 
localparam MATRIX_A_MEM_DEPTH = MATRIX_A_M * MATRIX_A_N;
localparam MATRIX_B_MEM_DEPTH = MATRIX_B_M * MATRIX_B_N;
localparam MATRIX_C_MEM_DEPTH = MATRIX_A_M * MATRIX_B_N;
localparam MATRIX_MEM_WIDTH = 32;

// Matirx A memory
logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] wr_address_a;
logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] rd_address_a;
logic [MATRIX_MEM_WIDTH-1:0] write_data_a;
logic [MATRIX_MEM_WIDTH-1:0] read_data_a;
logic write_en_a;

// Matirx B memory
logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] wr_address_b;
logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] rd_address_b;
logic [MATRIX_MEM_WIDTH-1:0] write_data_b;
logic [MATRIX_MEM_WIDTH-1:0] read_data_b;
logic write_en_b;

// Matirx C memory
logic [$clog2(MATRIX_C_MEM_DEPTH)-1:0] wr_address_c;
logic [$clog2(MATRIX_C_MEM_DEPTH)-1:0] rd_address_c;
logic [MATRIX_MEM_WIDTH-1:0] write_data_c;
logic [MATRIX_MEM_WIDTH-1:0] read_data_c;
logic write_en_c;
   
// Matirx A memory  
dual_port_ram #(MATRIX_A_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_a(
    .wr_clk(clk),
    .rd_clk(clk),
    .reset(reset),
    .wr_address(wr_address_a),
    .rd_address(rd_address_a),
    .write_data(write_data_a),
    .read_data(read_data_a),
    .write_en(write_en_a)
);

// Matirx B memory  
dual_port_ram #(MATRIX_B_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_b(
    .wr_clk(clk),
    .rd_clk(clk),
    .reset(reset),
    .wr_address(wr_address_b),
    .rd_address(rd_address_b),
    .write_data(write_data_b),
    .read_data(read_data_b),
    .write_en(write_en_b)
);

// Matirx B memory  
dual_port_ram #(MATRIX_C_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_c(
    .wr_clk(clk),
    .rd_clk(clk),
    .reset(reset),
    .wr_address(wr_address_c),
    .rd_address(rd_address_c),
    .write_data(write_data_c),
    .read_data(read_data_c),
    .write_en(write_en_c)
);
    
endmodule
