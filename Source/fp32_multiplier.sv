`timescale 1ns / 1ps

module fp32_mult_pipelined(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [31:0] a,       // 32-bit floating-point input a
    input logic [31:0] b,       // 32-bit floating-point input b
    output logic [31:0] result, // 32-bit floating-point output result
    output logic done,          // Signal indicating the multiplication is done
    output logic overflow,      // Overflow flag
    output logic underflow      // Underflow flag
);

logic [5:0] leading_zeros;

    // Stage 1: Extract components and prepare for multiplication
    typedef struct {
        logic sign_a, sign_b;
        logic [7:0] exponent_a, exponent_b;
        logic [23:0] mantissa_a, mantissa_b;
        logic enable;
    } stage1_data_t;

    stage1_data_t stage1_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_reg <= {default: 'b0};
        end else if (start) begin
            stage1_reg.sign_a <= a[31];
            stage1_reg.sign_b <= b[31];
            stage1_reg.exponent_a <= a[30:23];
            stage1_reg.exponent_b <= b[30:23];
            stage1_reg.mantissa_a <= {1'b1, a[22:0]}; // Add implicit leading 1
            stage1_reg.mantissa_b <= {1'b1, b[22:0]};
            stage1_reg.enable <= 1'b1;
        end
        else begin
            stage1_reg <= {default: 'b0};
        end
    end

    // Stage 2: Multiply mantissas and add exponents
    typedef struct {
        logic sign_result;
        logic [7:0] exponent_sum;  // 9 bits to handle overflow
        logic [47:0] mantissa_mult;
        logic enable;
    } stage2_data_t;

    stage2_data_t stage2_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !stage1_reg.enable) begin
            stage2_reg <= {default: 'b0};
        end else begin
            stage2_reg.sign_result <= stage1_reg.sign_a ^ stage1_reg.sign_b;
            stage2_reg.exponent_sum <= stage1_reg.exponent_a + stage1_reg.exponent_b - 8'd127;
            stage2_reg.mantissa_mult <= stage1_reg.mantissa_a * stage1_reg.mantissa_b;
            stage2_reg.enable <= 1'b1;
        end
    end

    // Stage 3: Normalize and prepare final result
    typedef struct {
        logic sign_result;
        logic [7:0] exponent_result;
        logic [22:0] mantissa_result;
        logic enable;
    } stage3_data_t;

    stage3_data_t stage3_reg;

    logic [47:0] mantissa_mult_shifted;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !stage2_reg.enable) begin
            stage3_reg <=  {default: 'b0};
        end else begin
            stage3_reg.enable <= 1'b1;
            stage3_reg.sign_result <= stage2_reg.sign_result;
            if(stage2_reg.mantissa_mult [47] == 1'b1) begin
                stage3_reg.exponent_result <= stage2_reg.exponent_sum + 8'b1;
                stage3_reg.mantissa_result <= stage2_reg.mantissa_mult [46:24];
            end
            else begin 
                stage3_reg.exponent_result <= stage2_reg.exponent_sum;
                stage3_reg.mantissa_result <= stage2_reg.mantissa_mult [45:23];
            end
            
            
        end
    end

    // Final output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !stage3_reg.enable) begin
            result <= 'b0;
            done <= 1'b0;
            overflow <= 1'b0;
            underflow <= 1'b0;
        end else begin
            result <= {stage3_reg.sign_result, stage3_reg.exponent_result, stage3_reg.mantissa_result};
            done <= 1'b1;
            overflow <= (stage3_reg.exponent_result >= 255);
            underflow <= (stage3_reg.exponent_result <= 0);
        end
    end
    



endmodule