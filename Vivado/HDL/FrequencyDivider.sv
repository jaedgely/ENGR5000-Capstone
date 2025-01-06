`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 09:33:30 AM
// Design Name: 
// Module Name: I2CController
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

module FrequencyDivider#(parameter FREQ_DIV_BITS = 8)
   (input clk, 
    input rst_n, 
    input [FREQ_DIV_BITS-1:0] factor,
    output dclk);
    
    assign dclk = divclk;
    
    reg[FREQ_DIV_BITS-1:0] counter = '0;
    reg divclk = 0;

    always_ff@(posedge clk) begin
        if (!rst_n) begin
            divclk <= 0;
            counter <= '0;
        end else if (counter >= factor) begin
            divclk <= ~divclk;
            counter <= '0;
        end else begin
            counter <= counter + 1;
        end
    end        
endmodule
