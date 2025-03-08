//    SSSSSSSSSSSSSSS  TTTTTTTTTTTTTTTTTTTTTTT      000000000      PPPPPPPPPPPPPPPP
//  SS:::::::::::::::S T:::::::::::::::::::::T    00:::::::::00    P:::::::::::::::P
// S:::::SSSSSS::::::S T:::::::::::::::::::::T  00:::::::::::::00  P::::::PPPPPP:::::P
// S:::::     SSSSSSSS T:::::TT:::::::TT:::::T 0:::::::000:::::::0 PP:::::P     P:::::P
// S:::::S             TTTTTT  T:::::T  TTTTTT 0::::::0   0::::::0   P::::P     P:::::P
// S:::::S                     T:::::T         0:::::0     0:::::0   P::::P     P:::::P
//  S::: :SSSS                 T:::::T         0:::::0     0:::::0   P:::::PPPPPP:::::P
//   SS: :::::SSSSS            T:::::T         0:::::0     0:::::0   P:::::::::::::PP
//    SSS: :::::::SS           T:::::T         0:::::0     0:::::0   P::::PPPPPPPPP
//       SSSSSS::::S           T:::::T         0:::::0     0:::::0   P::::P
//             S:::::S         T:::::T         0:::::0     0:::::0   P::::P
//             S:::::S         T:::::T         0::::::0    0::::::0  P::::P
// SSSSSSS     S:::::S       TT:::::::TT       0:::::::000:::::::0  PP:::::PP
// S::::::SSSSSS:::::S       T:::::::::T        00:::::::::::::00   P:::::::P
// S:::::::::::::::SS        T:::::::::T          00:::::::::00     P:::::::P
//  SSSSSSSSSSSSSSS          TTTTTTTTTTT            000000000       PPPPPPPPP

// This module is fully verified and functioning. 
// If you are not Jack Edgely, there is no reason for you to be modifying this file. 
//
// If you are from a future senior design team trying to hunt down a bug, I can assure you,
// modifying this file will only cause you more headaches
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
//
// Create Date: 01/5/2025 07:38:00 AM
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

typedef enum logic [2:0]
{
    IDLE    = 3'h0,
    START   = 3'h1,
    PADDR   = 3'h2,
    ACK     = 3'h3,
    WRITE   = 3'h4,
    READ    = 3'h5,
    RESTART = 3'h6,
    STOP    = 3'h7
} STATES_t;

module I2CController#(parameter FPGA_CLOCK_HZ = 100_000_000)
(
    input clk,
    input rst_n,        // 0           
    input start,        // 1
    input stop,         // 2
    input rwbit,         
    input tenBitAddr,  
    input forceClock,         
    input [6:0] periphAddr,
    input [7:0] txBuffer,  
    input [7:0] prescale,
    output logic [7:0] rxBuffer,
    output logic busy,
    output logic loading,
    output logic starting,
    output logic nack,
    // Serial IO
    input I2C_SDA_i,
    input I2C_SCL_i,
    output logic I2C_SDA_o,
    output logic I2C_SCL_o
);

    STATES_t STATE;
    STATES_t NEXT_STATE;

    logic sclRisingEdge;
    logic sentAddr;
    logic sdaRisingEdge;
    logic sclFallingEdge;
    logic sdaFallingEdge;
    logic savedOpCode;
    logic[7:0] savedPeriphAddr;
    logic arbitrationLost;
    logic[1:0] nackCounter;
    logic[3:0] bitCounter;
    logic[3:0] byteCounter;
    logic[10:0] clockCounter;
    logic[10:0] prescale;
    logic [7:0] dataTx; // Stuff periph addr and data tx into one
    logic [7:0] dataRx;
    
    // EXAMPLE: PRESCALE == 500
    //          PRESCALE >> 2 == 125
    //          PRESCALE >> 1 == 250
    //          PRESCALE - (PRESCALE >> 1) == 375        
    assign sdaRisingEdge  = clockCounter == 0;
    assign sclRisingEdge  = clockCounter == (prescale >> 2) - 1;
    assign sdaFallingEdge = clockCounter == (prescale >> 1) - 1;
    assign sclFallingEdge = clockCounter == (prescale - (prescale >> 2)) - 1;
    
    assign busy = STATE != IDLE;
    assign loading = STATE == ACK;
    assign starting = STATE == START || STATE == RESTART;

    // Determine prescale for clock counter
    /*
    always_comb begin
        case (freqSel)
        'b00: prescale = (FPGA_CLOCK_HZ) / (100_000);   
        'b01: prescale = (FPGA_CLOCK_HZ) / (400_000);   
        'b10: prescale = (FPGA_CLOCK_HZ) / (1_000_000); 
        'b11: prescale = (FPGA_CLOCK_HZ) / (3_400_000); 
        endcase
    end
    */
    // Next state logic
    always_comb begin
     // NEXT_STATE = arbitrationLost ? STOP : NEXT_STATE;
        case (STATE)
        IDLE:   NEXT_STATE = start ? START : IDLE;          
        START:  NEXT_STATE = PADDR;                         
        PADDR:  NEXT_STATE = bitCounter == 0 & byteCounter == 1 ? ACK : PADDR; 
        ACK:    begin
                if (nackCounter == 3) begin                 
                    NEXT_STATE = STOP;
                end else if (nack) begin                    
                    NEXT_STATE = ACK;
                //end else if (byteCounter == 2 && start) begin
                end else if (start) begin  
                    NEXT_STATE = RESTART;
                //end else if (byteCounter == 2 && stop) begin
                end else if (stop) begin
                    NEXT_STATE = STOP;
                //end else if (byteCounter == 1 && tenBitAddr) begin
                end else if (tenBitAddr & ~sentAddr) begin
                    NEXT_STATE = WRITE;
                end else begin                              
                    NEXT_STATE = savedOpCode ? READ : WRITE;
                end
                end
        WRITE:  NEXT_STATE = bitCounter == 0 & byteCounter != 1 ? ACK : WRITE;
        READ:   begin
                if (bitCounter == 0 & byteCounter == 2) begin
                    if (start) begin
                        NEXT_STATE = RESTART;
                    end else if (stop) begin
                        NEXT_STATE = STOP;
                    end else begin
                        NEXT_STATE = ACK;
                    end
                end else begin
                    NEXT_STATE = READ;
                end
                end
        RESTART:NEXT_STATE = START; //I2C_SDA_o == 0 ? PADDR : RESTART;
        STOP:   NEXT_STATE = I2C_SDA_o == 1 ? IDLE : STOP;
        default:NEXT_STATE = IDLE;
        endcase
    end
    
    /*/
     *  TO DO
     *      Actually implement the arbitration into the code.    
     *
    /*/
    /*
    always_ff@(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            arbitrationLost = 0;
        end else if (STATE != IDLE) begin
            if (I2C_SDA_i != I2C_SDA_o || I2C_SCL_i != I2C_SCL_o) begin
                arbitrationLost = 1;
            end else begin
                arbitrationLost = 0;
            end
        end else begin
            arbitrationLost = 0;
        end
    end
   */
    // I2C_SDA block
    always_ff@(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            STATE <= IDLE;
            I2C_SDA_o <= 1;
            savedOpCode <= 0;
            sentAddr <= 0;
            dataTx <= 'b1;
        end else if (sclRisingEdge) begin
            if (STATE == START) begin
                I2C_SDA_o <= 0;
            end else begin
                I2C_SDA_o <= I2C_SDA_o;
            end
        end else if (sclFallingEdge) begin
            if (STATE == STOP) begin
                I2C_SDA_o <= 1;
            end else begin
                I2C_SDA_o <= I2C_SDA_o;
            end
        end else if (sdaRisingEdge) begin
            STATE <= NEXT_STATE;
            case (STATE)
            IDLE:   I2C_SDA_o <= I2C_SDA_o;
            START:  I2C_SDA_o <= dataTx[7];
            PADDR:  I2C_SDA_o <= bitCounter == 0 ? 1'b1 : dataTx[7];
            ACK:    begin
                    sentAddr <= 1;
                    if (start) begin
                        I2C_SDA_o <= 1; // This causes repeated start condition. Dont touch.
                    end else if (nack) begin;
                        I2C_SDA_o <= 1;
                    end else begin
                        I2C_SDA_o <= dataTx[7];
                    end
                    end    
            READ:   I2C_SDA_o <= bitCounter == 0 ? 1'b0 : 1'b1;
            WRITE:  I2C_SDA_o <= bitCounter == 0 ? 1'b1 : dataTx[7];
            RESTART:I2C_SDA_o <= 0; // Might need to be I2C_SDA_o <= I2C_SDA_o
            STOP:   I2C_SDA_o <= 1;
            default:I2C_SDA_o <= 1;
            endcase
        end else if (sdaFallingEdge) begin
            if (STATE == IDLE) begin
                dataTx <= dataTx;
            end else if (STATE == START || STATE == RESTART) begin
                savedOpCode <= rwbit;
                dataTx = {periphAddr, rwbit};
            end else if (STATE == ACK) begin
                dataTx <= txBuffer;
            end else if (STATE == PADDR || STATE == WRITE) begin
                dataTx <= dataTx << 1;
            end else begin
                dataTx <= dataTx;
            end 
        end else begin
            STATE <= STATE;
            I2C_SDA_o <= I2C_SDA_o;
            dataTx <= dataTx;
        end
    end
    
    // I2C_SCL block
    always_ff@(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            nack <= 1;
            I2C_SCL_o <= 1;
            nackCounter <= 0;
        end else if (sclRisingEdge) begin
            I2C_SCL_o <= 1;
            if (STATE == START) begin
                nack <= 1;
                dataRx <= 'b0;
                nackCounter <= 0;
            end else if (STATE == ACK) begin
                nack <= I2C_SCL_i;
                dataRx <= dataRx;
                nackCounter <= nackCounter + I2C_SCL_i;
            end else if (STATE == READ) begin
                nack <= nack;
                dataRx <= {dataRx[6:0], I2C_SDA_i};
                nackCounter <= nackCounter;
            end else begin
                nack <= nack;
                dataRx <= dataRx;
                nackCounter <= nackCounter;
            end
        end else if (sclFallingEdge) begin
            if (forceClock && STATE == IDLE) begin
                I2C_SCL_o <= 0;
            end else begin
                case (STATE)
                IDLE:   I2C_SCL_o <= 1;
                START:  I2C_SCL_o <= 0;
                PADDR:  I2C_SCL_o <= 0;
                ACK:    I2C_SCL_o <= 0;
                READ:   I2C_SCL_o <= 0;
                WRITE:  I2C_SCL_o <= 0;
                RESTART:I2C_SCL_o <= 1;
                STOP:   I2C_SCL_o <= 1;
                default:I2C_SCL_o <= 1;
                endcase
            end    
        end else begin
            nack <= nack;
            I2C_SCL_o <= I2C_SCL_o;
            nackCounter <= nackCounter;
        end
    end

    always_ff@(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            clockCounter <= 0;
        end else if (clockCounter == prescale - 1) begin
            clockCounter <= 0;
        end else begin
            clockCounter <= clockCounter + 1;
        end
    end
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            bitCounter <= 0;
            byteCounter <= 0;
        end else if (STATE == IDLE || STATE == START || STATE == RESTART) begin
            bitCounter <= 0;
            byteCounter <= 0;
        end else if (STATE == ACK) begin
            bitCounter <= 0;
            byteCounter <= byteCounter;
        end else if (sclRisingEdge) begin
            bitCounter <= bitCounter + 1;
            byteCounter <= byteCounter + (bitCounter == 7);
        end else begin
            bitCounter <= bitCounter;
            byteCounter <= byteCounter;
        end
    end
endmodule
