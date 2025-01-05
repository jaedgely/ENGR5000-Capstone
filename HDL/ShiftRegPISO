`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 09:18:16 AM
// Design Name: 
// Module Name: ShiftRegPISO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ShiftRegPISO#(parameter DATA_WIDTH = 8)
(input clk, input rst_n, input sh, input ld, input [DATA_WIDTH-1:0] d, output q);
    
    reg[DATA_WIDTH-1:0] reg_internal = 'h0;
    
    assign q = reg_internal[DATA_WIDTH-1];
    
    always_ff@(posedge clk) begin
        if (!rst_n) begin
            reg_internal <= '0;
        end else if (sh & ~ld) begin
            reg_internal <= {reg_internal[DATA_WIDTH-2:0], 1'bX};
        end else if (~sh & ld) begin
            reg_internal <= d;
        end
    end
endmodule
