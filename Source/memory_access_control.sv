`timescale 1ns / 1ps
module memory_access_control #(parameter MATRIX_A_MEM_DEPTH = 64, MATRIX_B_MEM_DEPTH = 64, MATRIX_MEM_WIDTH = 32)(
    input logic clk,
    input logic rst_n,
    // All clocks are the same
    
    // Matirx A memory
    input logic wr_clk_a,
    output logic [$clog2(MATRIX_A_MEM_DEPTH)-1:0] wr_address_a,
    output logic [MATRIX_MEM_WIDTH-1:0] write_data_a,
    output logic write_en_a,
    
    // Matirx B memory
    input logic wr_clk_b,
    output logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] wr_address_b,
    output logic [MATRIX_MEM_WIDTH-1:0] write_data_b,
    output logic write_en_b,
    
    // Input stream
    input logic data_valid,
    input logic [31:0] data
);
 
typedef enum logic [0:0] {
    FILL_MEM_A,
    FILL_MEM_B 
} state_t;

state_t state, next_state;

logic [$clog2(MATRIX_A_MEM_DEPTH) -1:0] addr_a;
logic [$clog2(MATRIX_B_MEM_DEPTH)-1:0] addr_b;



always_ff @(posedge clk) begin
    if(!rst_n) begin
        addr_a <=  'b0;
        addr_b <= 'b0;
        state <= FILL_MEM_A;
    end 
    else begin
        state <= next_state;
        if(data_valid) begin
            if(state == FILL_MEM_A) begin
                addr_a <= addr_a + 'b1;
            end
            else if(state == FILL_MEM_B) begin
                addr_b <= addr_b + 'b1; 
            end    
         end
    end
end

always_ff @(posedge clk) begin
    write_en_a <= 1'b0;
    write_en_b <= 1'b0;
    write_data_a <= 'b0;
    write_data_b <= 'b0;
    if (data_valid) begin
        case (state)
            FILL_MEM_A: begin
                wr_address_a <= addr_a;
                write_data_a <= data;
                write_en_a <= 1'b1;
            end
            FILL_MEM_B: begin
                wr_address_b <= addr_b;
                write_data_b <= data;
                write_en_b <= 1'b1;
            end
        endcase
    end
end

always_comb begin
    next_state = state;
    case (state)
        FILL_MEM_A: begin
            if (addr_a == MATRIX_A_MEM_DEPTH - 1) begin
                next_state = FILL_MEM_B;
            end
        end
        FILL_MEM_B: begin
            if (addr_b == MATRIX_B_MEM_DEPTH - 1) begin
                next_state = FILL_MEM_A;
            end
        end
    endcase
end

endmodule
