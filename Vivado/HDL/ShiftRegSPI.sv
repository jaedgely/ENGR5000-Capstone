`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2025 08:24:38 AM
// Design Name: 
// Module Name: ShiftRegSPI
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

module ShiftRegSPI#(parameter DATA_WIDTH = 8)
(
    input clk,
    input rst_n,
    input sh,
    input ld,
    input [DATA_WIDTH-1:0] D_TX_p,   // Parallel data in
    input D_RX_s,                    // Serial data in  (GPIO pin)
    output D_TX_s,                   // Serial data out (GPIO pin)
    output [DATA_WIDTH-1:0] D_RX_p   // Parallel data out
);

    reg sampled;
    reg[DATA_WIDTH-1:0] sr = 'hDEADCE11;
    
    assign D_TX_s = sr[DATA_WIDTH-1];
    assign D_RX_p = sr;
    
    always_ff@(negedge clk) begin
        sampled <= D_RX_s;
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            sr <= 'h0;
        end else begin 
            case ({sh, ld})
            'b00: begin end
            'b01: sr <= D_TX_p;
            'b10: sr <= {sr[DATA_WIDTH-2:0], sampled};
            'b11: begin end
            default: sr <= 'hDEADCE11;
            endcase
        end
    end                
endmodule
