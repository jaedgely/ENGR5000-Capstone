`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 10:18:03 AM
// Design Name: 
// Module Name: ShiftRegSIPO
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


module ShiftRegSIPO#(parameter DATA_WIDTH = 8)
(input clk, input rst_n, input sh, input d, output [DATA_WIDTH-1:0] q);

    reg[DATA_WIDTH-1:0] reg_internal = 'hDEADBEEF;
    
    assign q = reg_internal;
    
    always_ff@(posedge clk) begin
        if (!rst_n) begin
            reg_internal <= 'h0;
        end else if (sh) begin
            reg_internal <= {reg_internal[DATA_WIDTH-2:0], d};
        end else begin
            //
        end
    end
endmodule
