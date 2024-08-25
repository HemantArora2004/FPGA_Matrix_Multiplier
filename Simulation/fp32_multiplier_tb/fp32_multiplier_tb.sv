`timescale 1ns / 1ps

module fp32_multiplier_tb;

localparam OPERANDS = 6;
localparam PRODUCTS = OPERANDS/2;
localparam MEM_WIDTH = 32;

logic [MEM_WIDTH-1:0] memory_operands [OPERANDS-1:0]; 
logic [MEM_WIDTH-1:0] memory_products [PRODUCTS-1:0]; 

logic error;

logic clk;
logic rst_n;
logic start;
logic [31:0] a;
logic [31:0] b;
logic [31:0] result;
logic done;

int operand_index;
int product_index;

initial begin
        $readmemh("memory_operands.mem", memory_operands);
        $readmemh("memory_products.mem", memory_products);
        start <= 1'b0;
        operand_index <= 0;
        product_index <= 0;
        rst_n <= 0; #10;
        rst_n <= 1; #10;
        
        while(operand_index < OPERANDS || product_index < PRODUCTS) begin
            if(operand_index < OPERANDS) begin
                start <= 1'b1;
                a <= memory_operands[operand_index];
                b <= memory_operands[operand_index + 1];
                operand_index = operand_index + 2;
            end
            
            if(done) begin
                product_index = product_index + 1;
                if(result != memory_products[product_index]) error <= 1'b1;
                else  error <= 1'b0;
            end
        end
        
        start <= 1'b0;
end





always begin
    clk <= 1; #5;
    clk <= 0; #5;
end







fp32_mult_pipelined dut(
    .clk(clk),              
    .rst_n(rst_n),          
    .start(start),         
    .a(a),                  
    .b(b),                  
    .result(result),        
    .done(done),           
    .overflow(overflow),   
    .underflow(underflow)   
);
endmodule