`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/07/2025 08:19:20 AM
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
// Additional Comments: Read the following
// https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html
// 
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic[1:0]
{
    IDLE     = 'h0,
    START = 'h1,
    ACTIVE   = 'h2,
    STOP = 'h4
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
    input [NUM_BYTES-1:0][7:0] D_TX,
    input CIPO,
    output COPI,
    output PCLK,
    output BUSY,
    output STARTING,
    output reg [PERIPH_DEVICES-1:0] CS_gpio,
    output reg [NUM_BYTES-1:0][7:0] Q_RX
);

    wire shiftregLoadCommand;
    wire spiclk;
    wire[NUM_BYTES-1:0][7:0] Q_RX_wires;
    
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
    
    reg[2:0] bitcount;
    reg[$bits(NUM_BYTES)-1:0] bytecount;
    
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
            ACTIVE: if (bitcount == 'h7 && bytecount == DATA_LEN) begin
                        STATE <= STOP;
                        Q_RX <= Q_RX_wires;
                    end else begin
                        STATE <= ACTIVE;
                    end
            //ACTIVE: STATE <= bytecount > DATA_LEN ? STOP : bitcount == 'h7 ? PAUSE : ACTIVE;
            STOP:   STATE <= IDLE; 
            default: STATE <= IDLE;  
            endcase            
        end    
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            bitcount <= 0;
            bytecount <= 0;
        end else if (STATE == IDLE || STATE == START) begin
            bitcount <= 0;
            bytecount <= 0;
        end else begin
            bitcount <= bitcount + 1;
            if (bitcount == 'h7) begin
                bytecount <= bytecount + 1;
            end
        end
    end
    
    ShiftRegSPI #(8*NUM_BYTES)SHIFT_REG
    (
        .clk(spiclk),
        .rst_n(rst_n),
        .sh(shiftregShiftCommand),
        .ld(STARTING),
        .D_TX_p(D_TX),
        .D_TX_s(COPI),
        .D_RX_s(CIPO),
        .D_RX_p(Q_RX_wires)
    );
        
endmodule
