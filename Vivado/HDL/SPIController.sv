`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 12/29/2024 05:05:47 PM
// Design Name: 
// Module Name: SPIController
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


typedef enum logic[1:0]
{
    IDLE     = 'h0,
    START = 'h1,
    ACTIVE   = 'h2,
    STOP = 'h3
} SPI_STATES;

module SPIController#(parameter NUM_BYTES = 2, parameter PERIPH_DEVICES = 1)
(
    input clk,
    input rst_n,
    input SCOM,
    input CPOL,
    input CPHA,
    input [1:0] DATA_LEN,
    input [PERIPH_DEVICES-1:0] CS_i,
    input [NUM_BYTES-1:0][7:0] TxBuffer,
    input CIPO,
    output COPI,
    output PCLK,
    output BUSY,
    output STARTING,
    output reg [PERIPH_DEVICES-1:0] CS_gpio,
    output reg [NUM_BYTES-1:0][7:0] RxBuffer
);

    wire shiftregLoadCommand;
    wire spiclk;
    wire[NUM_BYTES-1:0][7:0] Q_RX;
    
    SPI_STATES STATE;

    assign BUSY = STATE != IDLE;
    assign STARTING = STATE == START;
    assign shiftregShiftCommand = STATE == ACTIVE;
    
    // If CPOL == CPHA 
    //  Data sampled on falling edge and shifted out on the rising edge
    // else
    //  Data sampled on rising edge and shifted out on the failing edge
    assign spiclk = CPOL == CPHA ? clk : ~clk;
    
    // If not active, idle at the CPOL Level
    assign PCLK = STATE == ACTIVE ? spiclk : CPOL;
    
    reg[4:0] bitcount; // Count 32
    
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            STATE <= IDLE;
        end else begin
            case (STATE)
            IDLE:   if (SCOM) begin
                        CS_gpio <= CS_i;
                        STATE <= START;
                    end else begin
                        CS_gpio <= '1;
                        STATE <= IDLE;
                    end
            START:  STATE <= ACTIVE;
            ACTIVE: STATE <= bitcount == 8 * (DATA_LEN + 1) - 1 ? STOP : ACTIVE; 
            STOP:   begin
                    STATE <= IDLE;
                    RxBuffer <= Q_RX;
                    end
            default: STATE <= IDLE;  
            endcase            
        end    
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            bitcount <= 0;
        end else if (STATE == IDLE || STATE == START) begin
            bitcount <= 0;
        end else begin
            bitcount <= bitcount + 1;
        end
    end
    
    ShiftRegSPI #(8*NUM_BYTES)SHIFT_REG
    (
        .clk(spiclk),
        .rst_n(rst_n),
        .sh(shiftregShiftCommand),
        .ld(STARTING),
        .D_TX_p(TxBuffer),
        .D_TX_s(COPI),
        .D_RX_s(CIPO),
        .D_RX_p(Q_RX)
    );
        
endmodule
