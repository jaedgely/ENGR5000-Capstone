`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 03:00:01 PM
// Design Name: 
// Module Name: HDMI_TMDS_PACKAGE
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

package HDMIPackage;
    typedef enum logic[7:0]
    {
        NullPacket = 8'h00,
        AudioClockRegen = 8'h01,
        AudioSample = 8'h02,
        GenControl = 8'h03,
        ACPPacket = 8'h04,
        ISRC1Packet = 8'h05,
        ISRC2Packet = 8'h06,
        OBAPacket = 8'h07,
        DSTAPacket = 8'h08,
        HBRAudtioPacket = 8'h09,
        GamutMetadata = 8'h0A,
        InfoFramePacket = 8'h80,
        VendorSpecificInfo = 'h81,
        AVIInfo = 'h82,
        SourceDescriptor = 'h83,
        AudoInfoFrame = 'h84,
        MPEGInfoFrame = 'h85
    } PacketType_t;
    
    typedef enum logic[9:0]
    {
        COM00 = 10'b11_0101_0100,
        COM01 = 10'b00_1010_1011,
        COM10 = 10'b01_0101_0100,
        COM11 = 10'b10_1010_1011
    } ControlCodes_t;

    typedef enum logic[9:0]
    {
        VGB_CH0 = 10'b10_1100_1100,
        VGB_CH1_CH2 = 10'b01_0011_0011
    } VideoGuardBand_t;
  
    // CH0 NOT VALID
    typedef enum logic[9:0]
    {
        DIGB_CH0 = 10'b00_0000_0000,
        DIGB_CH1_CH2 = 10'b01_0011_0011
    } DataIslandGuardBand_t;
    
    typedef struct packed
    {
        logic[2:0][7:0] Header;
        logic[55:0][3:0] Subpacket;
        logic[2:0][2:0] Parity;
    } DataIslandPacket_t;

    typedef struct packed 
    {
        logic Inverted;
        logic UsedXor;
        logic[7:0] EncodedData;
    } TMDSEncoded_t;
    
    function automatic logic[7:0] GenerateGuardban(input logic unsigned [2:0] CH);
        case(CH)
            'b00: begin end
            'b01: begin end
            'b10: begin end
            default: begin end
        endcase
    endfunction
    
    // function automatic logic[23:0] GenerateHeader(input PACKET_TYPE PACKET)
    //function automatic logic[2:0][7:0]GenerateHeader(input logic[1:0] CHANNEL);
    function automatic logic[2:0][7:0]GenerateHeader(input PacketType_t PACKET, input[2:0][7:0] ACC_DATA);
        case (PACKET)
            NullPacket:begin
                        GenerateHeader[2] = 8'h00;
                        GenerateHeader[1] = 8'h00;
                        GenerateHeader[0] = 8'h00;
                        end
            AudioClockRegen:begin
                        GenerateHeader[2] = 8'b0000_0001;
                        GenerateHeader[1] = 8'h00;
                        GenerateHeader[0] = 8'h00;
                        end
            AudioSample:begin
                        GenerateHeader[2] = 8'b0000_0010;
                        GenerateHeader[1] = {3'b000, ACC_DATA[1][4:0]};
                        GenerateHeader[0] = ACC_DATA[0];
                        end
            GenControl: begin
                        GenerateHeader[2] = 8'b0000_0001;
                        GenerateHeader[1] = 8'h00;
                        GenerateHeader[0] = 8'h00;
                        end
            // Unsure of this
            ACPPacket:  begin
                        GenerateHeader[2] = ACC_DATA[2];
                        GenerateHeader[1] = ACC_DATA[1];
                        GenerateHeader[0] = ACC_DATA[0];
                        end
            /*
            ISRC1Packet:
            ISRC2Packet:
            OBAPacket:
            */
            DSTAPacket: begin
                        GenerateHeader[2] = 8'b0000_1000;
                        GenerateHeader[1] = {ACC_DATA[1][7:6], 6'b000000};
                        GenerateHeader[0] = 8'h00;
                        end
            HBRAudtioPacket: begin
                        GenerateHeader[2] = 8'b0000_1001;
                        GenerateHeader[1] = {ACC_DATA[1][7:6], 6'b000000};
                        GenerateHeader[0] = {ACC_DATA[0][7:4], 4'b0000};
                        end
            /*
            GamutMetadata:
            InfoFramePacket:
            VendorSpecificInfo:
            AVIInfo:
            SourceDescriptor:
            AudoInfoFrame:
            MPEGInfoFrame:
            */
            default:begin
                        GenerateHeader[2] = 8'h00;
                        GenerateHeader[1] = 8'h00;
                        GenerateHeader[0] = 8'h00;
                    end
        endcase
    endfunction        
endpackage
