
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hctxPortArbiter
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// http://www.opencores.org/cores/usbhostslave/                 ////
////                                                              ////
//// Module Description:                                          ////
//// 
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`timescale 1ns / 1ps

module HCTxPortArbiter (clk, directCntlCntl, directCntlData, directCntlGnt, directCntlReq, directCntlWEn, HCTxPortCntl, HCTxPortData, HCTxPortWEnable, rst, sendPacketCntl, sendPacketData, sendPacketGnt, sendPacketReq, sendPacketWEn, SOFCntlCntl, SOFCntlData, SOFCntlGnt, SOFCntlReq, SOFCntlWEn);
input   clk;
input   [7:0]directCntlCntl;
input   [7:0]directCntlData;
input   directCntlReq;
input   directCntlWEn;
input   rst;
input   [7:0]sendPacketCntl;
input   [7:0]sendPacketData;
input   sendPacketReq;
input   sendPacketWEn;
input   [7:0]SOFCntlCntl;
input   [7:0]SOFCntlData;
input   SOFCntlReq;
input   SOFCntlWEn;
output  directCntlGnt;
output  [7:0]HCTxPortCntl;
output  [7:0]HCTxPortData;
output  HCTxPortWEnable;
output  sendPacketGnt;
output  SOFCntlGnt;

wire    clk;
wire    [7:0]directCntlCntl;
wire    [7:0]directCntlData;
reg     directCntlGnt, next_directCntlGnt;
wire    directCntlReq;
wire    directCntlWEn;
reg     [7:0]HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0]HCTxPortData, next_HCTxPortData;
reg     HCTxPortWEnable, next_HCTxPortWEnable;
wire    rst;
wire    [7:0]sendPacketCntl;
wire    [7:0]sendPacketData;
reg     sendPacketGnt, next_sendPacketGnt;
wire    sendPacketReq;
wire    sendPacketWEn;
wire    [7:0]SOFCntlCntl;
wire    [7:0]SOFCntlData;
reg     SOFCntlGnt, next_SOFCntlGnt;
wire    SOFCntlReq;
wire    SOFCntlWEn;


// Constants
`define DIRECT_CTRL_MUX 2'b10
`define SEND_PACKET_MUX 2'b00
`define SOF_CTRL_MUX 2'b01
// diagram signals declarations
reg  [1:0]muxCntl, next_muxCntl;

// BINARY ENCODED state machine: HCTxArb
// State codes definitions:
`define START_HARB 3'b000
`define WAIT_REQ 3'b001
`define SEND_SOF 3'b010
`define SEND_PACKET 3'b011
`define DIRECT_CONTROL 3'b100

reg [2:0]CurrState_HCTxArb, NextState_HCTxArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// SOFController/directContol/sendPacket mux
always @(muxCntl or SOFCntlWEn or SOFCntlData or SOFCntlCntl or
directCntlWEn or directCntlData or directCntlCntl or
directCntlWEn or directCntlData or directCntlCntl or
sendPacketWEn or sendPacketData or sendPacketCntl)
begin
case (muxCntl)
`SOF_CTRL_MUX :
begin
HCTxPortWEnable <= SOFCntlWEn;
HCTxPortData <= SOFCntlData;
HCTxPortCntl <= SOFCntlCntl;
end
`DIRECT_CTRL_MUX :
begin
HCTxPortWEnable <= directCntlWEn;
HCTxPortData <= directCntlData;
HCTxPortCntl <= directCntlCntl;
end
`SEND_PACKET_MUX :
begin
HCTxPortWEnable <= sendPacketWEn;
HCTxPortData <= sendPacketData;
HCTxPortCntl <= sendPacketCntl;
end
default :
begin
HCTxPortWEnable <= 1'b0;
HCTxPortData <= 8'h00;
HCTxPortCntl <= 8'h00;
end
endcase
end


// Machine: HCTxArb

// NextState logic (combinatorial)
always @ (SOFCntlReq or sendPacketReq or directCntlReq or SOFCntlGnt or sendPacketGnt or directCntlGnt or muxCntl or CurrState_HCTxArb)
begin
  NextState_HCTxArb <= CurrState_HCTxArb;
  // Set default values for outputs and signals
  next_SOFCntlGnt <= SOFCntlGnt;
  next_sendPacketGnt <= sendPacketGnt;
  next_directCntlGnt <= directCntlGnt;
  next_muxCntl <= muxCntl;
  case (CurrState_HCTxArb)  // synopsys parallel_case full_case
    `START_HARB:
    begin
      NextState_HCTxArb <= `WAIT_REQ;
    end
    `WAIT_REQ:
    begin
      if (SOFCntlReq == 1'b1)
      begin
        NextState_HCTxArb <= `SEND_SOF;
        next_SOFCntlGnt <= 1'b1;
        next_muxCntl <= `SOF_CTRL_MUX;
      end
      else if (sendPacketReq == 1'b1)
      begin
        NextState_HCTxArb <= `SEND_PACKET;
        next_sendPacketGnt <= 1'b1;
        next_muxCntl <= `SEND_PACKET_MUX;
      end
      else if (directCntlReq == 1'b1)
      begin
        NextState_HCTxArb <= `DIRECT_CONTROL;
        next_directCntlGnt <= 1'b1;
        next_muxCntl <= `DIRECT_CTRL_MUX;
      end
    end
    `SEND_SOF:
    begin
      if (SOFCntlReq == 1'b0)
      begin
        NextState_HCTxArb <= `WAIT_REQ;
        next_SOFCntlGnt <= 1'b0;
      end
    end
    `SEND_PACKET:
    begin
      if (sendPacketReq == 1'b0)
      begin
        NextState_HCTxArb <= `WAIT_REQ;
        next_sendPacketGnt <= 1'b0;
      end
    end
    `DIRECT_CONTROL:
    begin
      if (directCntlReq == 1'b0)
      begin
        NextState_HCTxArb <= `WAIT_REQ;
        next_directCntlGnt <= 1'b0;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_HCTxArb <= `START_HARB;
  else
    CurrState_HCTxArb <= NextState_HCTxArb;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    SOFCntlGnt <= 1'b0;
    sendPacketGnt <= 1'b0;
    directCntlGnt <= 1'b0;
    muxCntl <= 2'b00;
  end
  else 
  begin
    SOFCntlGnt <= next_SOFCntlGnt;
    sendPacketGnt <= next_sendPacketGnt;
    directCntlGnt <= next_directCntlGnt;
    muxCntl <= next_muxCntl;
  end
end

endmodule