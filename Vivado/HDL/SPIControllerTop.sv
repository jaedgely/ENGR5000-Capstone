`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2025 07:22:54 PM
// Design Name: 
// Module Name: SPIControllerTop
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


module SPIControllerTop#(parameter NUM_BYTES = 2, parameter PERIPH_DEVICES = 1)
(
    input clk,
    input rst_n,
    input SCOM,
    input CPOL,
    input CPHA,
    input [2:0] FREQ_SEL,
    input [1:0] DATA_LEN,
    input [PERIPH_DEVICES-1:0] CS_i,
    input [NUM_BYTES-1:0][7:0] TxBuffer,
    input CIPO,
    output COPI,
    output PCLK,
    output BUSY,
    output STARTING,
    output [PERIPH_DEVICES-1:0] CS_gpio,
    output [NUM_BYTES-1:0][7:0] RxBuffer
);
    
    wire sysclk;
    wire[7:0] DIV_FACTOR;
    
    assign DIV_FACTOR = (1 << FREQ_SEL);

    SPIController #(NUM_BYTES, PERIPH_DEVICES)SPI_CONTROLLER
    (
        .clk(sysclk),
        .rst_n(rst_n),
        .SCOM(SCOM),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .DATA_LEN(DATA_LEN),
        .CS_i(CS_i),
        .TxBuffer(TxBuffer),
        .CIPO(CIPO),
        .COPI(COPI),
        .PCLK(PCLK),
        .BUSY(BUSY),
        .STARTING(STARTING),
        .CS_gpio(CS_gpio),
        .RxBuffer(RxBuffer)
    );
    
    FrequencyDivider #(8)CLK_GEN
    (
        .clk(clk),
        .rst_n(1),
        .factor(DIV_FACTOR),
        .clk_o(sysclk)
    ); 
        
endmodule
