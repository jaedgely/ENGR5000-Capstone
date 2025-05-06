`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 04/29/2025 05:49:35 PM
// Design Name: 
// Module Name: DVIEncoderSV
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


module DVIEncoderSV import HDMIPackageSV::*;
(
    input CLK,
    input RST,
    input VDE,
    input [7:0] VIDDATA,
    input [1:0] CONTROL,
    output logic [9:0] ENC 
);

    logic usedNot;
    logic usedXor;
    logic signed [3:0] runningDisparity;
    logic [3:0] numberOnesIn;
    logic [3:0] numberOnesInterim;
    logic [3:0] numberZeroesInterim;
    logic signed [3:0] diffOnes;
    logic [7:0] dataInterim;

    function automatic logic [3:0] CountOnesInByte(input logic [7:0] data);
        CountOnesInByte = 0;
        for (int i = 0; i < 8; i++) begin
            CountOnesInByte = CountOnesInByte + data[i];
        end
    endfunction
    
    function automatic logic [7:0] EncodingXOR(input logic [7:0] data);
        EncodingXOR[0] = data[0];
        for (int i = 1; i < 8; i++) begin
            EncodingXOR[i] = data[i] ^ EncodingXOR[i - 1];
        end
    endfunction
    
    function automatic logic [7:0] EncodingXNOR(logic [7:0] data);
        EncodingXNOR[0] = data[0];
        for (int i = 1; i < 8; i++) begin
            EncodingXNOR[i] = data[i] ~^ EncodingXNOR[i - 1];
        end
    endfunction
    
    assign dataInterim = usedXor ? EncodingXOR(VIDDATA) : EncodingXNOR(VIDDATA);
    assign diffOnes = (numberOnesInterim << 1) - 'd8; 
    assign numberOnesIn = CountOnesInByte(VIDDATA);
    assign numberOnesInterim = CountOnesInByte(dataInterim);
    
    always_comb begin
        if (numberOnesIn > 4 || (numberOnesIn == 4 && VIDDATA[0] == 0)) begin
            usedXor = 0;
        end else begin
            usedXor = 1;
        end
    end
    
    always_comb begin
        if (runningDisparity == 0 || numberOnesInterim == 4) begin
            usedNot = ~usedXor;
        end else if ((runningDisparity > 0 && numberOnesInterim > 4) || (runningDisparity < 0 && numberOnesInterim < 4)) begin
            usedNot = 1;
        end else begin
            usedNot = 0;
        end
    end
    
    always_ff@(posedge CLK) begin
        if (RST) begin
            runningDisparity <=0;
            ENC <= COM00;
        end else begin    
            if (VDE) begin
                ENC <= {usedNot, usedXor , usedNot ? ~dataInterim : dataInterim};
                if (runningDisparity == 0 || numberOnesInterim == 4) begin
                    runningDisparity <= runningDisparity + (usedXor ? diffOnes : -(diffOnes));
                end else if ((runningDisparity > 0 && numberOnesInterim > 4) || (runningDisparity < 0 && numberOnesInterim < 4)) begin
                    runningDisparity <= runningDisparity + 2'(usedXor << 1) - diffOnes;
                end else begin
                    runningDisparity <= runningDisparity - 2'(~usedXor << 1) + diffOnes; 
                end
            end else begin    
                runningDisparity <= 0;
                case (CONTROL)
                'b00: ENC <= COM00;
                'b01: ENC <= COM01;
                'b10: ENC <= COM10;
                'b11: ENC <= COM11;
                endcase 
            end
        end 
    end
endmodule
