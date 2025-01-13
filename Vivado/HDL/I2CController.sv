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
    ACKNOWL = 'h3,     
    WRITING = 'h4,
    READING = 'h5,
    STOP    = 'h6,
    RESTART = 'h7
} STATE_ENUM;

module I2CController#(parameter NUM_BYTES = 1)
(
    input clk,                          // Make 4x faster than desired I2C_SCL frequency
    input rst_n,                        
    input start,                        
    input OP_CODE,                      
    input FORCE_CLK,                    
    input DATA_LEN, 
    input SEND_REG_ADDR,          // 0 = no register address, 1 = send address
    input REG_ADDR_LEN,         // 0 = 8 bit, 1 = 16 bit
    input [6:0] PERIPH_ADDR,            
    input [15:0] REG_ADDR,                     
    input [(8*NUM_BYTES)-1:0] D_TX,     
    
    output reg [(8*NUM_BYTES)-1:0] D_RX,   
    output BUSY,                            //1 == BUSY
    output reg NACK,                    
    inout I2C_SCL_t,                        // Tristate clock line. Internal pull-up, open-drain
    inout I2C_SDA_t                         // Tristate clock line. Internal pull-up, open-drain
);

    reg SENT_REG_ADDR;
    reg[1:0] clockcounter = 2'b00;
    reg[3:0] bit_count;
   
    reg OP_CODE_LATCHED;
    reg[1:0] NACK_COUNT;
    STATE_ENUM STATE;
    
    // Busy flag logic
    assign BUSY = STATE != IDLE;
    
    // Shift register enable signals
    wire SR_SDAO_en;
    wire SR_SDAI_en;
    wire SR_REG_ADDR_en;
    wire SR_PERIPH_ADDR_en;
    
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
    
    wire [7:0] SR_ADDR_in;
    assign SR_ADDR_in = SEND_REG_ADDR && !SENT_REG_ADDR ? {PERIPH_ADDR[6:0], 1'b0} : {PERIPH_ADDR[6:0], OP_CODE};
    wire [15:0] SR_SDAO_in;
    assign SR_SDAO_in = SEND_REG_ADDR && !SENT_REG_ADDR ? REG_ADDR : D_TX;
    
    always_ff@(clockcounter) begin
        if (!rst_n) begin
            STATE <= IDLE;
            SENT_REG_ADDR <= 0;
            I2C_SDA_o <= 1; // Tristate    
            D_RX <= 'hDEADCE11;
        end else begin
            case(cccheat)
            // Update state at 0
            2'b00:  begin
                        case (STATE)
                            IDLE:   begin
                                        if (start) begin
                                            STATE <= START;
                                        end
                                        I2C_SDA_o <= 1;         // Tristate
                                        OP_CODE_LATCHED <= OP_CODE;
                                        SENT_REG_ADDR <= 0;
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
                                        if (NACK_COUNT == 3 || (bytessent == DATA_LEN + SEND_REG_ADDR + (SEND_REG_ADDR && REG_ADDR_LEN) + 1)) begin
                                            STATE <= STOP;
                                            I2C_SDA_o <= 'b0;
                                        end else if (!NACK) begin
                                            if (SEND_REG_ADDR && !SENT_REG_ADDR) begin
                                                if (bytessent == REG_ADDR_LEN + 1) begin
                                                    STATE <= RESTART;
                                                    I2C_SDA_o <= 1;
                                                    SENT_REG_ADDR <= 1;
                                                end else begin  // Send register address via the SDA Out shift register
                                                    STATE <= WRITING;
                                                    I2C_SDA_o = SR_SDAO_q;
                                                end
                                            end else if (OP_CODE_LATCHED) begin
                                                STATE <= READING;
                                                I2C_SDA_o <= 'b1;
                                            end else begin
                                                STATE <= WRITING;
                                                I2C_SDA_o <= SR_SDAO_q;
                                            end
                                        end    
                                    end
                            READING:begin
                                        I2C_SDA_o <= 'b1;
                                        if (bit_count == 7) begin
                                            STATE <= ACKNOWL;
                                            // If reading and not the last byte, pull line low. Otherwise tristate
                                            I2C_SDA_o = OP_CODE_LATCHED && (bytessent < DATA_LEN + 1) ? 'b0 : 'b1;
                                            //I2C_SDA_o <= 'b1;
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
                            RESTART:begin
                                        STATE <= ADDRESS;
                                        I2C_SDA_o <= SR_ADDR_q;
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
                        if (STATE == RESTART) begin
                            I2C_SDA_o <= 0;
                        end
                    end
            2'b11:  begin
                        if (STATE == STOP) begin
                            I2C_SDA_o <= 1;
                            D_RX <= SR_SDAI_q;
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
            NACK_COUNT <= 0;
            I2C_SCL_o <= 1;
        end else begin
            case(cccheat)
            2'b00:  begin end
            2'b01:  begin
                        if (STATE != IDLE && STATE != START || FORCE_CLK) begin
                            I2C_SCL_o <= ~I2C_SCL_o;
                        end
                        if (STATE == ACKNOWL) begin
                            if (I2C_SDA_i == 0 || (OP_CODE_LATCHED && bytessent == DATA_LEN + 1)) begin
                                NACK <= 0;
                                NACK_COUNT <= 0;
                            end else begin
                                NACK <= 1;
                                NACK_COUNT <= NACK_COUNT + 1;
                            end
                        end
                        if (STATE == STOP) begin
                            NACK = NACK_COUNT == 3;
                            I2C_SCL_o <= 1;
                        end    
                    end
            2'b10:  begin
                        if (STATE == IDLE || STATE == START || START == STOP) begin
                            I2C_SCL_o <= 1;  
                            NACK_COUNT <= 0;
                        end
                    end
            2'b11:  begin
                        if (STATE != IDLE && STATE != STOP  || FORCE_CLK) begin
                            I2C_SCL_o <= ~I2C_SCL_o;
                        end
                    end
            default:begin
                        I2C_SCL_o <= 1;
                        NACK <= 1;
                    end        
            endcase
        end
    end
    
    reg[2:0] bytessent = 0;
    // Count num bits/bytes sent 
    always_ff@(posedge cccheat == 2'b00, negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= 0;  
        end else if (STATE == IDLE || STATE == START) begin
            bit_count <= 0;  
            bytessent <= 0; 
        end else if (STATE != RESTART) begin
            bit_count <= bit_count + 1;
            if (bit_count == 8 && !NACK) begin   // This will actually trigged on the 8th clock cycle 
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
        .ld(STATE == START || STATE == RESTART),
        .d(SR_ADDR_in),
        .q(SR_ADDR_q)
    );    

    ShiftRegPISO #(8*NUM_BYTES)SR_SDAO
    (
        .clk(clockcounter == 2'b01),
        .rst_n(rst_n),
        .sh(SR_SDAO_en),
        .ld(STATE == START || STATE == RESTART),
        .d(SR_SDAO_in),
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
