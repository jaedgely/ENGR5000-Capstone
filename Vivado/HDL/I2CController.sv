`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 09:33:30 AM
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

typedef enum logic[2:0]
{
    IDLE    = 'h0,
    START   = 'h1,
    ADDRESS = 'h2,
    ACKNOWL = 'h4,     
    WRITING = 'h5,
    READING = 'h6,
    STOP    = 'h7
} STATE_ENUM;

module I2CController#(parameter NUM_BYTES = 1)(
    input clk,                          // Make 4x faster than desired I2C_SCL frequency
    input rst_n,                        // Reset, active low
    // Control Bits
    input start,                        // Starts the read/write operation
    input OP_CODE,                      // 0 for write, 1 for read
    input FORCE_CLK,                    // Forces the I2C_SCL line to be driven. Can be used to try to clear the bus if a peripheral device is locked up
    input send2bytes,  // Bits that let you choose how many bytes you actually want to send, so you can end the transaction early (E.g, parameterized as 3 bytes, but you only want 1. Write 0b01 to here)
    input [6:0] PERIPH_ADDR,            // Peripheral device address
    input [(8*NUM_BYTES)-1:0] D_TX,     // Data to send to the peripheral device
    
    output reg [(8*NUM_BYTES)-1:0] Q_RX,    // Data that was read from the peripheral device
    output BUSY,                        // 0 means I2C controller is free. 1 means it is busy
    output reg NACK,                    // Sent if there is no acknowledge. Can only be cleared by a hard reset. 1 means there was no acknowledge
    inout I2C_SCL_t,                    // Clock line to peripheral device
    inout I2C_SDA_t);                   // Tristate data line (Pushpull, Xilinx does not support open drain)
        
    reg[1:0] clockcounter = 2'b00;
    reg[3:0] bit_count;
    reg[$bits(NUM_BYTES)-1:0] byte_count;
   
    reg OP_CODE_LATCHED;
    STATE_ENUM STATE;
    
    // Busy flag logic
    assign BUSY = STATE != IDLE;
    
    // Shift register enable signals
    wire SR_ADDR_en;
    wire SR_SDAO_en;
    wire SR_SDAI_en;
    assign SR_ADDR_en = STATE == ADDRESS;
    assign SR_SDAO_en = STATE == WRITING;// && bit_count != 8;
    assign SR_SDAI_en = STATE == READING;// && bit_count != 8;
    
    // Shift register wire outputs
    wire SR_ADDR_q;                     // Serial
    wire SR_SDAO_q;                     // Serial
    wire [(8*NUM_BYTES)-1:0] SR_SDAI_q; // Parallel
    
    // Seperate in/out wires for tri-state signal I2C_SDA
    reg I2C_SDA_o;
    wire I2C_SDA_i;
    assign I2C_SDA_t = I2C_SDA_o ? 'bZ : 'b0;
    assign I2C_SDA_i = I2C_SDA_t;
    
    always_ff@(clockcounter) begin
        if (!rst_n) begin
            STATE <= IDLE;
            I2C_SDA_o <= 1; // Tristate    
            Q_RX <= 'hDEADCE11;
        end else begin
            case(cccheat)
            // Update state at 0
            2'b00:  begin
                        case (STATE)
                            IDLE:   begin
                                        I2C_SDA_o <= 1;         // Tristate
                                        OP_CODE_LATCHED <= OP_CODE;
                                        if (start) STATE <= START;
                                    end
                            START:  begin
                                        STATE <= ADDRESS;
                                        I2C_SDA_o <= SR_ADDR_q;
                                    end    
                            ADDRESS:begin   
                                        if (bit_count == 7) begin
                                            STATE <= ACKNOWL;
                                            I2C_SDA_o <= 'b1;   // Tristate
                                        end else begin
                                            I2C_SDA_o <= SR_ADDR_q;
                                        end
                                    end    
                            ACKNOWL:begin
                                        if (NACK || (bytessent == send2bytes + 1)) begin
                                            STATE <= STOP;
                                            I2C_SDA_o <= 'b0;
                                        end else begin
                                            STATE <= OP_CODE_LATCHED ? READING : WRITING;
                                            I2C_SDA_o <= OP_CODE_LATCHED ? 'b1 : SR_SDAO_q; 
                                        end    
                                    end
                            READING:begin
                                        I2C_SDA_o <= 'b1;
                                        if (bit_count == 7) begin
                                            STATE <= ACKNOWL;
                                            I2C_SDA_o <= 'b1;   // Tristate
                                        end    
                                    end
                            WRITING:begin
                                        I2C_SDA_o <= SR_SDAO_q;                                        
                                        if (bit_count == 7) begin
                                            STATE <= ACKNOWL;
                                            I2C_SDA_o <= 'b1;   // Tristate
                                        end    
                                    end
                            STOP:   begin
                                        STATE <= IDLE;
                                    end
                            default:begin
                                        STATE <= IDLE;
                                        I2C_SDA_o <= 1;
                                    end        
                        endcase
                    end           
            2'b01:  begin
                        if (STATE == START) begin
                            I2C_SDA_o <= 0;
                        end
                    end
            2'b10:  begin
                    //
                    end
            2'b11:  begin
                        if (STATE == STOP) begin
                            I2C_SDA_o <= 1;
                            Q_RX <= SR_SDAI_q;
                        end
                    end
            default:begin
                        STATE <= IDLE;
                        I2C_SDA_o <= 1;
                    end            
            endcase
        end    
    end
   
    wire I2C_SCL_i;
    reg I2C_SCL_o;
    assign I2C_SCL_t = I2C_SCL_o ? 'bZ: 'b0;
    assign I2C_SCL_i = I2C_SCL_t;
    
    always_ff@(clockcounter) begin
        if (!rst_n) begin
            NACK <= 0;
            I2C_SCL_o <= 1;
        end else begin
            case(cccheat)
            2'b00:  begin
                    end
                   
            2'b01:  begin
                        if (STATE != IDLE && STATE != START) begin
                            I2C_SCL_o <= ~I2C_SCL_o;
                        end
                        if (STATE == ACKNOWL) begin
                            NACK <= I2C_SDA_i;
                        end
                        if (STATE == STOP) begin
                            I2C_SCL_o <= 1;
                        end    
                    end
            2'b10:  begin
                        if (STATE == IDLE || STATE == START || START == STOP) begin
                            I2C_SCL_o <= 1;  
                        end
                    end
            2'b11:  begin
                        if (STATE != IDLE && STATE != STOP) begin
                            I2C_SCL_o <= ~I2C_SCL_o;
                        end
                    end
            default:begin
                        I2C_SCL_o <= 1;
                    end        
            endcase
        end
    end
    
    reg[1:0] bytessent = 0;
    // Count num bits/bytes sent 
    always_ff@(posedge cccheat == 2'b00, negedge rst_n) begin
       if (!rst_n) begin
            bit_count <= 0;
        end else if (STATE == IDLE || STATE == START) begin
            bit_count <= 0;   
        end else begin
            bit_count <= bit_count + 1;
            if (bit_count == 8) begin   // This will actually trigged on the 8th clock cycle 
                bytessent <= bytessent + 1;
                bit_count <= 0;
            end
        end
    end 
    
    // Count clock cycles
    reg [1:0] cccheat;
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            clockcounter <= 2'b00;
            cccheat <= 2'b00;
        end else begin
            clockcounter <= clockcounter + 1'b1;
            cccheat <= clockcounter - 1;
        end
    end
    
    // Shift Registers 
    ShiftRegPISO #(8)SR_ADDR
    (
        .clk(clockcounter == 2'b01),
        .rst_n(rst_n),
        .sh(SR_ADDR_en),
        .ld(STATE == START),
        .d({PERIPH_ADDR, OP_CODE}),
        .q(SR_ADDR_q)
    );        

    ShiftRegPISO #(8*NUM_BYTES)SR_SDAO
    (
        .clk(clockcounter == 2'b01),
        .rst_n(rst_n),
        .sh(SR_SDAO_en),
        .ld(STATE == START),
        .d(D_TX),
        .q(SR_SDAO_q)
    );     

    ShiftRegSIPO #(8*NUM_BYTES)SR_SDAI
    (
        .clk(I2C_SCL_o),
        .rst_n(rst_n),
        .sh(SR_SDAI_en),
        .d(I2C_SDA_i),
        .q(SR_SDAI_q)
    );
    
endmodule
