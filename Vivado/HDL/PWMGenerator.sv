//    SSSSSSSSSSSSSSS  TTTTTTTTTTTTTTTTTTTTTTT      000000000      PPPPPPPPPPPPPPPP
//  SS:::::::::::::::S T:::::::::::::::::::::T    00:::::::::00    P:::::::::::::::P
// S:::::SSSSSS::::::S T:::::::::::::::::::::T  00:::::::::::::00  P::::::PPPPPP:::::P
// S:::::     SSSSSSSS T:::::TT:::::::TT:::::T 0:::::::000:::::::0 PP:::::P     P:::::P
// S:::::S             TTTTTT  T:::::T  TTTTTT 0::::::0   0::::::0   P::::P     P:::::P
// S:::::S                     T:::::T         0:::::0     0:::::0   P::::P     P:::::P
//  S::: :SSSS                 T:::::T         0:::::0     0:::::0   P:::::PPPPPP:::::P
//   SS: :::::SSSSS            T:::::T         0:::::0     0:::::0   P:::::::::::::PP
//    SSS: :::::::SS           T:::::T         0:::::0     0:::::0   P::::PPPPPPPPP
//       SSSSSS::::S           T:::::T         0:::::0     0:::::0   P::::P
//             S:::::S         T:::::T         0:::::0     0:::::0   P::::P
//             S:::::S         T:::::T         0::::::0    0::::::0  P::::P
// SSSSSSS     S:::::S       TT:::::::TT       0:::::::000:::::::0  PP:::::PP
// S::::::SSSSSS:::::S       T:::::::::T        00:::::::::::::00   P:::::::P
// S:::::::::::::::SS        T:::::::::T          00:::::::::00     P:::::::P
//  SSSSSSSSSSSSSSS          TTTTTTTTTTT            000000000       PPPPPPPPP

// This module is fully verified and functioning. 
// If you are not Jack Edgely, there is no reason for you to be modifying this file. 
//
// If you are from a future senior design team trying to hunt down a bug, I can assure you,
// modifying this file will not solve your issue. 

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wentworth Institute of Technology
// Engineer: Jack Edgely
// 
// Create Date: 01/12/2025 12:06:08 PM
// Design Name: 
// Module Name: PWMGenerator
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
module PWMGenerator#(parameter RESOLUTION = 8)
(
    input clk,          // Take a guess
    input rst_n,        // Take another guess
    input [RESOLUTION-1:0] duty,
    output signal_p,
    output signal_n
);

    logic counterexceeded;
    logic[RESOLUTION-1:0] counter;
   
    assign counterexceeded = duty >= counter;
    assign signal_p = ~rst_n ?  counterexceeded : 1'bZ;
    assign signal_n = ~rst_n ? ~counterexceeded : 1'bZ;
    
    always_ff@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
