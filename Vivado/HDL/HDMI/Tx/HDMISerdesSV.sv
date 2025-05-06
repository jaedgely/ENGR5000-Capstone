`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 04/29/2025 07:42:59 PM
// Design Name: 
// Module Name: HDMISerdesSV
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


module HDMISerdesSV
(
    input CLK,
    input CLKDIV,
    input RST,
    input [2:0][9:0] D,
    output PCLK,
    output [2:0] Q
);

    logic MISOCLK1;
    logic MISOCLK2;
    OSERDESE2 #( .DATA_RATE_OQ("DDR"), .DATA_RATE_TQ("SDR"), .DATA_WIDTH(10),         
                     .INIT_OQ(1'b0), .INIT_TQ(1'b0), .SERDES_MODE("MASTER"), 
                     .SRVAL_OQ(1'b0), .SRVAL_TQ(1'b0), .TBYTE_CTL("FALSE"),  
                     .TBYTE_SRC("FALSE"), .TRISTATE_WIDTH(1))
    SerMasterCLK
    (
       .OFB(OFB),             // 1-bit output: Feedback path for data
       .OQ(PCLK),               // 1-bit output: Data path output
       // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
       .SHIFTOUT1(SHIFTOUT1M),
       .SHIFTOUT2(SHIFTOUT2M),
       .TBYTEOUT(TBYTEOUTM),   // 1-bit output: Byte group tristate
       .TFB(TFBM),             // 1-bit output: 3-state control
       .TQ(TQM),               // 1-bit output: 3-state control
       .CLK(CLK),             // 1-bit input: High speed clock
       .CLKDIV(CLKDIV),       // 1-bit input: Divided clock
       // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
       .D1(1'b1),
       .D2(1'b1),
       .D3(1'b1),
       .D4(1'b1),
       .D5(1'b1),
       .D6(1'b0),
       .D7(1'b0),
       .D8(1'b0),
       .OCE(1'b1),             // 1-bit input: Output data clock enable
       .RST(RST),             // 1-bit input: Reset
       // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
       .SHIFTIN1(MISOCLK1),
       .SHIFTIN2(MISOCLK2),
       // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
       .T1(1'b0),
       .T2(1'b0),
       .T3(1'b0),
       .T4(1'b0),
       .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
       .TCE(1'b0)              // 1-bit input: 3-state clock enable
    );
        
    OSERDESE2 #( .DATA_RATE_OQ("DDR"), .DATA_RATE_TQ("SDR"), .DATA_WIDTH(10),         
             .INIT_OQ(1'b0), .INIT_TQ(1'b0), .SERDES_MODE("SLAVE"), 
             .SRVAL_OQ(1'b0), .SRVAL_TQ(1'b0), .TBYTE_CTL("FALSE"),  
             .TBYTE_SRC("FALSE"), .TRISTATE_WIDTH(1))
    SerSlaveCLK
    (
       .OFB(OFBS),             // 1-bit output: Feedback path for data
       .OQ(OQSCLK),               // 1-bit output: Data path output
       // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
       .SHIFTOUT1(MISOCLK1),
       .SHIFTOUT2(MISOCLK2),
       .TBYTEOUT(TBYTEOUTS),   // 1-bit output: Byte group tristate
       .TFB(TFBS),             // 1-bit output: 3-state control
       .TQ(TQS),               // 1-bit output: 3-state control
       .CLK(CLK),             // 1-bit input: High speed clock
       .CLKDIV(CLKDIV),       // 1-bit input: Divided clock
       // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
       .D1(1'bX),
       .D2(1'bX),
       .D3(1'b0),
       .D4(1'b0),
       .D5(1'bX),
       .D6(1'bX),
       .D7(1'bX),
       .D8(1'bX),
       .OCE(1'b1),             // 1-bit input: Output data clock enable
       .RST(RST),             // 1-bit input: Reset
       // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
       .SHIFTIN1(1'b0),
       .SHIFTIN2(1'b0),
       // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
       .T1(1'b0),
       .T2(1'b0),
       .T3(1'b0),
       .T4(1'b0),
       .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
       .TCE(1'b0)              // 1-bit input: 3-state clock enable
    );  
    
    generate
    
        logic [2:0] MISO1;
        logic [2:0] MISO2;
      
        for (genvar i = 0; i < 3; i++) begin
            OSERDESE2 #( .DATA_RATE_OQ("DDR"), .DATA_RATE_TQ("SDR"), .DATA_WIDTH(10),         
                         .INIT_OQ(1'b0), .INIT_TQ(1'b0), .SERDES_MODE("MASTER"), 
                         .SRVAL_OQ(1'b0), .SRVAL_TQ(1'b0), .TBYTE_CTL("FALSE"),  
                         .TBYTE_SRC("FALSE"), .TRISTATE_WIDTH(1))
            SerMaster
            (
               .OFB(),             // 1-bit output: Feedback path for data
               .OQ(Q[i]),               // 1-bit output: Data path output
               // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
               .SHIFTOUT1(),
               .SHIFTOUT2(),
               .TBYTEOUT(),   // 1-bit output: Byte group tristate
               .TFB(),             // 1-bit output: 3-state control
               .TQ(),               // 1-bit output: 3-state control
               .CLK(CLK),             // 1-bit input: High speed clock
               .CLKDIV(CLKDIV),       // 1-bit input: Divided clock
               // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
               .D1(D[i][0]),
               .D2(D[i][1]),
               .D3(D[i][2]),
               .D4(D[i][3]),
               .D5(D[i][4]),
               .D6(D[i][5]),
               .D7(D[i][6]),
               .D8(D[i][7]),
               .OCE(1'b1),             // 1-bit input: Output data clock enable
               .RST(RST),             // 1-bit input: Reset
               // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
               .SHIFTIN1(MISO1[i]),
               .SHIFTIN2(MISO2[i]),
               // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
               .T1(1'b0),
               .T2(1'b0),
               .T3(1'b0),
               .T4(1'b0),
               .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
               .TCE(1'b0)              // 1-bit input: 3-state clock enable
            );
            
            OSERDESE2 #( .DATA_RATE_OQ("DDR"), .DATA_RATE_TQ("SDR"), .DATA_WIDTH(10),         
                     .INIT_OQ(1'b0), .INIT_TQ(1'b0), .SERDES_MODE("SLAVE"), 
                     .SRVAL_OQ(1'b0), .SRVAL_TQ(1'b0), .TBYTE_CTL("FALSE"),  
                     .TBYTE_SRC("FALSE"), .TRISTATE_WIDTH(1))
            SerSlave
            (
               .OFB(),             // 1-bit output: Feedback path for data
               .OQ(),               // 1-bit output: Data path output
               // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
               .SHIFTOUT1(MISO1[i]),
               .SHIFTOUT2(MISO2[i]),
               .TBYTEOUT(),   // 1-bit output: Byte group tristate
               .TFB(),             // 1-bit output: 3-state control
               .TQ(),               // 1-bit output: 3-state control
               .CLK(CLK),             // 1-bit input: High speed clock
               .CLKDIV(CLKDIV),       // 1-bit input: Divided clock
               // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
               .D1(1'bX),
               .D2(1'bX),
               .D3(D[i][8]),
               .D4(D[i][9]),
               .D5(1'bX),
               .D6(1'bX),
               .D7(1'bX),
               .D8(1'bX),
               .OCE(1'b1),             // 1-bit input: Output data clock enable
               .RST(RST),             // 1-bit input: Reset
               // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
               .SHIFTIN1(1'b0),
               .SHIFTIN2(1'b0),
               // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
               .T1(1'b0),
               .T2(1'b0),
               .T3(1'b0),
               .T4(1'b0),
               .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
               .TCE(1'b0)              // 1-bit input: 3-state clock enable
            ); 
        end
    endgenerate
endmodule
