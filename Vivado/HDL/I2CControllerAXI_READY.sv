`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/04/2025 01:11:05 PM
// Design Name: 
// Module Name: I2CControllerAXI_READY
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
    
module I2CControllerAXI_READY(
    input clk,                          // Make 4x faster than desired I2C_SCL frequency
    input [31:0] AXI_IN,
    output [31:0] AXI_OUT,
    output NACK,                        // Also part of AXI_OUT. This is for an LED
    inout I2C_SCL_t,                    // Clock line to peripheral device
    inout I2C_SDA_t);                   // Tristate data line (Pushpull, Xilinx does not support open drain)
    
    wire rst_n;
    wire start;
    wire OP_CODE;
    wire send2bytes;
    wire [1:0] FRQ_SEL;
    wire FORCE_CLK;
    wire [6:0] PERIPH_ADDR;
    wire [15:0] D_TX;
    wire [15:0] Q_RX;
    wire BUSY;
    wire NACK;
    
    wire [1:0] reserved1;
    wire [31:18] reserved2; 
    
    assign rst_n = AXI_IN[0];
    assign start = AXI_IN[1];
    assign OP_CODE = AXI_IN[2];
    assign send2bytes = AXI_IN[3];
    assign FRQ_SEL = AXI_IN[5:4];
    assign FORCE_CLK = AXI_IN[6];
    assign reserved0 = AXI_IN[7];
    assign PERIPH_ADDR = AXI_IN[14:8];
    assign reserved1 = AXI_IN[15];
    assign D_TX = AXI_IN[31:16];
    
    assign AXI_OUT[15:0] = Q_RX;
    assign AXI_OUT[16] = BUSY;
    assign AXI_OUT[17] = NACK;
    assign AXI_OUT[31:18] = {'hBAD, 'b00};
    
    I2CControllerTop I2C_CONTROLLER(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .OP_CODE(OP_CODE),
        .FORCE_CLK(FORCE_CLK),
        .send2bytes(send2bytes),
        .FRQ_SEL(FRQ_SEL),
        .PERIPH_ADDR(PERIPH_ADDR),
        .D_TX(D_TX),
        .Q_RX(Q_RX),
        .BUSY(BUSY),
        .NACK(NACK),
        .I2C_SCL_t(I2C_SCL_t),
        .I2C_SDA_t(I2C_SDA_t));
        
endmodule
