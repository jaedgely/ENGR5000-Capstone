`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 03/11/2025 06:33:28 PM
// Design Name: 
// Module Name: TMDSDecoder
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

module TMDSDecoder import HDMIPackage::*;
(
    input clk,
    input [9:0] dataTx,
    output logic enabled,
    output logic [1:0] controlCom,
    output logic [7:0] decoded
);

    logic [7:0] dataInterim;

    function automatic logic [7:0] DecodingXOR (input logic [7:0] data);
        DecodingXOR[0] = data[0];
        for (int i = 1; i < 8; i++) begin
            DecodingXOR[i] = data[i] ^ data[i - 1];
        end
    endfunction
    
    function automatic logic [7:0] DecodingXNOR (input logic [7:0] data);
        DecodingXNOR[0] = data[0];
        for (int i = 1; i < 8; i++) begin
            DecodingXNOR[i] = data[i] ~^ data[i - 1];
        end
    endfunction

    assign dataInterim = dataTx[9] ? ~dataTx[7:0] : dataTx[7:0];
    
    always_ff@(posedge clk) begin
    
        if (dataTx inside {COM00, COM01, COM10, COM11}) begin
            enabled <= 0;
            case (dataTx)
                COM00:  controlCom = 2'b00;
                COM01:  controlCom = 2'b01;
                COM10:  controlCom = 2'b10;
                COM11:  controlCom = 2'b11;
                default:controlCom = 2'b00;
            endcase 
            decoded <= decoded;
        end else begin
            enabled <= 1;
            controlCom <= controlCom;
            decoded <= dataTx[8] ? DecodingXOR(dataInterim) : DecodingXNOR(dataInterim);
        end
    end
endmodule
