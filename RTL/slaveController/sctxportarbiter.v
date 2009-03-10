
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SCTxPortArbiter
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

module SCTxPortArbiter (clk, directCntlCntl, directCntlData, directCntlGnt, directCntlReq, directCntlWEn, rst, SCTxPortCntl, SCTxPortData, SCTxPortRdyIn, SCTxPortRdyOut, SCTxPortWEnable, sendPacketCntl, sendPacketData, sendPacketGnt, sendPacketReq, sendPacketWEn);
input   clk;
input   [7:0]directCntlCntl;
input   [7:0]directCntlData;
input   directCntlReq;
input   directCntlWEn;
input   rst;
input   SCTxPortRdyIn;
input   [7:0]sendPacketCntl;
input   [7:0]sendPacketData;
input   sendPacketReq;
input   sendPacketWEn;
output  directCntlGnt;
output  [7:0]SCTxPortCntl;
output  [7:0]SCTxPortData;
output  SCTxPortRdyOut;
output  SCTxPortWEnable;
output  sendPacketGnt;

wire    clk;
wire    [7:0]directCntlCntl;
wire    [7:0]directCntlData;
reg     directCntlGnt, next_directCntlGnt;
wire    directCntlReq;
wire    directCntlWEn;
wire    rst;
reg     [7:0]SCTxPortCntl, next_SCTxPortCntl;
reg     [7:0]SCTxPortData, next_SCTxPortData;
wire    SCTxPortRdyIn;
reg     SCTxPortRdyOut, next_SCTxPortRdyOut;
reg     SCTxPortWEnable, next_SCTxPortWEnable;
wire    [7:0]sendPacketCntl;
wire    [7:0]sendPacketData;
reg     sendPacketGnt, next_sendPacketGnt;
wire    sendPacketReq;
wire    sendPacketWEn;

// diagram signals declarations
reg muxDCEn, next_muxDCEn;

// BINARY ENCODED state machine: SCTxArb
// State codes definitions:
`define SARB1_WAIT_REQ 2'b00
`define SARB_SEND_PACKET 2'b01
`define SARB_DC 2'b10
`define START_SARB 2'b11

reg [1:0]CurrState_SCTxArb, NextState_SCTxArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// SOFController/directContol/sendPacket mux
always @(SCTxPortRdyIn)
begin
SCTxPortRdyOut <= SCTxPortRdyIn;
end
always @(muxDCEn or
directCntlWEn or directCntlData or directCntlCntl or
directCntlWEn or directCntlData or directCntlCntl or
sendPacketWEn or sendPacketData or sendPacketCntl)
begin
if (muxDCEn == 1'b1)
begin
SCTxPortWEnable <= directCntlWEn;
SCTxPortData <= directCntlData;
SCTxPortCntl <= directCntlCntl;
end
else
begin
SCTxPortWEnable <= sendPacketWEn;
SCTxPortData <= sendPacketData;
SCTxPortCntl <= sendPacketCntl;
end
end


// Machine: SCTxArb

// NextState logic (combinatorial)
always @ (sendPacketReq or directCntlReq or sendPacketGnt or muxDCEn or directCntlGnt or CurrState_SCTxArb)
begin
  NextState_SCTxArb <= CurrState_SCTxArb;
  // Set default values for outputs and signals
  next_sendPacketGnt <= sendPacketGnt;
  next_muxDCEn <= muxDCEn;
  next_directCntlGnt <= directCntlGnt;
  case (CurrState_SCTxArb)  // synopsys parallel_case full_case
    `SARB1_WAIT_REQ:
    begin
      if (sendPacketReq == 1'b1)
      begin
        NextState_SCTxArb <= `SARB_SEND_PACKET;
        next_sendPacketGnt <= 1'b1;
        next_muxDCEn <= 1'b0;
      end
      else if (directCntlReq == 1'b1)
      begin
        NextState_SCTxArb <= `SARB_DC;
        next_directCntlGnt <= 1'b1;
        next_muxDCEn <= 1'b1;
      end
    end
    `SARB_SEND_PACKET:
    begin
      if (sendPacketReq == 1'b0)
      begin
        NextState_SCTxArb <= `SARB1_WAIT_REQ;
        next_sendPacketGnt <= 1'b0;
      end
    end
    `SARB_DC:
    begin
      if (directCntlReq == 1'b0)
      begin
        NextState_SCTxArb <= `SARB1_WAIT_REQ;
        next_directCntlGnt <= 1'b0;
      end
    end
    `START_SARB:
    begin
      NextState_SCTxArb <= `SARB1_WAIT_REQ;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_SCTxArb <= `START_SARB;
  else
    CurrState_SCTxArb <= NextState_SCTxArb;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    sendPacketGnt <= 1'b0;
    directCntlGnt <= 1'b0;
    muxDCEn <= 1'b0;
  end
  else 
  begin
    sendPacketGnt <= next_sendPacketGnt;
    directCntlGnt <= next_directCntlGnt;
    muxDCEn <= next_muxDCEn;
  end
end

endmodule