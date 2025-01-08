`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2025 09:01:01 AM
// Design Name: 
// Module Name: SPIController_tb
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

module SPIController_tb();
    logic clock;
    logic reset;
    logic start;
    logic clockPol;
    logic clockPha;
    logic [1:0] dataLength;
    logic [7:0] chipSelect;
    logic [3:0][7:0] dataTx;
    logic CIPO;
    logic COPI;
    logic PCLK;
    logic BUSY;
    logic STARTING;
    logic [7:0]CS_gpio;
    logic [3:0][7:0] dataRx;
    
    SPIController #(4, 8)DUT
    (
        .clk(clock),
        .rst_n(reset),
        .SCOM(start),
        .CPOL(clockPol),
        .CPHA(clockPha),
        .DATA_LEN(dataLength),
        .CS_i(chipSelect),
        .D_TX(dataTx),
        .CIPO(CIPO),
        .COPI(COPI),
        .PCLK(PCLK),
        .BUSY(BUSY),
        .STARTING(STARTING),
        .CS_gpio(CS_gpio),
        .Q_RX(dataRx)
    );
    
    assign CIPO = COPI;
   
    task CycleClock();
        clock = ~clock; #10;
        clock = ~clock; #10;
    endtask
    
    task Write8(logic[7:0] data, logic[7:0] chip);
        dataTx[3] = data;
        dataLength = 2'b00;
        chipSelect = chip;
        start = 1;
        // 1 start cycle + 8 data + 1 end + 2 to track idle
        repeat(12) begin
            CycleClock();
        end
    endtask
    
    task Write16(logic[15:0] data, logic[7:0] chip);
        dataTx[3] = data[15:8];
        dataTx[2] = data[7:0];
        dataLength = 2'b01;
        chipSelect = chip;
        start = 1;
        // 1 start cycle + 8 data + 1 end + 2 to track idle
        repeat(20) begin
            CycleClock();
        end
    endtask
    
    task Write24(logic[23:0] data, logic[7:0] chip);
        dataTx[31:8] = data;
        dataLength = 2'b10;
        chipSelect = chip;
        start = 1;
        // 1 start cycle + 8 data + 1 end + 2 to track idle
        repeat(30) begin
            CycleClock();
        end
    endtask
    
    task Write32(logic[31:0] data, logic[7:0] chip);
        dataTx[31:0] = data;
        dataLength = 2'b11;
        chipSelect = chip;
        start = 1;
        // 1 start cycle + 8 data + 1 end + 2 to track idle
        repeat(38) begin
            CycleClock();
        end
    endtask
    
    task ValidateCS_GPIO(logic [7:0] chip);
    
    endtask
    
    task ValidateDataRx(logic [1:0] register, logic[7:0] data);
        assert (dataRx[register] == data)
            $display("Received data matches expected data. Measured 0x%h, expected 0x%h", dataRx[register], data);
        else
            $display("Received data does not match expected data. Measured 0x%h, expected 0x%h", dataRx[register], data);
    endtask
    
    task ValidateCPOL(logic cpolLevel);
        clockPol = cpolLevel; #1;
        
        assert (PCLK == clockPol) 
            $display("Pass - clock idles %d when CPOL is %d", PCLK, cpolLevel);
        else
            $display("Fail - clock idls %d when CPOL is %d", PCLK, cpolLevel);
    endtask         
    
    initial begin
        clock = 0;
        reset = 0;
        start = 0;
        clockPol = 0;
        clockPha = 0;
        dataLength = 0;
        chipSelect = '1;
        dataTx = 'hDEADCE11;
        CycleClock();
        reset = 1;
        CycleClock();
        ValidateCPOL(0);
        ValidateCPOL(1);
        CycleClock();
        CycleClock();
        Write8('hAC, 7'b111_1110);
        ValidateDataRx(0, 'hAC);
        clockPol = 0;
        clockPha = 0; #1;
        Write16('hDEAD, 7'b111_0111);
        clockPol = 1; #1;
        Write24('hCE11FF, 7'b101_1111);
        clockPha = 1; #1;
        Write32('h89AB_CDEF, 7'b111_1011);
    end
   
endmodule

