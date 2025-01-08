`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2025 06:54:46 PM
// Design Name: 
// Module Name: GPIOBuffer_tb
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


module GPIOBuffer_tb();

    logic dcIn;
    logic tristateEn;
    logic gpio;
    logic dcOut;
    
    GPIOBuffer DUT
    (
        .dataTx(dcIn),
        .triEn(tristateEn),
        .dataRx(dcOut),
        .GPIO_t(gpio)
    );
        
    initial begin
        dcIn = 0;
        tristateEn = 0;
        
        // Check tristate is active HIGH
        tristateEn = 1; 
        dcIn = 0;
        #1;
        assert(gpio === 'Z) 
            $display("Pass - GPIO Pin is in high-impedence when enable signal is high. Measured %d, expected Z", gpio);
        else
            $display("Fail - GPIO Pin is not in Hi-Z! Measured %d, expected Z", gpio);
            
        dcIn = 1;
        #1;
        assert(gpio === 'Z) 
            $display("Pass - GPIO Pin is in high-impedence when enable signal is high. Measured %d, expected Z", gpio);
        else
            $display("Fail - GPIO Pin is not in Hi-Z! Measured %d, expected Z", gpio);
        
        tristateEn = 0;
        
        dcIn = 0; #1;
        assert(gpio == dcIn) 
            $display("Pass - GPIO output matches input. Measured %d, expected %d", gpio, dcIn);
        else
            $display("Fail - GPIO output does not match input, expected %d", gpio, dcIn);
            
        assert(dcOut == dcIn)   
            $display("Pass - DC reading matches expected input. Measured %d, expected %d", dcOut, dcIn);
        else
            $display("Fail - DC reading does not match expected input. Measured %d, expected %d", dcOut, dcIn);
           
        dcIn = 1; #1;
        assert(gpio == dcIn) 
            $display("Pass - GPIO output matches input. Measured %d, expected %d", gpio, dcIn);
        else
            $display("Fail - GPIO output does not match input, expected %d", gpio, dcIn);
            
        assert(dcOut == dcIn)   
            $display("Pass - DC reading matches expected input. Measured %d, expected %d", dcOut, dcIn);
        else
            $display("Fail - DC reading does not match expected input. Measured %d, expected %d", dcOut, dcIn);
    
    end        
endmodule
