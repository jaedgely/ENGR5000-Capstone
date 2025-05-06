`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 04/29/2025 05:49:35 PM
// Design Name: 
// Module Name: HDMI_Source
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


module HDMI_Source
#
(
    parameter integer DVI_ONLY = 0,
    parameter integer VIDEO_CODE = 1,
    parameter real VIDEO_CLOCK_MHZ = 74.25,
    parameter integer VIDEO_DEPTH = 8,
    
    parameter integer AUDIO_CLOCK_HZ = 44100,
    parameter integer AUDIO_DEPTH    = 16,
    parameter integer AUDIO_CHANNELS = 2,
    
    parameter VENDOR_NAME = "UNKNOWN",
    parameter PRODUCT_INFO = "PROG. GATE ARRAY",
    parameter DEVICE_INFO = 8'h00
)
(
    input CLK,
    input CLKDIV,
    input CLKAUDIO,
    input RST,
    input [23:0] VIDDATA,
    input [$clog2(AUDIO_DEPTH) - 1 : 0] AUDIODATA,
    output wire HDMI_TX_PCLK_P,
    output wire HDMI_TX_PCLK_N,
    output wire [2:0] HDMI_TX_TMDS_P,
    output wire [2:0] HDMI_TX_TMDS_N
);

    wire HDMI_TX_PCLK;
    wire [2:0] HDMI_TX_TMDS;

    // Vivado does NOT infer differential buffers - they must be explicitly stated
    OBUFDS 
    #(
        .IOSTANDARD("TMDS_33"), 
        .SLEW("FAST")           
    ) OBUFDS_HDMI_TX_PCLK (
        .O(HDMI_TX_PCLK_P),     
        .OB(HDMI_TX_PCLK_N),   
        .I(HDMI_TX_PCLK)      
    );
    
    generate 
        for (genvar i = 0; i < 3; i = i + 1) begin
            OBUFDS 
            #(
                .IOSTANDARD("TMDS_33"), 
                .SLEW("FAST")           
            ) OBUFDS_HDMI_TX_TMDS (
                .O(HDMI_TX_TMDS_P[i]),     
                .OB(HDMI_TX_TMDS_N[i]),   
                .I(HDMI_TX_TMDS[i])      
            ); 
        end       
    endgenerate
    
    HDMITxSV
    #(
        .DVI_ONLY(DVI_ONLY),
        .VIDEO_CODE(VIDEO_CODE),
        .VIDEO_CLOCK_MHZ(VIDEO_CLOCK_MHZ),
        .VIDEO_DEPTH(VIDEO_DEPTH),
        
        .AUDIO_CLOCK_HZ(AUDIO_CLOCK_HZ),
        .AUDIO_DEPTH(AUDIO_DEPTH),
        .AUDIO_CHANNELS(AUDIO_CHANNELS),
        
        .VENDOR_NAME({"JAEDGELY"}),
        .PRODUCT_INFO({"XILINX ZYNQ-7020"}),
        .DEVICE_INFO(8'b00)
    )
    HDMI_TX
    (
        .CLK(CLK),
        .CLKDIV(CLKDIV),
        .CLKAUDIO(CLKAUDIO),
        .RST(RST),
        .VIDDATA(VIDDATA),
        .AUDIODATA(AUDIODATA),
        .HDMI_TX_PCLK(HDMI_TX_PCLK),
        .HDMI_TX_TMDS(HDMI_TX_TMDS)
    );
endmodule
