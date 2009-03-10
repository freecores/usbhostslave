
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sendpacketarbiter
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
`include "usbConstants_h.v"

module sendPacketArbiter (clk, HC_PID, HC_SP_WEn, HCTxGnt, HCTxReq, rst, sendPacketPID, sendPacketWEnable, SOF_SP_WEn, SOFTxGnt, SOFTxReq);
input   clk;
input   [3:0]HC_PID;
input   HC_SP_WEn;
input   HCTxReq;
input   rst;
input   SOF_SP_WEn;
input   SOFTxReq;
output  HCTxGnt;
output  [3:0]sendPacketPID;
output  sendPacketWEnable;
output  SOFTxGnt;

wire    clk;
wire    [3:0]HC_PID;
wire    HC_SP_WEn;
reg     HCTxGnt, next_HCTxGnt;
wire    HCTxReq;
wire    rst;
reg     [3:0]sendPacketPID, next_sendPacketPID;
reg     sendPacketWEnable, next_sendPacketWEnable;
wire    SOF_SP_WEn;
reg     SOFTxGnt, next_SOFTxGnt;
wire    SOFTxReq;

// diagram signals declarations
reg muxSOFNotHC, next_muxSOFNotHC;

// BINARY ENCODED state machine: sendPktArb
// State codes definitions:
`define HC_ACT 2'b00
`define SOF_ACT 2'b01
`define SARB_WAIT_REQ 2'b10
`define START_SARB 2'b11

reg [1:0]CurrState_sendPktArb, NextState_sendPktArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// hostController/SOFTransmit mux
always @(muxSOFNotHC or SOF_SP_WEn or HC_SP_WEn or HC_PID)
begin
if (muxSOFNotHC  == 1'b1)
begin
sendPacketWEnable <= SOF_SP_WEn;
sendPacketPID <= `SOF;
end
else
begin
sendPacketWEnable <= HC_SP_WEn;
sendPacketPID <= HC_PID;
end
end


// Machine: sendPktArb

// NextState logic (combinatorial)
always @ (HCTxReq or SOFTxReq or HCTxGnt or SOFTxGnt or muxSOFNotHC or CurrState_sendPktArb)
begin
  NextState_sendPktArb <= CurrState_sendPktArb;
  // Set default values for outputs and signals
  next_HCTxGnt <= HCTxGnt;
  next_SOFTxGnt <= SOFTxGnt;
  next_muxSOFNotHC <= muxSOFNotHC;
  case (CurrState_sendPktArb)  // synopsys parallel_case full_case
    `HC_ACT:
    begin
      if (HCTxReq == 1'b0)
      begin
        NextState_sendPktArb <= `SARB_WAIT_REQ;
        next_HCTxGnt <= 1'b0;
      end
    end
    `SOF_ACT:
    begin
      if (SOFTxReq == 1'b0)
      begin
        NextState_sendPktArb <= `SARB_WAIT_REQ;
        next_SOFTxGnt <= 1'b0;
      end
    end
    `SARB_WAIT_REQ:
    begin
      if (SOFTxReq == 1'b1)
      begin
        NextState_sendPktArb <= `SOF_ACT;
        next_SOFTxGnt <= 1'b1;
        next_muxSOFNotHC <= 1'b1;
      end
      else if (HCTxReq == 1'b1)
      begin
        NextState_sendPktArb <= `HC_ACT;
        next_HCTxGnt <= 1'b1;
        next_muxSOFNotHC <= 1'b0;
      end
    end
    `START_SARB:
    begin
      NextState_sendPktArb <= `SARB_WAIT_REQ;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_sendPktArb <= `START_SARB;
  else
    CurrState_sendPktArb <= NextState_sendPktArb;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    HCTxGnt <= 1'b0;
    SOFTxGnt <= 1'b0;
    muxSOFNotHC <= 1'b0;
  end
  else 
  begin
    HCTxGnt <= next_HCTxGnt;
    SOFTxGnt <= next_SOFTxGnt;
    muxSOFNotHC <= next_muxSOFNotHC;
  end
end

endmodule