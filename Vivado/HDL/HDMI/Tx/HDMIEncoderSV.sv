`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 04/29/2025 05:49:35 PM
// Design Name: 
// Module Name: HDMIEncoderSV
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


module HDMIEncoderSV import HDMIPackageSV::*;
(
    input CLK,
    input RST,
    input VDE,
    input ADE,
    input [7:0] VIDDATA,
    input [3:0] AUXDATA,
    input [1:0] CONTROL,
    output logic [9:0] ENC 
);

    logic [9:0] dviEncoded;
    
    always_comb begin
        if (ADE == 1 && VDE == 0) begin
            ENC = TERC4Encoder(AUXDATA);
        end else begin
            ENC = dviEncoded;
        end       
    end
    
    DVIEncoderSV DVIEnc
    (
        .CLK(CLK),
        .RST(RST),
        .VDE(VDE),
        .VIDDATA(VIDDATA),
        .CONTROL(CONTROL),
        .ENC(dviEncoded)
    );

endmodule
