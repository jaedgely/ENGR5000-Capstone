`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 12/29/2024 05:10:17 PM
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
        .TxBuffer(dataTx),
        .CIPO(CIPO),
        .COPI(COPI),
        .PCLK(PCLK),
        .BUSY(BUSY),
        .STARTING(STARTING),
        .CS_gpio(CS_gpio),
        .RxBuffer(dataRx)
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
            start = 0;
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
            start = 0;
        end
    endtask
    
    task Write24(logic[23:0] data, logic[7:0] chip);
        dataTx[3] = data[23:16];
        dataTx[2] = data[15:8];
        dataTx[1] = data[7:0];
        dataLength = 2'b10;
        chipSelect = chip;
        start = 1;
        // 1 start cycle + 8 data + 1 end + 2 to track idle
        repeat(30) begin
            CycleClock();
            start = 0;
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
            start = 0;
        end
    endtask
    
    task ValidateCS_GPIO(logic[7:0] chip);
        assert(CS_gpio == chip)
            $display("Chip select GPIO pins match expected output. Measured %d, expected %d", CS_gpio, chipSelect);
        else
            $display("!!!!!!!!!!!!!!!!!!/n Chip select GPIO pins do not match expected output. Measured %d, expected %d !!!!!!!!!!!!!!!!!!", CS_gpio, chipSelect);
    endtask
    
    task ValidateDataRx(logic[1:0] register, logic[7:0] data);
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
    
    task Test1Byte();
        logic[7:0] data = $urandom_range((2**8) - 1, 0);
        int chipSelect = $urandom_range(255, 0);
        Write8(data, chipSelect);        
        ValidateDataRx(0, data);
    endtask
    
    task Test2Byte();
        logic[15:0] data = $urandom_range((2**16) - 1, 0);
        int chipSelect = $urandom_range(255, 0);
        Write16(data, chipSelect);        
        ValidateDataRx(1, data[15:8]);
        ValidateDataRx(0, data[7:0]);
    endtask  
    
    task Test3Byte();
        logic[23:0] data = $urandom_range((2**24) - 1, 0);
        int chipSelect = $urandom_range(255, 0);
        Write24(data, chipSelect);      
        ValidateDataRx(2, data[23:16]);  
        ValidateDataRx(1, data[15:8]);
        ValidateDataRx(0, data[7:0]); 
    endtask  
    
    task Test4Byte();
        logic[15:0] data0 = $urandom_range((2**16) - 1, 0);
        logic[15:0] data1 = $urandom_range((2**16) - 1, 0);
        logic[31:0] dataConcat = {data1, data0};
        int chipSelect = $urandom_range(255, 0);
        Write32(dataConcat, chipSelect);     
        ValidateDataRx(3, dataConcat[31:24]);   
        ValidateDataRx(2, dataConcat[23:16]);  
        ValidateDataRx(1, dataConcat[15:8]);
        ValidateDataRx(0, dataConcat[7:0]);   
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

        
        for (int i = 0; i < 4; i++) begin
            // Update SPI Mode
            {clockPol, clockPha} = i; #1;
            $display("TESTING SPI MODE %d", i);
            
            for (int j = 0; j < 4; j++) begin
            $display("TESTING %d BYTE TRANSMISSION", j + 1);
                repeat(3) begin
                    case(j)
                        0: Test1Byte();
                        1: Test2Byte();
                        2: Test3Byte();
                        3: Test4Byte();
                    endcase
                end
            end
        end        
    end
   
endmodule
