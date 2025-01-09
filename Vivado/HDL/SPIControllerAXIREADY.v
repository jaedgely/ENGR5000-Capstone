`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 12/29/2024 05:31:30 PM
// Design Name: SPI Controller
// Module Name: SPIControllerAXIREADY
// Project Name: 
// Target Devices: 
// Tool Versions: 
// REGISTER MAP:
//                  INPUTS          Name                Notes
//                  AXI 0 CHANNEL 0
//                  Bit 0           Reset               Active low
//                  Bit 1           CPHA Bit            Clock Phase Angle
//                  Bit 2           CPOL Bit            Clock Polarity
//                  Bit[5:3]        Frequency           Formula = 100MHz / 2 ^ (n + 1)  OR  100MHz >> (n + 1)
//                  Bit[15:8]       Chip select bits    8 possible downstream devices
//                  Bit[31:16]      Reserved
//                  
//                  AXI 0 CHANNEL 1
//                  Bit[31:0]      TX Data buffer       TX Data loaded on falling edge of chip select bits if not busy
//                  
//                  OUTPUTS
//                  AXI 1 CHANNEL 0
//                  Bit[0]         SPI_BUSY             Active high
//                  
//                  AXI 1 CHANNEL 1
//                  Bit[31:0]      RX Data buffer       Updates on falling edge of SPI_BUSY
//                  
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
    
module SPIControllerAXIREADY#(parameter NUM_BYTES = 4, parameter PERIPH_DEVICES = 1)
(
    input clk, 
    input [31:0] AXI_IN_CONTROL,
    input [31:0] AXI_IN_DATA,
    input CIPO,
    output COPI,
    output PCLK,
    output [31:0] AXI_OUT_STATUS,
    output [31:0] AXI_OUT_DATA,
    output [PERIPH_DEVICES-1:0] CS_gpio
);

    wire rst_n;
    wire SCOM;
    wire CPOL;
    wire CPHA;
    wire [2:0] FREQ_SEL;
    wire [1:0] DATA_LEN;
    wire [PERIPH_DEVICES-1:0] CS_i;
    wire [NUM_BYTES-1:0] TxBuffer [7:0];
    wire BUSY;
    wire STARTING;
    wire [NUM_BYTES-1:0] RxBuffer [7:0];
    
    assign rst_n = AXI_IN_CONTROL[0];
    assign SCOM = AXI_IN_CONTROL[1];
    assign CPHA = AXI_IN_CONTROL[2];
    assign CPOL = AXI_IN_CONTROL[3];
    assign FREQ_SEL = AXI_IN_CONTROL[6:4];
    assign DATA_LEN = AXI_IN_CONTROL[9:8];  // Vitis will do weird sh!t if you have an enum wrap around registers so I skip bit 7 here
    assign CS_i = AXI_IN_CONTROL[23:16];    // Also why i skip 7 BITS here. F##k you Vitis!
    
    assign TxBuffer[3] = AXI_IN_DATA[31:24];
    assign TxBuffer[2] = AXI_IN_DATA[23:16];
    assign TxBuffer[1] = AXI_IN_DATA[15:8];
    assign TxBuffer[0] = AXI_IN_DATA[7:0];
    
    assign AXI_OUT_STATUS[0] = BUSY;
    assign AXI_OUT_STATUS[1] = STARTING;
    
    assign AXI_OUT_DATA[31:24] = RxBuffer[3];
    assign AXI_OUT_DATA[23:16] = RxBuffer[2];
    assign AXI_OUT_DATA[15:8] = RxBuffer[1];
    assign AXI_OUT_DATA[7:0] = RxBuffer[0];
    
    SPIControllerTop #(NUM_BYTES, PERIPH_DEVICES)
    (
        .clk(clk),
        .rst_n(rst_n),
        .SCOM(SCOM),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .FREQ_SEL(FREQ_SEL),
        .DATA_LEN(DATA_LEN),
        .CS_i(CS_i),
        .TxBuffer({TxBuffer[3], TxBuffer[2], TxBuffer[1], TxBuffer[0]}),
        .CIPO(CIPO),
        .COPI(COPI),
        .PCLK(PCLK),
        .BUSY(BUSY),
        .STARTING(STARTING),
        .CS_gpio(CS_gpio),
        .RxBuffer({RxBuffer[3], RxBuffer[2], RxBuffer[1], RxBuffer[0]})
    );
      
endmodule