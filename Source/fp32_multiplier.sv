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

    // Stage 1: Extract components and prepare for multiplication
    typedef struct {
        logic sign_a, sign_b;
        logic [7:0] exponent_a, exponent_b;
        logic [23:0] mantissa_a, mantissa_b;
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
        end
    end

    // Stage 2: Multiply mantissas and add exponents
    typedef struct {
        logic sign_result;
        logic [8:0] exponent_sum;  // 9 bits to handle overflow
        logic [47:0] mantissa_mult;
    } stage2_data_t;

    stage2_data_t stage2_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage2_reg <= {default: 'b0};
        end else begin
            stage2_reg.sign_result <= stage1_reg.sign_a ^ stage1_reg.sign_b;
            stage2_reg.exponent_sum <= stage1_reg.exponent_a + stage1_reg.exponent_b - 127;
            stage2_reg.mantissa_mult <= stage1_reg.mantissa_a * stage1_reg.mantissa_b;
        end
    end

    // Stage 3: Normalize and prepare final result
    typedef struct {
        logic sign_result;
        logic [7:0] exponent_result;
        logic [22:0] mantissa_result;
    } stage3_data_t;

    stage3_data_t stage3_reg;

    logic [47:0] mantissa_mult_shifted;
    logic [7:0] exponent_final;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage3_reg <=  {default: 'b0};
        end else begin
            if (stage2_reg.mantissa_mult[47] == 1) begin
                mantissa_mult_shifted = stage2_reg.mantissa_mult[46:24];
                exponent_final = stage2_reg.exponent_sum + 1;
            end else begin
                mantissa_mult_shifted = stage2_reg.mantissa_mult[45:23];
                exponent_final = stage2_reg.exponent_sum;
            end
            stage3_reg.sign_result <= stage2_reg.sign_result;
            stage3_reg.exponent_result <= exponent_final[7:0];
            stage3_reg.mantissa_result <= mantissa_mult_shifted[22:0];
        end
    end

    // Final output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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