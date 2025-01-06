`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/01/2025 03:51:05 PM
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
    logic opCode;
    logic forceClock;
    logic [1:0] bytesToSend;
    logic [6:0] address;
    logic [15:0] dataTx;
    logic [15:0] dataRx;   // Try to load 0xCE11
    logic busyBit;
    logic nackBit;
    
    wire SDA;
    wire SCL;
    
    pullup(SDA);
    pullup(SCL);

    I2CController #(2)DUT
    (
        .clk(clock),
        .rst_n(reset),
        .start(start),
        .OP_CODE(opCode),
        .FORCE_CLK(forceClock),
        .bytesToSend(bytesToSend),
        .PERIPH_ADDR(address),
        .D_TX(dataTx),
        .Q_RX(dataRx),
        .BUSY(busyBit),
        .NACK(nackBit),
        .I2C_SCL_t(SCL),
        .I2C_SDA_t(SDA)
    );
    
    // 100KHz - slowest i2c speed
    task CycleClocks(); 
        clock = ~clock; #1250;
        clock = ~clock; #1250;
    endtask
    
    task WriteData(logic [6:0] pAddr, logic [15:0] data, logic[1:0] numBytes, logic addrAck, logic dataAck0, logic dataAck1);
        start = 0;
        $display("Testing I2C Controller write functionality.");
        $display("\t Targeting device 0x%h with data 0x%h.", pAddr, data);
        $display("\t Will force the following: ADDR_ACK = %b, DATA_ACK_0 = %b, DATA_ACK_1 = %b", addrAck, dataAck0, dataAck1);
                 
        address = pAddr;
        opCode = 0;
        dataTx = data;
        bytesToSend = numBytes;
        
        $display("\t Writing 0x%h to device 0x%h", data, pAddr);
        
        start = 1;
        
        for (int i = 0; i < 35; i++) begin
            $display("Cycle %d", i);
            CycleClocks();
        end
        
        TestACK(0);
        
        // 8 data bits + 1 ack == 9
        repeat(31) begin;
            CycleClocks();
        end
        TestACK(0);
        
        repeat(31) begin;
            CycleClocks();
        end
        TestACK(0);
        
        repeat(8) begin;
            CycleClocks(); 
        end
        
    endtask    
    
    task ReadData(logic[6:0] pAddr, logic[15:0] data, logic[1:0] numbytes);
        start = 0;
        $display("Testing I2C Controller read functionality.");
        $display("\t Targeting device 0x%h with data 0x%h.", pAddr, data);
                 
        address = pAddr;
        opCode = 1;
        dataTx = data;
        bytesToSend = numbytes;
        
        $display("\t Writing 0x%h to device 0x%h", data, pAddr);
        
        start = 1;
        
        // 1 start bit + 7 addr + 1 command = 9 bits
        // 4 * 9 = 36
        repeat(36) begin;
            CycleClocks();
        end
        start = 0;
        TestACK(0);
        
        // 8 data bits + 1 ack == 9
        repeat(31) begin;
            CycleClocks();
        end
        TestACK(0);
        
        repeat(31) begin;
            CycleClocks();
        end
        TestACK(0);
        
        repeat(8) begin;
            CycleClocks(); 
        end
    endtask;
    
    task TestACK(logic NACK);
        clock = ~clock; #1240;
        #10;
        CheckSDATristate();
        force SDA = NACK;      
        CycleClocks();
        //$display("\t Wrote %b to SDA line", NACK);
        CycleClocks();
        
        assert(nackBit == NACK)
            $display("\t Pass - NACK output matches expected value");
        else
            $display("\t Fail - NACK output does not match expected. Measured %d, expected %d", nackBit, NACK);

        CycleClocks();
        CycleClocks();
        release SDA;
    endtask;
     
    task CheckSDATristate();
        assert(SDA === 1'b1)    // Due to pullup, will pulse 1
            $display("\t Pass - I2C Controller succesfully tri-stated I2C_SDA line before next I2C_SCL pulse");
        else
            $display("\t Fail - I2C Controller is still driving I2C_SDA_t to %d", SDA);
    endtask
  
    
    initial begin
        clock = 0;
        reset = 0;
        start = 0;
        opCode = 0;
        forceClock = 0;
        bytesToSend = 1;
        address = 'hFF;
        dataTx = 'hFFFF;
        CycleClocks();
        CycleClocks();
        CycleClocks();
        CycleClocks();
        reset = 1;
        CycleClocks();
        CycleClocks();
        CycleClocks();  
        CycleClocks();    
        
        WriteData('hA5, 'h550F, 1, 0, 0, 0);
        ReadData('h24, 'hABCD, 1);
        reset = 0;
        repeat(25) begin;
            CycleClocks();
        end
            
        reset = 1;
        repeat(25) begin;
            CycleClocks();
        end
        WriteData('hD3, 'hDEAD, 1, 0, 0, 0); 

        WriteData('h35, 'hCC00, 0, 0, 0, 0);
    end
    
endmodule
