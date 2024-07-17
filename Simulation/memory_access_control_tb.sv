`timescale 1ns / 1ps
module memory_access_control_tb;

localparam MATRIX_A_MEM_DEPTH = 8;
localparam MATRIX_B_MEM_DEPTH = 8;
localparam MATRIX_MEM_WIDTH = 32;

// All clocks are the same
logic clk;
logic rst_n;


// Matirx A memory
logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] wr_address_a;
logic [MATRIX_MEM_WIDTH-1:0] write_data_a;
logic write_en_a;

// Matirx B memory
logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] wr_address_b;
logic [MATRIX_MEM_WIDTH-1:0] write_data_b;
logic write_en_b;

// Input stream
logic data_valid;
logic [31:0] data;

memory_access_control #(MATRIX_A_MEM_DEPTH, MATRIX_B_MEM_DEPTH, MATRIX_MEM_WIDTH) dut (
    .rst_n(rst_n),
    // All clocks are the same
    
    // Matirx A memory
    .wr_clk_a(clk),
    .wr_address_a(wr_address_a),
    .write_data_a(write_data_a),
    .write_en_a(write_en_a),
    
    // Matirx B memory
    .wr_clk_b(clk),
    .wr_address_b(wr_address_b),
    .write_data_b(write_data_b),
    .write_en_b(write_en_b),
    
    // Input stream
    .data_clk(clk),
    .data_valid(data_valid),
    .data(data)
);

initial begin
      
        rst_n <= 0; data_valid <= 0; #10;
        rst_n <= 1; #10;
        
        // Mem A
        data_valid <= 1'b1; data <= 32'hA001_100F; #10;
        data_valid <= 1'b1; data <= 32'hB002_200E; #10;
        data_valid <= 1'b1; data <= 32'hC003_300D; #10;
        data_valid <= 1'b1; data <= 32'hD004_400C; #10;
        
        data_valid <= 1'b0; #20;
        
        data_valid <= 1'b1; data <= 32'hE005_500B; #10;
        data_valid <= 1'b1; data <= 32'hF006_600A; #10;
        data_valid <= 1'b1; data <= 32'hA007_700F; #10;
        data_valid <= 1'b1; data <= 32'hB008_800E; #10;
        
        //Mem B
        data_valid <= 1'b1; data <= 32'hA001_100F; #10;
        data_valid <= 1'b1; data <= 32'hB002_200E; #10;
        data_valid <= 1'b1; data <= 32'hC003_300D; #10;
        data_valid <= 1'b1; data <= 32'hD004_400C; #10;
        
        data_valid <= 1'b0; #20;
        
        data_valid <= 1'b1; data <= 32'hE005_500B; #10;
        data_valid <= 1'b1; data <= 32'hF006_600A; #10;
        data_valid <= 1'b1; data <= 32'hA007_700F; #10;
        data_valid <= 1'b1; data <= 32'hB008_800E; #10;
       
        
        data_valid <= 0;       
end

// 100MHz clock
always begin
    clk <= 1; #5;
    clk <= 0; #5;
end



endmodule
