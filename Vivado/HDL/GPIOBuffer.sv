`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/07/2025 06:51:06 PM
// Design Name: 
// Module Name: GPIOBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple GPIO Tri-state buffer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GPIOBuffer
(
    input dataTx,
    input triEn,
    output dataRx,
    output GPIO_t
);

    assign GPIO_t = triEn ? 'bZ : dataTx;
    assign dataRx = GPIO_t;
    
endmodule
