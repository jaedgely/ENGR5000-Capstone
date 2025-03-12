`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 09:47:12 AM
// Design Name: 
// Module Name: HDMISerializer
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

module HDMISerializer import HDMIPackage::*;
#(parameter logic [1:0] CHANNEL = 0)
(
    input clk,
    input STATE_t state,
    input [1:0] controlCode,
    input [3:0] auxData,
    input [7:0] videoData,
    output logic [9:0] dataEncoded
);
    
    logic [9:0] videoGuardBand;
    logic [9:0] dataIslandGuardBand;
    logic [9:0] tmdsEncoded;
    
    always_comb begin
        case (CHANNEL)
        0:       videoGuardBand = 10'b10_1100_1100;
        1:       videoGuardBand = 10'b01_0011_0011;
        2:       videoGuardBand = 10'b10_1100_1100;
        default: videoGuardBand = 10'b10_1100_1100;
        endcase
    end
    
    always_comb begin
        case (CHANNEL)
        0:      dataIslandGuardBand = TERC4Encoder({2'b11, controlCode}); // Encodes as 'hC, 'hD, 'hE, or 'hF
        1:      dataIslandGuardBand = 10'b01_0011_0011;
        2:      dataIslandGuardBand = 10'b01_0011_0011;
        default:dataIslandGuardBand = 10'b01_0011_0011;
        endcase
    end
    
    always_comb begin
        case (state)
        VIDEO_PREAMBLE: dataEncoded = tmdsEncoded;
        VIDEO_GUARD:    dataEncoded = videoGuardBand;
        VIDEO_ISLAND:   dataEncoded = tmdsEncoded;
        AUXIL_PREAMBLE: dataEncoded = tmdsEncoded;
        AUXIL_GUARD:    dataEncoded = dataIslandGuardBand;
        AUXIL_ISLAND:   dataEncoded = TERC4Encoder(auxData);
        CONTROL:        dataEncoded = tmdsEncoded;
        default:        dataEncoded = tmdsEncoded;
        endcase
    end 
    
    TMDSEncoder Encoder
    (
        .clk(clk),
        .enable(VIDEO_DATA),
        .controlCom(controlCode),
        .dataTx(videoData),
        .dataEncoded(tmdsEncoded)
    );  

endmodule
