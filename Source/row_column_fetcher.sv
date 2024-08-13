`timescale 1ns / 1ps
module row_column_fetcher #(
    parameter 
    MATRIX_A_MEM_DEPTH = 64, 
    MATRIX_A_ROWS = 8, 
    MATRIX_A_COLUMNS = 8, 
    
    MATRIX_B_MEM_DEPTH = 64, 
    MATRIX_B_ROWS = 8, 
    MATRIX_B_COLUMNS = 8, 
    
    MATRIX_MEM_WIDTH = 32
    )(
    input logic clk,
    input logic rst_n,
    
    input memory_filled,
    output logic new_row_a,
    output logic new_column_a,
    logic done_a,
    
    output logic new_row_b,
    output logic new_column_b,
    output logic done_b,
    
    
    // Matirx A memory
    output logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] rd_address_a,
    input logic [MATRIX_MEM_WIDTH-1:0] read_data_a,
    
    // Matirx B memory
    output logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] rd_address_b,
    input logic [MATRIX_MEM_WIDTH-1:0] read_data_b,
    
    //Mult 1
    output logic [MATRIX_MEM_WIDTH-1:0] mult_1_a,
    output logic [MATRIX_MEM_WIDTH-1:0] mult_1_b,
    output logic mult_1_en,
    input logic [MATRIX_MEM_WIDTH-1:0] mult_1_out,
    input logic mult_1_busy,
    
    //Mult 2
    output logic [MATRIX_MEM_WIDTH-1:0] mult_2_a,
    output logic [MATRIX_MEM_WIDTH-1:0] mult_2_b,
    output logic mult_2_en,
    input logic [MATRIX_MEM_WIDTH-1:0] mult_2_out,
    input logic mult_2_busy,
    
    //Mult 3
    output logic [MATRIX_MEM_WIDTH-1:0] mult_3_a,
    output logic [MATRIX_MEM_WIDTH-1:0] mult_3_b,
    output logic mult_3_en,
    input logic [MATRIX_MEM_WIDTH-1:0] mult_3_out,
    input logic mult_3_busy,
    
    //Mult 4
    output logic [MATRIX_MEM_WIDTH-1:0] mult_4_a,
    output logic [MATRIX_MEM_WIDTH-1:0] mult_4_b,
    output logic mult_4_en,
    input logic [MATRIX_MEM_WIDTH-1:0] mult_4_out,
    input logic mult_4_busy
);

typedef enum logic [0:0] {
    IDLE,
    COUNT
} state_t;

state_t state, next_state;

logic [$clog2(MATRIX_A_MEM_DEPTH) -1:0] counter_a;
logic [$clog2(MATRIX_A_ROWS)-1:0] row_counter_a;
logic [$clog2(MATRIX_A_COLUMNS)-1:0] column_counter_a;

logic [$clog2(MATRIX_B_MEM_DEPTH) -1:0] counter_b;
logic [$clog2(MATRIX_B_ROWS)-1:0] row_counter_b;
logic [$clog2(MATRIX_B_COLUMNS)-1:0] column_counter_b;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        counter_a <= 'b0;
        row_counter_a <= 'b0;
        column_counter_a <= 'b0;
        counter_b <= 'b0;
        row_counter_b <= 'b0;
        column_counter_b <= 'b0;
    end
    else begin
        state <= next_state;
    end
end


always_ff @(posedge clk) begin
    case(state)
        IDLE: begin 
        end
        COUNT: begin
            if(row_counter_a == MATRIX_A_ROWS - 1) begin
                row_counter_a <= 'b0;
                new_row_a <= 1'b1;
            end
            else begin
                row_counter_a <= row_counter_a <= 'b1;
            end
            
            
            if(column_counter_a == MATRIX_A_COLUMNS - 1) begin
                column_counter_a <= 'b0;
                new_column_a <= 1'b1;
            end
            else begin
                column_counter_a <= column_counter_a <= 'b1;
            end
            
            
            if(counter_a == MATRIX_A_MEM_DEPTH - 1) begin
                counter_a <= 'b0;
                done_a <= 1'b1;
            end
            else begin
                counter_a <= counter_a <= 'b1;
            end
            
            
            if(row_counter_b == MATRIX_B_ROWS - 1) begin
                row_counter_b <= 'b0;
                new_row_b <= 1'b1;
            end
            else begin
                row_counter_b <= row_counter_b <= 'b1;
            end
               
                
            if(column_counter_b == MATRIX_B_COLUMNS - 1) begin
                column_counter_b <= 'b0;
                new_column_b <= 1'b1;
            end
            else begin 
                column_counter_b <= column_counter_b <= 'b1;
            end
            
            
            if(counter_b == MATRIX_B_MEM_DEPTH - 1) begin 
                counter_b <= 'b0;
                done_b <= 1'b1;
            end
            else begin 
                counter_b <= counter_b <= 'b1;
            end
        end
    endcase
end


endmodule
