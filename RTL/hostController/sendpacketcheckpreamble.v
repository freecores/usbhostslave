
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sendpacketcheckpreamble
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
// $Id: sendpacketcheckpreamble.v,v 1.3 2004-12-31 14:40:41 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbConstants_h.v"

module sendPacketCheckPreamble (clk, fullSpeedBitRate, fullSpeedPolarity, grabLineControl, preAmbleEnable, rst, sendPacketCPPID, sendPacketCPReady, sendPacketCPWEn, sendPacketPID, sendPacketRdy, sendPacketWEn);
input   clk;
input   preAmbleEnable;
input   rst;
input   [3:0]sendPacketCPPID;
input   sendPacketCPWEn;
input   sendPacketRdy;
output  fullSpeedBitRate;
output  fullSpeedPolarity;
output  grabLineControl;    // mux select
output  sendPacketCPReady;
output  [3:0]sendPacketPID;
output  sendPacketWEn;

wire    clk;
reg     fullSpeedBitRate, next_fullSpeedBitRate;
reg     fullSpeedPolarity, next_fullSpeedPolarity;
reg     grabLineControl, next_grabLineControl;
wire    preAmbleEnable;
wire    rst;
wire    [3:0]sendPacketCPPID;
reg     sendPacketCPReady, next_sendPacketCPReady;
wire    sendPacketCPWEn;
reg     [3:0]sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;

// BINARY ENCODED state machine: sendPktCP
// State codes definitions:
`define SPC_WAIT_EN 4'b0000
`define START_SPC 4'b0001
`define CHK_PREAM 4'b0010
`define PREAM_PKT_SND_PREAM 4'b0011
`define PREAM_PKT_WAIT_RDY1 4'b0100
`define PREAM_PKT_WAIT_RDY2 4'b0101
`define PREAM_PKT_SND_PID 4'b0110
`define PREAM_PKT_WAIT_RDY3 4'b0111
`define REG_PKT_SEND_PID 4'b1000
`define REG_PKT_WAIT_RDY1 4'b1001
`define REG_PKT_WAIT_RDY 4'b1010
`define READY 4'b1011

reg [3:0]CurrState_sendPktCP, NextState_sendPktCP;


// Machine: sendPktCP

// NextState logic (combinatorial)
always @ (sendPacketCPWEn or preAmbleEnable or sendPacketRdy or sendPacketCPPID or sendPacketCPReady or sendPacketWEn or sendPacketPID or fullSpeedBitRate or fullSpeedPolarity or grabLineControl or CurrState_sendPktCP)
begin
  NextState_sendPktCP <= CurrState_sendPktCP;
  // Set default values for outputs and signals
  next_sendPacketCPReady <= sendPacketCPReady;
  next_sendPacketWEn <= sendPacketWEn;
  next_sendPacketPID <= sendPacketPID;
  next_fullSpeedBitRate <= fullSpeedBitRate;
  next_fullSpeedPolarity <= fullSpeedPolarity;
  next_grabLineControl <= grabLineControl;
  case (CurrState_sendPktCP)  // synopsys parallel_case full_case
    `SPC_WAIT_EN:
    begin
      if (sendPacketCPWEn == 1'b1)
      begin
        NextState_sendPktCP <= `CHK_PREAM;
        next_sendPacketCPReady <= 1'b0;
      end
    end
    `START_SPC:
    begin
      NextState_sendPktCP <= `SPC_WAIT_EN;
    end
    `CHK_PREAM:
    begin
      if (preAmbleEnable == 1'b1)
      begin
        NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY1;
      end
      else
      begin
        NextState_sendPktCP <= `REG_PKT_WAIT_RDY1;
      end
    end
    `READY:
    begin
      next_sendPacketCPReady <= 1'b1;
      NextState_sendPktCP <= `SPC_WAIT_EN;
    end
    `PREAM_PKT_SND_PREAM:
    begin
      next_sendPacketWEn <= 1'b1;
      next_sendPacketPID <= `PREAMBLE;
      NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY2;
      next_sendPacketWEn <= 1'b0;
    end
    `PREAM_PKT_WAIT_RDY1:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_sendPktCP <= `PREAM_PKT_SND_PREAM;
        next_fullSpeedBitRate <= 1'b1;
        next_fullSpeedPolarity <= 1'b1;
        next_grabLineControl <= 1'b1;
      end
    end
    `PREAM_PKT_WAIT_RDY2:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_sendPktCP <= `PREAM_PKT_SND_PID;
        next_fullSpeedBitRate <= 1'b1;
      end
    end
    `PREAM_PKT_SND_PID:
    begin
      next_sendPacketWEn <= 1'b1;
      next_sendPacketPID <= sendPacketCPPID;
      NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY3;
      next_sendPacketWEn <= 1'b0;
    end
    `PREAM_PKT_WAIT_RDY3:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_sendPktCP <= `READY;
        next_grabLineControl <= 1'b0;
      end
    end
    `REG_PKT_SEND_PID:
    begin
      next_sendPacketWEn <= 1'b1;
      next_sendPacketPID <= sendPacketCPPID;
      NextState_sendPktCP <= `REG_PKT_WAIT_RDY;
    end
    `REG_PKT_WAIT_RDY1:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_sendPktCP <= `REG_PKT_SEND_PID;
      end
    end
    `REG_PKT_WAIT_RDY:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_sendPktCP <= `READY;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_sendPktCP <= `START_SPC;
  else
    CurrState_sendPktCP <= NextState_sendPktCP;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    sendPacketCPReady <= 1'b1;
    sendPacketWEn <= 1'b0;
    sendPacketPID <= 4'b0;
    fullSpeedBitRate <= 1'b0;
    fullSpeedPolarity <= 1'b0;
    grabLineControl <= 1'b0;
  end
  else 
  begin
    sendPacketCPReady <= next_sendPacketCPReady;
    sendPacketWEn <= next_sendPacketWEn;
    sendPacketPID <= next_sendPacketPID;
    fullSpeedBitRate <= next_fullSpeedBitRate;
    fullSpeedPolarity <= next_fullSpeedPolarity;
    grabLineControl <= next_grabLineControl;
  end
end

endmodule