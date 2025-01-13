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
    
module I2CControllerAXI_READY
(
    input clk,      
    input [31:0] AXI_IN,
    input [15:0] TX_BUFFER,
    output [31:0] AXI_OUT,
    output NACK,    
    inout I2C_SCL_t,
    inout I2C_SDA_t
);  
    
    wire rst_n;
    wire FORCE_CLK;
    wire start;
    wire OP_CODE;
    wire DATA_LEN;
    wire SEND_REG_ADDR;
    wire REG_ADDR_LEN;
    wire [1:0] FRQ_SEL;
    wire [6:0] PERIPH_ADDR;
    wire [15:0] REG_ADDR;
    wire [15:0] D_TX;
    wire [15:0] D_RX;
    wire BUSY;
    wire NACK;
    
    assign rst_n = AXI_IN[0];
    assign start = AXI_IN[1];
    assign OP_CODE = AXI_IN[2];
    assign DATA_LEN = AXI_IN[3];
    assign SEND_REG_ADDR = AXI_IN[4];
    assign REG_ADDR_LEN = AXI_IN[5];
    assign FRQ_SEL = AXI_IN[7:6];
    assign FORCE_CLK = AXI_IN[8];
    assign PERIPH_ADDR = AXI_IN[15:9];
    assign REG_ADDR = AXI_IN[31:16];
    assign D_TX = TX_BUFFER;
    
    assign AXI_OUT[15:0] = D_RX;
    assign AXI_OUT[16] = BUSY;
    assign AXI_OUT[17] = NACK;
    assign AXI_OUT[31:18] = {'hBAD, 'b00};
    
    I2CControllerTop #(2)I2C_CONTROLLER
    (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .OP_CODE(OP_CODE),
        .FORCE_CLK(FORCE_CLK),
        .DATA_LEN(DATA_LEN),
        .SEND_REG_ADDR(SEND_REG_ADDR),
        .REG_ADDR_LEN(REG_ADDR_LEN),
        .FRQ_SEL(FRQ_SEL),
        .PERIPH_ADDR(PERIPH_ADDR),
        .REG_ADDR(REG_ADDR),
        .D_TX(D_TX),
        .D_RX(D_RX),
        .BUSY(BUSY),
        .NACK(NACK),
        .I2C_SCL_t(I2C_SCL_t),
        .I2C_SDA_t(I2C_SDA_t)
    );
        
endmodule
