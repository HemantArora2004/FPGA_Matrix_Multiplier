`timescale 1ns / 1ps
module floating_point_multiplier(
    input logic clk,
    input logic rst_n,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic en,
    output logic [31:0] out,
    output logic busy
    );
endmodule
