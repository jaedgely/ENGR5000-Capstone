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
    
    typedef enum logic [9:0]
    {
        TERC4_0 = 10'b10_1001_1100,
        TERC4_1 = 10'b10_0110_0011,
        TERC4_2 = 10'b10_1110_0100,
        TERC4_3 = 10'b10_1110_0010,
        TERC4_4 = 10'b01_0111_0001,
        TERC4_5 = 10'b01_0001_1110,
        TERC4_6 = 10'b01_1000_1110,
        TERC4_7 = 10'b01_0011_1100,
        TERC4_8 = 10'b10_1100_1100,
        TERC4_9 = 10'b01_0011_1001,
        TERC4_A = 10'b01_1001_1100,
        TERC4_B = 10'b10_1100_0110,
        TERC4_C = 10'b10_1000_1110,
        TERC4_D = 10'b10_0111_0001,
        TERC4_E = 10'b01_0110_0011,
        TERC4_F = 10'b10_1100_0011
    } TERC4Encoded_t;
    
    function automatic logic [9:0] TERC4Encoder(input logic [3:0] decoded);
        case (decoded)
        4'h0:    TERC4Encoder = TERC4_0;
        4'h1:    TERC4Encoder = TERC4_1;
        4'h2:    TERC4Encoder = TERC4_2;
        4'h3:    TERC4Encoder = TERC4_3;
        4'h4:    TERC4Encoder = TERC4_4;
        4'h5:    TERC4Encoder = TERC4_5;
        4'h6:    TERC4Encoder = TERC4_6;
        4'h7:    TERC4Encoder = TERC4_7;
        4'h8:    TERC4Encoder = TERC4_8;
        4'h9:    TERC4Encoder = TERC4_9;
        4'hA:    TERC4Encoder = TERC4_A;
        4'hB:    TERC4Encoder = TERC4_B;
        4'hC:    TERC4Encoder = TERC4_C;
        4'hD:    TERC4Encoder = TERC4_D;
        4'hE:    TERC4Encoder = TERC4_E;
        4'hF:    TERC4Encoder = TERC4_F;
        default: TERC4Encoder = TERC4_0;
        endcase  
    endfunction
    
    function automatic logic [3:0] TERC4Decoder(input logic [9:0] encoded);
        case(encoded)
        TERC4_0: TERC4Decoder = 4'h0;
        TERC4_1: TERC4Decoder = 4'h1;
        TERC4_2: TERC4Decoder = 4'h2;
        TERC4_3: TERC4Decoder = 4'h3;
        TERC4_4: TERC4Decoder = 4'h4;
        TERC4_5: TERC4Decoder = 4'h5;
        TERC4_6: TERC4Decoder = 4'h6;
        TERC4_7: TERC4Decoder = 4'h7;
        TERC4_8: TERC4Decoder = 4'h8;
        TERC4_9: TERC4Decoder = 4'h9;
        TERC4_A: TERC4Decoder = 4'hA;
        TERC4_B: TERC4Decoder = 4'hB;
        TERC4_C: TERC4Decoder = 4'hC;
        TERC4_D: TERC4Decoder = 4'hD;
        TERC4_E: TERC4Decoder = 4'hE;
        TERC4_F: TERC4Decoder = 4'hF;
        default: TERC4Decoder = 4'h0;
        endcase
    endfunction
    
    typedef enum logic[9:0]
    {
        VGB_CH0 = 10'b10_1100_1100,
        VGB_CH1_CH2 = 10'b01_0011_0011
    } VideoGuardBand_t;
  
    typedef enum logic[9:0]
    {
        DIGB_CH0 = 10'b00_0000_0000,
        DIGB_CH1_CH2 = 10'b01_0011_0011
    } DataIslandGuardBand_t;
    
    typedef enum logic[2:0]
    {
        VIDEO_PREAMBLE = 3'b000,
        VIDEO_GUARD    = 3'b001,
        VIDEO_ISLAND   = 3'b010,
        AUXIL_PREAMBLE = 3'b011,
        AUXIL_GUARD    = 3'b100,
        AUXIL_ISLAND   = 3'b101,
        CONTROL        = 3'b111
    } STATE_t;
    
    typedef enum logic[1:0]
    {
        RGB444 = 0,
        YCC422 = 1,
        YCC444 = 2
    } PixelEncoding_t;
    
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
