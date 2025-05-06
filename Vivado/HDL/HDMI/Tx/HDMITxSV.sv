`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 04/29/2025 05:49:35 PM
// Design Name: 
// Module Name: HDMITxSV
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


module HDMITxSV import HDMIPackageSV::*;
#
(
    parameter logic DVI_ONLY = 0,
    
    parameter integer unsigned VIDEO_CODE   = 1,
    parameter real VIDEO_CLOCK_MHZ = 74.25,
    parameter integer unsigned VIDEO_DEPTH  = 8,
    
    parameter integer unsigned AUDIO_CLOCK_HZ = 44100,
    parameter integer unsigned AUDIO_DEPTH    = 16,
    parameter integer unsigned AUDIO_CHANNELS = 2,

    parameter logic [63:0]  VENDOR_NAME  = {"EDGELY"},
    parameter logic [123:0] PRODUCT_INFO = {"XILINX ZYNQ-7020"},
    parameter logic [7:0]   DEVICE_INFO  = 8'h00
)
(
    input CLK,
    input CLKDIV,
    input CLKAUDIO,
    input RST,
    input [23:0] VIDDATA,
    input [$bits(AUDIO_DEPTH) - 1 : 0] AUDIODATA,
    output HDMI_TX_PCLK,          // Route to OBUFDS
    output [2:0] HDMI_TX_TMDS      // Route to OBUFDS
);



    initial begin
        assert (!(VIDEO_CODE inside {1, 2, 3, 4, 5, 16, 34}))
            $warning("Invalid parameter VIDEO_CODE in %m - defaulting to VIDEO_CODE = 1 --> 640x480p @ 60Hz");
        assert (!(DVI_ONLY inside {0, 1}))
            $warning("Invalid parameter DVI_ONLY at %m - defaulting to DVI_ONLY = 1.");
        assert (VIDEO_DEPTH != 8) 
            $warning("Only 8-bit depth is supported for %m - defaulting to 8");             
    end    
     
    enum 
    {
        CONTROL    = 0, // Control period
        VID_PREAMB = 1, // Video preamble
        VID_GUARDL = 2, // Video guardband (leading) [there is no tailing video guardband]
        VID_ISLAND = 3, // Video island
        AUX_PREAMB = 4, // Video preamble
        AUX_GUARDL = 5, // Auxil guardband (leading)
        AUX_ISLAND = 6, // Auxil island
        AUX_GUARDT = 7  // Auxil island (tailing)
    } STATE, NEXT_STATE;
              
    logic VDE;
    logic ADE;
    logic HSYNC;
    logic VSYNC;
   
    // 50ms timer - when active, source must send an extended control period of 12 clocks (Table 5-3, Table 5-4)
    logic timer50ms;
    logic [$bits(1 / int'(VIDEO_CLOCK_MHZ * 10**6)) - 1 : 0] timerCounter;
    logic [$bits((50*10**(-3)) * int'(VIDEO_CLOCK_MHZ * 10**6)) - 1 : 0] timerTrigger = ((50*10**(-3)) * int'(VIDEO_CLOCK_MHZ * 10**6));
    
    assign timer50ms = timerCounter == timerTrigger;
    
    always_ff@(posedge CLK) begin
        if (RST) begin
            timerCounter <= 0;
        end else if (~timer50ms) begin
            timerCounter <= timerCounter + 1;
        end
    end
    
    logic CTRL0;
    logic CTRL1;
    logic CTRL2;
    logic CTRL3;
    logic [2:0][9:0] tmdsEncoded;
    logic [2:0][9:0] streamingData;
    logic [2:0][9:0] videoGB;
    logic [2:0][9:0] dataIslandGB;
    
    logic [7:0] pixelCounter;
    logic [9:0] maxPacketSize = 576; // 576 pixels from MSB of first packet to LSB last packet
    logic interlacing;
    logic syncLogicLevel;

    logic [6:0] hSyncStart;
    logic [6:0] hSyncSize;
    logic [10:0] hVideoSize;
    logic [11:0] hTotal;
    
    logic [6:0] vSyncStart;
    logic [6:0] vSyncSize;
    logic [10:0] vVideoSize;
    logic [10:0] vTotal;
    
    logic [11:0] HPOS_reg;
    logic [11:0] VPOS_reg;
    
    // From 5.2.3.2, packet count shall be limited to 18
    localparam MAX_PACKET_COUNT = 18;
    logic[$bits(MAX_PACKET_COUNT) - 1 :0] packetCounter;
    logic[4:0] packetBitCounter; // Goes from 0 to 31
    
    assign videoGB[0] = 10'b1011001100;
    assign videoGB[1] = 10'b0100110011;
    assign videoGB[2] = 10'b1011001100;
    
    assign dataIslandGB[0] = TERC4Encoder({HSYNC, VSYNC, 2'b11});
    assign dataIslandGB[1] = 10'b0100110011;
    assign dataIslandGB[2] = 10'b0100110011;
    
    generate 
        case (VIDEO_CODE)
        1:      // 640x480p @ 60Hz
        begin
            assign interlacing = 0;
            assign hSyncStart = 16;
            assign hSyncSize  = 96;
            assign hVideoSize = 640;
            assign hTotal     = 800;
            
            assign vSyncStart = 10;
            assign vSyncSize = 2;
            assign vVideoSize = 480;
            assign vTotal     = 525;
            assign syncLogicLevel = 0;
        end
        2, 3:   // 720x480p @ 60Hz
        begin
            assign interlacing = 0;
            assign hSyncStart = 16;
            assign hSyncSize  = 62;
            assign hVideoSize = 720;
            assign hTotal     = 858;
            
            assign vSyncStart = 9;
            assign vSyncSize = 6;
            assign vVideoSize = 480;
            assign vTotal     = 525;
            assign syncLogicLevel = 0;  
        end    
        4:      // 1280x720p @ 60Hz
        begin
            assign interlacing = 0;
            assign hSyncStart = 110;
            assign hSyncSize  = 40;
            assign hVideoSize = 1280;
            assign hTotal     = 1650;
            
            assign vSyncStart = 5;
            assign vSyncSize = 5;
            assign vVideoSize = 720;
            assign vTotal     = 750;
            assign syncLogicLevel = 1;
        end
        5:      // 1920x1080i @ 60Hz
        begin
            assign interlacing = 1;
            assign hSyncStart = 88;
            assign hSyncSize  = 44;
            assign hVideoSize = 1920;
            assign hTotal     = 2200;
            
            assign vSyncStart = 2;
            assign vSyncSize = 5;
            assign vVideoSize = 540;
            assign vTotal     = 563;
            assign syncLogicLevel = 1;
        end
        16:     // 1920x1080p @ 60Hz
        begin
            assign interlacing = 0;
            assign hSyncStart = 88;
            assign hSyncSize = 44;
            assign hVideoSize = 1920;
            assign hTotal = 2200;
            
            assign vSyncStart = 4;
            assign vSyncSize = 5;
            assign vVideoSize = 1080;
            assign vTotal = 1125;
        end
        16:     // 1920x1080p @ 60Hz
        begin
            assign interlacing = 0;
            assign hSyncStart = 88;
            assign hSyncSize = 44;
            assign hVideoSize = 1920;
            assign hTotal = 2200;
            
            assign vSyncStart = 4;
            assign vSyncSize = 5;
            assign vVideoSize = 1080;
            assign vTotal = 1125;
        end
        34:
        begin
            assign interlacing = 0;
            assign hSyncStart = 88;
            assign hSyncSize = 44;
            assign hVideoSize = 1920;
            assign hTotal = 2200;
            
            assign vSyncStart = 4;
            assign vSyncSize = 5;
            assign vVideoSize = 1080;
            assign vTotal = 1125;
        end
        default:
        begin
            assign interlacing = 0;
            assign hSyncStart = 16;
            assign hSyncSize  = 96;
            assign hVideoSize = 640;
            assign hTotal     = 800;
            
            assign vSyncStart = 10;
            assign vSyncStart = 2;
            assign vVideoSize = 480;
            assign vTotal     = 525;
            assign syncLogicLevel = 0;
        end        
        endcase   
    endgenerate
    

    // Generate either the DVI transmitter or HDMI transmitter
    generate 
        if (DVI_ONLY == 1) begin
            HDMISerdesSV SERDES 
            (
                .CLK(CLK),
                .CLKDIV(CLKDIV),
                .RST(RST),
                .D({streamingData[2], streamingData[1], streamingData[0]}),
                .PCLK(HDMI_TX_PCLK),
                .Q(HDMI_TX_TMDS)
            );
            
            for (genvar i = 0; i < 3; i++) begin
                DVIEncoderSV DIV_ENC_CH
                (  
                    .CLK(CLK),
                    .RST(RST),
                    .VDE(VDE),
                    .VIDDATA(VIDDATA[7 + (8 * i) : (8 * i)]),
                    .CONTROL(i == 0 ? {VSYNC, HSYNC} : 2'b00),
                    .ENC(tmdsEncoded[i])
                ); 
            end                        
            
        end else if (DVI_ONLY == 0) begin
        
            logic [2:0][3:0] AUXDATA;
            logic [3:0][7:0] packetHeader;
            logic [31:0][7:0] packetBody;
    
            HDMISerdesSV SERDES 
            (
                .CLK(CLK),
                .CLKDIV(CLKDIV),
                .RST(RST),
                .D({tmdsEncoded[2], tmdsEncoded[1], tmdsEncoded[0]}),
                .PCLK(HDMI_TX_PCLK),
                .Q(HDMI_TX_TMDS)
            );
            HDMIPacketWizard 
            #(
                .VIDEO_CODE(VIDEO_CODE),
                .ENCODING("RGB"),
                .VIDEO_CLOCK_MHZ(VIDEO_CLOCK_MHZ),
                .AUDIO_CLOCK_HZ(AUDIO_CLOCK_HZ),
                .AUDIO_DEPTH(AUDIO_DEPTH),
                .AUDIO_CHANNELS(AUDIO_CHANNELS),
                .VENDOR_NAME(VENDOR_NAME),
                .PRODUCT_INFO(PRODUCT_INFO),
                .DEVICE_INFO(DEVICE_INFO)
            )
            PacketWizard
            (
                .CLK(CLK),
                .CLKAUDIO(CLKAUDIO),
                .RST(RST),
                .AUDIODATA(AUDIODATA),
                .PACKETTYPE(packetType),
                .HEADER(packetHeader),
                .PACKETBODY(packetBody)
            );
    
            HDMIEncoderSV ENC0
            (
                .CLK(CLK),
                .RST(RST),
                .VDE(VDE),
                .ADE(ADE),
                .VIDDATA(VIDDATA[7:0]), 
                .AUXDATA(AUXDATA[0]),
                .CONTROL({VSYNC, HSYNC}),
                .ENC(tmdsEncoded[0])
            );
    
            HDMIEncoderSV ENC1
            (
                .CLK(CLK),
                .RST(RST),
                .VDE(VDE),
                .ADE(ADE),
                .VIDDATA(VIDDATA[15:8]), 
                .AUXDATA(AUXDATA[1]),
                .CONTROL({CTRL1, CTRL0}),
                .ENC(tmdsEncoded[1])
            );    
    
            HDMIEncoderSV ENC2
            (
                .CLK(CLK),
                .RST(RST),
                .VDE(VDE),
                .ADE(ADE),
                .VIDDATA(VIDDATA[23:16]), 
                .AUXDATA(AUXDATA[2]),
                .CONTROL({CTRL3, CTRL2}),
                .ENC(tmdsEncoded[2])
            );
            
            always_comb begin
            
                case (STATE)
                CONTROL:    streamingData = tmdsEncoded;
                VID_PREAMB: streamingData = tmdsEncoded;
                VID_GUARDL: streamingData = videoGB;
                VID_ISLAND: streamingData = tmdsEncoded;
                AUX_PREAMB: streamingData = tmdsEncoded;
                AUX_GUARDT: streamingData = dataIslandGB;
                AUX_ISLAND: streamingData = tmdsEncoded;
                AUX_GUARDT: streamingData = dataIslandGB;
                default:    streamingData = tmdsEncoded;
                endcase    
                
                        // ADE enable signal
                if (STATE == AUX_ISLAND) begin
                    ADE = 1;
                end else begin
                    ADE = 0;
                end     
                
                // Next state logic
                case (STATE)
                CONTROL:
                begin
                    if (timer50ms == 1 && pixelCounter < 12) begin
                        NEXT_STATE = CONTROL;
                    end else if (HPOS_reg == hTotal - hVideoSize - 3) begin
                        NEXT_STATE = VID_PREAMB;
                    end else begin
                        NEXT_STATE = CONTROL;
                    end         
                end                 
                VID_PREAMB: NEXT_STATE = pixelCounter == 7 ? VID_GUARDL : VID_PREAMB;
                VID_GUARDL: NEXT_STATE = pixelCounter == 1 ? VID_ISLAND : VID_GUARDL;
                VID_ISLAND: NEXT_STATE = VDE == 1 ? VID_ISLAND : CONTROL;
                AUX_PREAMB: NEXT_STATE = pixelCounter == 7 ? AUX_GUARDL : AUX_PREAMB;
                AUX_GUARDL: NEXT_STATE = pixelCounter == 1 ? AUX_ISLAND : AUX_GUARDL;
                AUX_ISLAND: NEXT_STATE = ADE == 1 ? AUX_ISLAND : AUX_GUARDT; 
                AUX_GUARDT: NEXT_STATE = pixelCounter == 1 ? CONTROL : AUX_GUARDT;
                default:    NEXT_STATE = CONTROL;
                endcase
                
                // AUXDATA logic - refer to section 5.2.3 of the HDMI spec
                case (STATE)
                    AUX_GUARDL, AUX_GUARDT: AUXDATA[0] = {VSYNC, HSYNC, 2'b11};
                    AUX_ISLAND:             AUXDATA[0] = {VSYNC, HSYNC, packetHeader[packetCounter][packetBitCounter], packetBitCounter == 0 ? 1'b0 : 1'b1};
                    default:                AUXDATA[0] = {VSYNC, HSYNC, 2'b11};
                endcase     
                
                AUXDATA[1] = {packetBody[packetCounter][3 + (7 * packetBitCounter)], packetBody[packetCounter][2 + (7 * packetBitCounter)]
                             ,packetBody[packetCounter][1 + (7 * packetBitCounter)], packetBody[packetCounter][0 + (7 * packetBitCounter)]};
                AUXDATA[2] = {packetBody[packetCounter][7 + (7 * packetBitCounter)], packetBody[packetCounter][6 + (7 * packetBitCounter)]
                             ,packetBody[packetCounter][5 + (7 * packetBitCounter)], packetBody[packetCounter][4 + (7 * packetBitCounter)]};             
            end             
        end
    endgenerate    
        

    always_comb begin
        // VSYNC signal logic
        if (VPOS_reg >= vSyncStart && VPOS_reg < vSyncStart + vSyncSize) begin
            VSYNC = syncLogicLevel;
        end else begin
            VSYNC = ~syncLogicLevel;
        end
        
        // HSYNC signal logic
        if (HPOS_reg >= hSyncStart && HPOS_reg < hSyncStart + hSyncSize) begin
            HSYNC = syncLogicLevel;
        end else begin
            HSYNC = ~syncLogicLevel;
        end
        
        // VDE enable signal
        if (HPOS_reg >= (hTotal - hVideoSize) && VPOS_reg >= (vTotal - vVideoSize)) begin
            VDE = 1;
        end else begin
            VDE = 0;
        end
    end
    
    always_ff@(posedge CLK) begin
        if (RST) begin
            HPOS_reg <= 0;
            VPOS_reg <= 0;
            STATE <= CONTROL;
            pixelCounter <= 0;
        end else begin
            STATE <= NEXT_STATE;
            // Update H position and V position
            if (HPOS_reg == hTotal) begin
                HPOS_reg <= 0;
                if (VPOS_reg == vTotal) begin
                    VPOS_reg <= 0;
                end else begin
                    VPOS_reg <= VPOS_reg + 1;
                end             
            end else begin
                HPOS_reg <= HPOS_reg + 1;
            end  
        end
    end 
endmodule
