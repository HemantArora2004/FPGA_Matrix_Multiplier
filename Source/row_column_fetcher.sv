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

localparam row_offset_width = $clog2((MATRIX_B_ROWS-1)*(MATRIX_B_COLUMNS-1))-1;
localparam counter_width = $clog2(MATRIX_A_ROWS)+$clog2(MATRIX_B_COLUMNS)+$clog2(MATRIX_B_ROWS)-1;

// One counter, bit slicing is used to figure out what row/column is currently being processed  
logic [counter_width:0] counter;
logic [row_offset_width:0] row_offset; // Offset to get the correct row when going though columns in matrix B


always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        counter <= 'b0;
        row_offset <= 'b0;
    end
    else begin
        state <= next_state;
        if(counter == '1) counter <= 'b0;
        else counter <= counter <= 'b1; 
        if(counter [MATRIX_B_ROWS-1:0] == '0) row_offset <= '0;
        else row_offset <= row_offset + row_offset_width'(MATRIX_B_ROWS - 1);
    end
end


always_ff @(posedge clk) begin
    case(state)
        IDLE: begin 
        end
        COUNT: begin
            rd_address_a <= counter[counter_width :counter_width-$clog2(MATRIX_A_ROWS)+1] + counter [MATRIX_B_ROWS-1:0];
            rd_address_b <= counter[counter_width-$clog2(MATRIX_A_ROWS):counter_width-$clog2(MATRIX_A_ROWS)-$clog2(MATRIX_B_COLUMNS)+1] + counter [MATRIX_B_ROWS-1:0];
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
            if(counter == '1) begin
                next_state = IDLE;
            end
        end
    endcase
end

endmodule
