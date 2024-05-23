`timescale 1ns / 1ps
module Matrix_Multiplier(
    input logic CLK,
    input logic RESET,
    
    // The Master will output the multipled matrix
    // The Slave will input the two source matrices 
    
    // AXI Master
    output logic M_AXIS_VALID,
    input logic M_AXIS_READY,
    output logic M_AXIS_DATA,
    output logic M_AXIS_LAST,
    // AXI Slave
    input logic S_AXIS_VALID,
    output logic S_AXIS_READY,
    input logic S_AXIS_DATA,
    input logic S_AXIS_LAST
);

// Matrix memory paramters 
localparam MATRIX_MEM_DEPTH = 1024;
localparam MATRIX_MEM_WIDTH = 32;

// Matirx A memory
logic [$clog2(MATRIX_MEM_DEPTH)-1:0] address_a;
logic [MATRIX_MEM_WIDTH-1:0] write_data_a;
logic [MATRIX_MEM_WIDTH-1:0] read_data_a;
logic write_en_a;

// Matirx B memory
logic [$clog2(MATRIX_MEM_DEPTH)-1:0] address_b;
logic [MATRIX_MEM_WIDTH-1:0] write_data_b;
logic [MATRIX_MEM_WIDTH-1:0] read_data_b;
logic write_en_b;

// Matirx C memory
logic [$clog2(MATRIX_MEM_DEPTH)-1:0] address_c;
logic [MATRIX_MEM_WIDTH-1:0] write_data_c;
logic [MATRIX_MEM_WIDTH-1:0] read_data_c;
logic write_en_c;
   
// Matirx A memory  
Single_Port_RAM #(MATRIX_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_a(
    .clk(CLK),
    .reset(RESET),
    .address(address_a),
    .write_data(write_data_a),
    .read_data(read_data_a),
    .write_en(write_en_a)
);

// Matirx B memory  
Single_Port_RAM #(MATRIX_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_b(
    .clk(CLK),
    .reset(RESET),
    .address(address_b),
    .write_data(write_data_b),
    .read_data(read_data_b),
    .write_en(write_en_b)
);

// Matirx B memory  
Single_Port_RAM #(MATRIX_MEM_DEPTH, MATRIX_MEM_WIDTH)  ram_c(
    .clk(CLK),
    .reset(RESET),
    .address(address_c),
    .write_data(write_data_c),
    .read_data(read_data_c),
    .write_en(write_en_c)
);
    
endmodule
