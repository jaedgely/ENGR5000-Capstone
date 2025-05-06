`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Jack Edgely
// Engineer: Wentworth Institute of Technology
// 
// Create Date: 04/30/2025 09:33:42 AM
// Design Name: 
// Module Name: HDMIPacketWizard
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
//  The packet wizard generates all data necessary for aux packets.
//  Any packet can be selected and then processed by the top-level HDMI module
//  All processes related to creating packet headers, bodies, checksums, and error correction is contained in this module
//////////////////////////////////////////////////////////////////////////////////


module HDMIPacketWizard    
#(
    parameter integer unsigned VIDEO_CODE     = 1,
    parameter string ENCODING                 = "RGB",
    parameter bit DEFAULT_PHASE               = 0,
    parameter integer unsigned COLOR_DEPTH    = 24,
    parameter real VIDEO_CLOCK_MHZ            = 74.25,
    parameter integer unsigned AUDIO_CLOCK_HZ = 44100,
    parameter integer unsigned AUDIO_DEPTH    = 16,
    parameter integer unsigned AUDIO_CHANNELS = 2,
    parameter logic [7:0][7:0]  VENDOR_NAME   = {"UNKNOWN"},
    parameter logic [15:0][7:0] PRODUCT_INFO  = {"PROG. GATE ARRAY"},
    parameter logic [7:0]   DEVICE_INFO       = 8'h00
)(    
    input CLK,
    input CLKAUDIO,
    input RST,
    input CLEAR_AVMUTE,
    input SET_AVMUTE,
    input [$bits(AUDIO_DEPTH) - 1 : 0] AUDIODATA,
    input [7:0] PACKETTYPE,
    output logic [3:0][7:0] HEADER, // 1 byte packet header, 2 bytes data, 1 for ECC
    output logic [31:0][7:0] PACKETBODY    // 28 bytes of data, 4 for ECC
);

    initial begin
        assert (!(ENCODING == "RGB" || ENCODING == "YCbCr422" || ENCODING == "YCbCr444"))
            $warning("Unsupported ENCODING setting \"%s\" - defaulting to RGB %m", ENCODING);
        assert (!(AUDIO_CLOCK_HZ inside {32000, 44100, 48000, 88200, 96000, 176400, 192000}))
            $warning("Unsupported audio rate (%d) - defaulting to 44100 %m", AUDIO_CLOCK_HZ);
        assert (!(AUDIO_CHANNELS inside {2, 8}))
            $warning("Unsupported audio channel count (%d)  - defaulting to 2 %m", AUDIO_CHANNELS);
    end 
    
    // I didn't name these, it was CEA-861-D! I promise!
    logic A;
    logic [1:0] Y;
    logic [1:0] B;
    logic [1:0] S;
    logic [1:0] C;
    logic [1:0] M;
    logic [3:0] R;
    logic ITC;
    logic [2:0] EC;
    logic [1:0] Q;
    logic [1:0] SC;
    logic [6:0] VIC;
    logic [1:0] YQ;
    logic [1:0] CN;
    logic [3:0] PR;
    
    logic [3:0] PPP;
    logic [3:0] CD;
    logic [19:0] N;
    logic [19:0] CTS_ideal;
    logic [19:0] audioClockCounter;
    logic [19:0] audioClockTimestamp;
    logic [19:0] CTS;
    
    logic [4:0][7:0] ECC;
    logic [27:0][7:0] BODY;
    
    function automatic logic [7:0] CalculateECC (input logic [7:0] byteIn, input logic [7:0] currentECC);
        for (int i = 0; i < 8; i++) begin
            if ((currentECC ^ byteIn[i]) >> 1 == 1) begin
                CalculateECC = currentECC ^ 8'b10000011;
            end else begin
                CalculateECC = currentECC;
            end  
        end      
    endfunction
     
    /*
     * There are seperate values for when the TMDS clock is >=297MHz. 
     * However the Zynq-7020 can only dream of running faster than that.
     * So I decided to simplify this case and not account for that.
     */
       
    generate
        assign A = 0; // Keeping this 0 for now. Don't really understand active format
        assign B = 2'b11; // Vert and Horizontal bar data valid (I plan to send data on both)
        assign S = 2'b00; // No compression
        assign C = 2'b00; // Setting to 0 because I don't understand it
        assign M = VIDEO_CODE inside {1, 2} ? 2'b01 : 2'b10;
        assign R = 4'b1000; // Sets to same as picture (M), I also based all other logic assuming this is true
        assign ITC = 1'b0;
        assign EC = 3'b000; // Setting to 0 because I don't understand it
        assign Q  = 2'b00;  // Set to "depends on video format"
        assign SC = 2'b00;  // No scaling done
        assign PR = 4'b0000; // No repetion
        assign VIC = VIDEO_CODE;
        assign YQ = 2'b00;  // Set to limited range
        assign CN = 2'b10;  // Set to 'cinema'
        
        if (ENCODING == "RGB") begin
            assign Y = 2'b00;
        end else if (ENCODING == "YCbCr422") begin
            assign Y = 2'b01;
        end else if (ENCODING == "YCbCr444") begin
            assign Y = 2'b10;
        end else begin
            assign Y = 2'b00;
        end
        
        case (COLOR_DEPTH)
        24:      assign PPP = 4'b0000;
        default: assign PPP = 4'b0000;
        endcase
        
        case (COLOR_DEPTH)
        24:      assign CD = 4'b0100;
        default: assign CD = 4'b0000;
        endcase
        
        case (COLOR_DEPTH)
        24:      assign PP = 4'b0000;
        default: assign PP = 4'b0000;
        endcase
             
        case (AUDIO_CLOCK_HZ)
        32000:  assign N = 4096;
        44100:  assign N = 6272;
        88200:  assign N = 12544;
        176400: assign N = 25088;
        48000:  assign N = 6144;
        96000:  assign N = 12288;
        192000: assign N = 24576;
        endcase
        
        assign CTS_ideal = (int'(VIDEO_CLOCK_MHZ * 10**6) * N) / (128 * AUDIO_CLOCK_HZ);
    endgenerate   

    // Create ECC blocks at the 4th header byte, and then at packet byte 7, 15, 23, 3
    assign ECC[0] = CalculateECC(HEADER[2], CalculateECC(HEADER[1], CalculateECC(HEADER[0], 8'h00)));
    generate
        for (genvar i = 0; i < 4; i++) begin    
            assign ECC[i + 1] = CalculateECC(BODY[6 + (7 * i)], CalculateECC(BODY[5 + (7 * i)], CalculateECC(BODY[4 + (7 * i)],
                                       CalculateECC(BODY[3 + (7 * i)], CalculateECC(BODY[2 + (7 * i)], CalculateECC(BODY[1 + (7 * i)],
                                       CalculateECC(BODY[0 + (7 * i)], 8'h00)))))));
        end
    endgenerate    
    
    assign HEADER[3]         = ECC[0];
    assign PACKETBODY[7]     = ECC[1];
    assign PACKETBODY[15]    = ECC[2];
    assign PACKETBODY[23]    = ECC[3];
    assign PACKETBODY[31]    = ECC[4];
    assign PACKETBODY[6:0]   = BODY[6:0];
    assign PACKETBODY[14:8]  = BODY[13:7];
    assign PACKETBODY[22:16] = BODY[20:14];
    assign PACKETBODY[30:24] = BODY[27:21];                         
    
    always_comb begin
        if (RST) begin
            HEADER[2:0] = 'b0;
            BODY = 'b0;
        end else begin
            HEADER[0] = PACKETTYPE;
            HEADER[2:1] = 'bX;
            BODY = 'bX;
            case (PACKETTYPE)
            8'h00:  // Null packet
            begin
                HEADER[2:1] = 16'h0000;
                BODY   = 'b0;
            end
            8'h01:      // Audio Clock Regen
            begin
                HEADER[2:1] = 16'h0000;
                for (int i = 0; i < 4; i++) begin
                    BODY[0 + (7 * i)] = 8'h00; 
                    BODY[1 + (7 * i)] = {4'h0, CTS[19:16]};
                    BODY[2 + (7 * i)] = CTS[15:8];
                    BODY[3 + (7 * i)] = CTS[7:0];
                    BODY[4 + (7 * i)] = {4'h0, N[19:16]};
                    BODY[5 + (7 * i)] = N[15:8];
                    BODY[6 + (7 * i)] = N[7:0];
                end             
            end
            
            8'h02:      // Audio Sample
            begin
                HEADER[2:1] = 16'h0000;
            end
            8'h03:      // General control
            begin
                HEADER[2:1] = 16'h0000;
                for (int i = 0; i < 4; i++) begin
                    BODY[0 + (7 * i)] = {3'b000, CLEAR_AVMUTE, 3'b000, SET_AVMUTE};
                    BODY[1 + (7 * i)] = {PPP, CD};
                    BODY[2 + (7 * i)] = {7'b0000000, DEFAULT_PHASE};
                    BODY[3 + (7 * i)] = 8'h00;
                    BODY[4 + (7 * i)] = 8'h00;
                    BODY[5 + (7 * i)] = 8'h00;
                    BODY[6 + (7 * i)] = 8'h00;
                end    
            end
            8'h07:      // One bit audio
            begin
            end
            8'h08:      // DST Audio
            begin
            end                 
            8'h09:      // High bitrate audio
            begin
            end
            8'h81:      // Vendor InfoFrame
            begin
                HEADER[1] = 8'h02;
                HEADER[2] = 8'h05;            
            end
            8'h82:      // AVI InfoFrame
            begin
                HEADER[1] = 8'h02;
                HEADER[2] = 8'h0D;
                
                BODY[1] = {1'b0, Y, A, B, S};
                BODY[2] = {C, M, R};
                BODY[3] = {ITC, EC, Q, SC};
                BODY[4] = {1'b0, VIC};
                BODY[5] = {YQ, CN, PR};
                BODY[6] = 8'h00;
                BODY[7] = 8'h00;
                BODY[8] = 8'hFF;
                BODY[9] = 8'hFF;
                BODY[10] = 8'h00;
                BODY[11] = 8'h00;
                BODY[12] = 8'hFF;
                BODY[13] = 8'hFF;   
                BODY[27:14] = 'b0;
                
                
                
                // Checksum - add all bytes (no ECC bytes), take two's complement   
                // I put this at the end so the simulation works. On hardware this is just a huge adder, and it actually does
                // work regardless of where it is in the case. But only works at the bottom in simulation
                BODY[0][7:0] = ~(HEADER[2] + HEADER[1] + HEADER[0]
                          + BODY[1] + BODY[2] + BODY[3] + BODY[4]
                          + BODY[5] + BODY[6] + BODY[7] + BODY[8]
                          + BODY[9] + BODY[10] + BODY[11] + BODY[12] + BODY[13]);          
            end    
            8'h83:      // Product description infoframe
            begin
                HEADER[1] = 8'h02;
                HEADER[2] = 8'h0D;
                
                BODY[1] = VENDOR_NAME[0];
                BODY[2] = VENDOR_NAME[1];
                BODY[3] = VENDOR_NAME[2];
                BODY[4] = VENDOR_NAME[3];
                BODY[5] = VENDOR_NAME[4];
                BODY[6] = VENDOR_NAME[5];
                BODY[7] = VENDOR_NAME[6];
                BODY[8] = VENDOR_NAME[7];
                
                BODY[9]  = PRODUCT_INFO[0];
                BODY[10] = PRODUCT_INFO[1];
                BODY[11] = PRODUCT_INFO[2];
                BODY[12] = PRODUCT_INFO[3];
                BODY[13] = PRODUCT_INFO[4];
                BODY[14] = PRODUCT_INFO[5];
                BODY[15] = PRODUCT_INFO[6];
                BODY[16] = PRODUCT_INFO[7];
                BODY[17] = PRODUCT_INFO[8];
                BODY[18] = PRODUCT_INFO[9];
                BODY[19] = PRODUCT_INFO[10];
                BODY[20] = PRODUCT_INFO[11];
                BODY[21] = PRODUCT_INFO[12];
                BODY[22] = PRODUCT_INFO[13];
                BODY[23] = PRODUCT_INFO[14];
                BODY[24] = PRODUCT_INFO[15];
                
                BODY[25] = DEVICE_INFO[0];
                BODY[26] = 8'h00;
                BODY[27] = 8'h00;
                
                BODY[0][7:0] = ~(HEADER[2] + HEADER[1] + HEADER[0]
                          + BODY[1] + BODY[2] + BODY[3] + BODY[4]
                          + BODY[5] + BODY[6] + BODY[7] + BODY[8]
                          + BODY[9] + BODY[10] + BODY[11] + BODY[12] 
                          + BODY[13] + BODY[14] + BODY[15] + BODY[16]
                          + BODY[17] + BODY[18] + BODY[19] + BODY[20]
                          + BODY[21] + BODY[22] + BODY[23] + BODY[24]
                          + BODY[25]);         
            end
            8'h84:      // Audio infoframe
            begin
            end
            default:    // Null
            begin   
                HEADER[2:1] = 'b0;
                BODY   = 'b0;
            end
            endcase
        end   
    end 
      
    // Generate CTS values (audio clock time stamp)
    always_ff@(posedge CLKAUDIO) begin
        if (RST) begin
            audioClockCounter <= 0;
            audioClockTimestamp <= 0;
        end else begin
           
        end        
    end    
endmodule
