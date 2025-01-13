`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 02:27:42 PM
// Design Name: 
// Module Name: I2CControllerTop
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

module I2CControllerTop#(parameter NUM_BYTES = 1)
(
    input clk,                          // 100MHz FPGA clock
    input rst_n,                        // Reset, active low
    input start,                        // Starts the read/write operation
    input OP_CODE,                      // 0 for write, 1 for read
    input FORCE_CLK,
    input DATA_LEN,                     // 0 = 8 bit, 1 = 16 bit
    input SEND_REG_ADDR,
    input REG_ADDR_LEN,                 // 0 = 8 bit, 1 = 16bit
    input [1:0] FRQ_SEL,                // Bits to select the frequency
    input [6:0] PERIPH_ADDR,            // Peripheral device address
    input [15:0] REG_ADDR,              // Register address
    input [(8*NUM_BYTES)-1:0] D_TX,     // Data to send to the peripheral device
    output [(8*NUM_BYTES)-1:0] D_RX,    // Data that was read from the peripheral device
    output BUSY,                        // 0 means I2C controller is free. 1 means it is busy
    output NACK,                    // Sent if there is no acknowledge. Can only be cleared by a hard reset. 1 means there was no acknowledge
    inout I2C_SCL_t,                         // Clock line to peripheral device
    inout I2C_SDA_t                         // Tristate data line (Pushpull, Xilinx does not support open drain)
);                   
    
    wire sysclk;

    reg[7:0] divFactor;
    always_comb begin
        case (FRQ_SEL)
        'b00: divFactor = 'd250;    // Standard Mode    - 100KHz
        'b01: divFactor = 'd63;     // Fast Mode        - 400KHz
        'b10: divFactor = 'd25;     // Fast Mode Plus   - 1MHz
        'b11: divFactor = 'd8;      // Ultra Fast Mode  - 3.4MHz
        default: divFactor = 'd250;
        endcase
    end
    
    I2CController #(NUM_BYTES)I2C_CONTROLLER
    (
        .clk(sysclk),
        .rst_n(rst_n),
        .start(start),
        .OP_CODE(OP_CODE),
        .FORCE_CLK(FORCE_CLK),
        .DATA_LEN(DATA_LEN),
        .SEND_REG_ADDR(SEND_REG_ADDR),
        .REG_ADDR_LEN(REG_ADDR_LEN),
        .PERIPH_ADDR(PERIPH_ADDR),
        .REG_ADDR(REG_ADDR),
        .D_TX(D_TX),
        .D_RX(D_RX),
        .BUSY(BUSY),
        .NACK(NACK),
        .I2C_SCL_t(I2C_SCL_t),
        .I2C_SDA_t(I2C_SDA_t)
    );
    
    FrequencyDivider #(8)CLK_GEN
    (
        .clk(clk),
        .rst_n(1),
        .factor(divFactor),
        .dclk(sysclk)
    );        
   
endmodule

