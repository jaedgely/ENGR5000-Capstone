`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 07:31:19 AM
// Design Name: 
// Module Name: HDMITransmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VALID SETTINGS:
//              480p60
//              720p30
//              720p60
//             1080p30
//             1080i60
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HDMITransmitter import HDMIPackage::*;
#(parameter SETTING = "720p30")
(
    input pclk,
    input tmdsclk,
    input enableVsync,
    input [1:0] pixelEncoding,
    input [3:0] streamingSetting,
    output [2:0] tmds_p,
    output [2:0] tmds_n,
    output pclk_p,
    output pclk_n
);

    STATE_t STATE;
    STATE_t NEXT_STATE;
    
    // Control signals and syncing signals
    logic CTL0;
    logic CTL1;
    logic CTL2;
    logic CLT3;
    logic videoEn;
    logic audioEn;    
    logic HSYNC;
    logic VSYNC;
    
    // Lengths and heights of the area, dependent on the setting
    always_comb begin
    case (streamingSetting)
    3'b000:         
    3'b001:
    3'b010:
    3'b011:
    logic [1:0] videoGuardBandLength;
    logic [11:0] totalDataLength;
    logic [11:0] videoDataLength;
   
    logic [11:0] xPosition;
    logic [11:0] HSYNCStart;
    logic [11:0] HSYNCEnd;
   
    logic [11:0] yPosition;
    logic [11:0] VSYNCStart;
    logic [11:0] VSYNCEnd;
    
    logic [11:0] videoDataHeight;
    logic [11:0] totalDataHeight;
    
    logic [2:0][3:0] terc4Code;
    logic [2:0][7:0] videoData;
    logic [2:0][7:0] audioData;
    logic [2:0][9:0] encodedData;
    
    logic [2:0][9:0] serialized;
    logic [3:0] pixelCounter;
    
    assign pclk_p = pclk;
    assign pclk_n = pclk;
    
    assign HSYNC = (xPosition >= HSYNCStart) & (xPosition < HSYNCEnd);
    assign VSYNC = enableVsync & (yPosition >= VSYNCStart) & (yPosition < VSYNCEnd);

    assign videoEn = (xPosition >= totalDataLength - videoDataLength) & (yPosition >= totalDataHeight - videoDataHeight);
    
    assign tmds_p[0] = serialized[0][0];
    assign tmds_p[1] = serialized[1][0];
    assign tmds_p[2] = serialized[2][0];
    
    assign tmds_n[0] = ~serialized[0][0];
    assign tmds_n[1] = ~serialized[1][0];
    assign tmds_n[2] = ~serialized[2][0];
    
       
    assign videoGuardBandLength = 2'h2;
    
    always_comb begin
        case (SETTING)
        "480p60":   videoDataLength = 480;
        "720p30":   videoDataLength = 720;
        "720p60":   videoDataLength = 720;
        "1080p30":  videoDataLength = 1080;
        "1080i60":  videoDataLength = 1080;
        default:    videoDataLength = 720;
        endcase
    end
    
    always_comb begin
        case (SETTING)
        "480p60":   videoDataHeight = 640;
        "720p30":   videoDataHeight = 1280;
        "720p60":   videoDataHeight = 1280;
        "1080p30":  videoDataHeight = 1920;
        "108s0i60": videoDataHeight = 1920;
        default:    videoDataHeight = 1280;
        endcase
    end   
    
    always_comb begin
        case (STATE)
        VIDEO_PREAMBLE: NEXT_STATE = VIDEO_GUARD;
        VIDEO_GUARD:    NEXT_STATE = yPosition == totalDataHeight - videoDataHeight ? VIDEO_ISLAND : AUXIL_PREAMBLE;
        VIDEO_ISLAND:   NEXT_STATE = xPosition == totalDataLength ? VIDEO_GUARD : VIDEO_ISLAND;
        AUXIL_PREAMBLE: NEXT_STATE = AUXIL_GUARD;
        AUXIL_GUARD:    NEXT_STATE = AUXIL_ISLAND;
        AUXIL_ISLAND:   NEXT_STATE = CONTROL;
        CONTROL:        NEXT_STATE = VIDEO_PREAMBLE;
        default:        NEXT_STATE = VIDEO_PREAMBLE;
        endcase
    end
    
    always_ff@(posedge tmdsclk) begin
        STATE <= NEXT_STATE;
        if (pixelCounter == 10) begin
            serialized[0] = encodedData[0];
            serialized[1] = encodedData[1];
            serialized[2] = encodedData[2];
            xPosition <= xPosition + 1;
            yPosition <= yPosition + (xPosition == totalDataLength);
            if (yPosition == totalDataHeight) begin
                yPosition = 0;
            end
        end else begin
            serialized[0] = {serialized[0][0], serialized[0][9:1]};
            serialized[1] = {serialized[1][0], serialized[1][9:1]};
            serialized[2] = {serialized[2][0], serialized[2][9:1]};
        end
    end
    
    HDMISerializer #(0) HDMIChannel0
    (
        .clk(tmdsclk),
        .state(signal),
        .controlCode({HSYNC, VSYNC}),
        .auxData(terc4Code[0]),
        .videoData(videoData[0]),
        .dataEncoded(encodedData[0])
    ); 
    
    HDMISerializer #(1) HDMIChannel1
    (
        .clk(tmdsclk),
        .state(signal),
        .controlCode({CTL1, CTL0}),
        .auxData(terc4Code[2]),
        .videoData(videoData[2]),
        .dataEncoded(encodedData[1])
    ); 
    
    HDMISerializer #(2) HDMIChannel2
    (
        .clk(tmdsclk),
        .state(signal),
        .controlCode({CTL3, CTL2}),
        .auxData(terc4Code[2]),
        .videoData(videoData[2]),
        .dataEncoded(encodedData[2])
    ); 
 
endmodule
