`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2025 01:41:12 PM
// Design Name: 
// Module Name: I2CController_tb
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


module I2CController_tb();

    logic clock;
    logic reset;
    logic start;
    logic stop;
    logic opCode;
    logic sendTenBitAddr;
    logic forceClock;
    logic [1:0] freqSel;
    logic [6:0] periphAddr;
    logic [15:0] regAddr;
    logic [15:0] dataTx;
    logic [15:0] dataRx;
    logic busy;
    logic loading;
    logic starting;
    logic nack;
    
    wire I2C_SCL;
    wire I2C_SDA;
    
    I2CController #(100_000_000) DUT
    (
        .clk(clock),
        .rst_n(reset),
        .start(start),
        .stop(stop),
        .rwbit(opCode),  
        .tenBitAddr(sendTenBitAddr),
        .forceClock(forceClock),
        .prescale(40),
        .periphAddr(periphAddr),
        .txBuffer(dataTx),
        .rxBuffer(dataRx),
        .busy(busy),
        .loading(loading),
        .starting(starting),
        .nack(nack),
        .I2C_SCL_i(I2C_SCL),
        .I2C_SCL_o(I2C_SCL),
        .I2C_SDA_i(1'b0),
        .I2C_SDA_o(I2C_SDA)
    );
   
    task CycleClock();
        clock = ~clock; #5;
        clock = ~clock; #5;
    endtask
    
    initial begin
        clock = 0;
        reset = 0;
        start = 0;
        stop = 0;
        opCode = 0;
        forceClock = 0;
        sendTenBitAddr = 0;  
        freqSel = 0;
        periphAddr = 0;
        regAddr = 0;
        dataTx = 0;
        
        repeat(2) begin
            CycleClock();
        end
        
        reset = 1;
        periphAddr = 7'h13;
        opCode = 0;
        dataTx = 16'hDEAD;
        regAddr = 16'hCE11;
        
        repeat(1000) begin
            CycleClock();
        end
        
        start = 1;
        
        repeat(4000) begin
            CycleClock();
        end
        
        start = 0;
        repeat(4000) begin
            CycleClock();
        end
        
        stop = 1;
        opCode = 1;
        
        repeat(80000) begin
            CycleClock();
        end
    end
endmodule
