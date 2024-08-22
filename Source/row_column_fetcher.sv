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

    // Matirx A memory
    output logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] rd_address_a,
    input logic [MATRIX_MEM_WIDTH-1:0] read_data_a,
    
    // Matirx B memory
    output logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] rd_address_b,
    input logic [MATRIX_MEM_WIDTH-1:0] read_data_b,
    
    //Mult 
    output logic [MATRIX_MEM_WIDTH-1:0] mult_a,
    output logic [MATRIX_MEM_WIDTH-1:0] mult_b,
    output logic mult_start,
    input logic [MATRIX_MEM_WIDTH-1:0] mult_out,
    input logic mult_done
);

typedef enum logic [0:0] {
    IDLE,
    COUNT
} state_t;

state_t state, next_state;

localparam row_a_cnt_width    = $clog2(MATRIX_A_ROWS);
localparam row_a_offset_width = $clog2(MATRIX_A_MEM_DEPTH);
localparam col_b_cnt_width    = MATRIX_B_COLUMNS > 1 ? $clog2(MATRIX_B_COLUMNS) : 1;
localparam col_b_offset_width = $clog2(MATRIX_B_MEM_DEPTH);
localparam counter_width      = $clog2(MATRIX_B_ROWS);

logic [row_a_cnt_width-1:0] row_a_cnt; 
logic [row_a_offset_width-1:0] row_a_offset;
logic [col_b_cnt_width-1:0] col_b_cnt;
logic [col_b_offset_width-1:0] col_b_offset;
logic [counter_width-1:0] counter;


always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        row_a_cnt <= 'b0;
        row_a_offset <= 'b0;
        col_b_cnt <= 'b0;
        col_b_offset <= 'b0;
        counter <= 'b0;
    end
    else begin
        state <= next_state;
        if(state == COUNT) begin
            if(counter == MATRIX_B_ROWS-1) begin
                counter <= 'b0;
                col_b_offset <= 'b0;
                col_b_cnt <= col_b_cnt + 'b1;
            end
            else begin 
                counter <= counter + 'b1;
                col_b_offset <= col_b_offset + col_b_offset_width'(MATRIX_B_COLUMNS-1);
            end
            
            if(col_b_cnt == MATRIX_B_COLUMNS-1 && counter == MATRIX_B_ROWS-1) begin
                col_b_cnt <= 'b0;
                row_a_cnt <= row_a_cnt + 'b1;
                row_a_offset <= row_a_offset + row_a_offset_width'(MATRIX_A_COLUMNS);
            end

            
            if(row_a_cnt == MATRIX_A_ROWS-1 && col_b_cnt == MATRIX_B_COLUMNS-1 && counter == MATRIX_B_ROWS-1) begin
                row_a_cnt <= 'b0;
                row_a_offset <= 'b0;
                col_b_cnt <= 'b0;
                col_b_offset <= 'b0;
                counter <= 'b0;
            end
        end
    end
end


always_ff @(posedge clk) begin
    case(state)
        IDLE: begin 
            rd_address_a <= 'b0;
            rd_address_b <= 'b0;
        end
        COUNT: begin
            rd_address_a <= row_a_offset + counter;
            rd_address_b <= col_b_cnt + col_b_offset + counter;
        end
    endcase

end

always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (memory_filled == 1'b1) begin
                next_state = COUNT;
            end
        end
        COUNT: begin
            if(row_a_cnt == MATRIX_A_ROWS-1 && col_b_cnt == MATRIX_B_COLUMNS-1 && counter == MATRIX_B_ROWS-1) begin
                next_state = IDLE;
            end
        end
    endcase
end

endmodule
