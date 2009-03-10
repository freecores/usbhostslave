
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// processTxByte
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
// $Id: processTxByte.v,v 1.3 2004-12-31 14:40:43 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"

module processTxByte (clk, JBit, KBit, processTxByteRdy, processTxByteWEn, rst, TxByteCtrlIn, TxByteIn, USBWireCtrl, USBWireData, USBWireGnt, USBWireRdy, USBWireReq, USBWireWEn);
input   clk;
input   [1:0]JBit;
input   [1:0]KBit;
input   processTxByteWEn;
input   rst;
input   [7:0]TxByteCtrlIn;
input   [7:0]TxByteIn;
input   USBWireGnt;
input   USBWireRdy;
output  processTxByteRdy;
output  USBWireCtrl;
output  [1:0]USBWireData;
output  USBWireReq;
output  USBWireWEn;

wire    clk;
wire    [1:0]JBit;
wire    [1:0]KBit;
reg     processTxByteRdy, next_processTxByteRdy;
wire    processTxByteWEn;
wire    rst;
wire    [7:0]TxByteCtrlIn;
wire    [7:0]TxByteIn;
reg     USBWireCtrl, next_USBWireCtrl;
reg     [1:0]USBWireData, next_USBWireData;
wire    USBWireGnt;
wire    USBWireRdy;
reg     USBWireReq, next_USBWireReq;
reg     USBWireWEn, next_USBWireWEn;

// diagram signals declarations
reg  [3:0]i, next_i;
reg  [7:0]TxByte, next_TxByte;
reg  [7:0]TxByteCtrl, next_TxByteCtrl;
reg  [1:0]TXLineState, next_TXLineState;
reg  [3:0]TXOneCount, next_TXOneCount;

// BINARY ENCODED state machine: prcTxB
// State codes definitions:
`define START_PTBY 4'b0000
`define PTBY_WAIT_EN 4'b0001
`define SEND_BYTE_UPDATE_BYTE 4'b0010
`define SEND_BYTE_WAIT_RDY 4'b0011
`define SEND_BYTE_CHK 4'b0100
`define SEND_BYTE_BIT_STUFF 4'b0101
`define SEND_BYTE_WAIT_RDY2 4'b0110
`define SEND_BYTE_CHK_FIN 4'b0111
`define PTBY_WAIT_GNT 4'b1000
`define STOP_SND_SE0_2 4'b1001
`define STOP_SND_SE0_1 4'b1010
`define STOP_CHK 4'b1011
`define STOP_SND_J 4'b1100
`define STOP_SND_IDLE 4'b1101
`define STOP_FIN 4'b1110

reg [3:0]CurrState_prcTxB, NextState_prcTxB;


// Machine: prcTxB

// NextState logic (combinatorial)
always @ (processTxByteWEn or TxByteIn or TxByteCtrlIn or i or TxByte or TXOneCount or KBit or JBit or USBWireRdy or TXLineState or USBWireGnt or TxByteCtrl or processTxByteRdy or USBWireData or USBWireCtrl or USBWireReq or USBWireWEn or CurrState_prcTxB)
begin
  NextState_prcTxB <= CurrState_prcTxB;
  // Set default values for outputs and signals
  next_processTxByteRdy <= processTxByteRdy;
  next_USBWireData <= USBWireData;
  next_USBWireCtrl <= USBWireCtrl;
  next_USBWireReq <= USBWireReq;
  next_USBWireWEn <= USBWireWEn;
  next_i <= i;
  next_TxByte <= TxByte;
  next_TxByteCtrl <= TxByteCtrl;
  next_TXLineState <= TXLineState;
  next_TXOneCount <= TXOneCount;
  case (CurrState_prcTxB)  // synopsys parallel_case full_case
    `START_PTBY:
    begin
      next_processTxByteRdy <= 1'b0;
      next_USBWireData <= 2'b00;
      next_USBWireCtrl <= `TRI_STATE;
      next_USBWireReq <= 1'b0;
      next_USBWireWEn <= 1'b0;
      next_i <= 4'h0;
      next_TxByte <= 8'h00;
      next_TxByteCtrl <= 8'h00;
      next_TXLineState <= 2'b0;
      next_TXOneCount <= 4'h0;
      NextState_prcTxB <= `PTBY_WAIT_EN;
    end
    `PTBY_WAIT_EN:
    begin
      next_processTxByteRdy <= 1'b1;
      if ((processTxByteWEn == 1'b1) && (TxByteCtrlIn == `DATA_START))
      begin
        NextState_prcTxB <= `PTBY_WAIT_GNT;
        next_processTxByteRdy <= 1'b0;
        next_TxByte <= TxByteIn;
        next_TxByteCtrl <= TxByteCtrlIn;
        next_TXOneCount <= 1;
        next_TXLineState <= JBit;
        next_USBWireReq <= 1'b1;
      end
      else if (processTxByteWEn == 1'b1)
      begin
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
        next_processTxByteRdy <= 1'b0;
        next_TxByte <= TxByteIn;
        next_TxByteCtrl <= TxByteCtrlIn;
        next_i <= 4'h0;
      end
    end
    `PTBY_WAIT_GNT:
    begin
      if (USBWireGnt == 1'b1)
      begin
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
        next_i <= 4'h0;
      end
    end
    `SEND_BYTE_UPDATE_BYTE:
    begin
      next_i <= i + 1'b1;
      next_TxByte <= {1'b0, TxByte[7:1] };
      if (TxByte[0] == 1'b1)                      //If this bit is 1, then
      next_TXOneCount <= TXOneCount + 1'b1;
      //increment 'TXOneCount'
      else                                        //else this is a zero bit
      begin
      next_TXOneCount <= 4'h1;
      //reset 'TXOneCount'
      if (TXLineState == JBit)
      next_TXLineState <= KBit;
      //toggle the line state
      else
      next_TXLineState <= JBit;
      end
      NextState_prcTxB <= `SEND_BYTE_WAIT_RDY;
    end
    `SEND_BYTE_WAIT_RDY:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `SEND_BYTE_CHK;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= TXLineState;
        next_USBWireCtrl <= `DRIVE;
      end
    end
    `SEND_BYTE_CHK:
    begin
      next_USBWireWEn <= 1'b0;
      if (TXOneCount == 4'h6)
      begin
        NextState_prcTxB <= `SEND_BYTE_BIT_STUFF;
      end
      else if (i != 4'h8)
      begin
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
      end
      else
      begin
        NextState_prcTxB <= `STOP_CHK;
      end
    end
    `SEND_BYTE_BIT_STUFF:
    begin
      next_TXOneCount <= 4'h1;
      //reset 'TXOneCount'
      if (TXLineState == JBit)
      next_TXLineState <= KBit;
      //toggle the line state
      else
      next_TXLineState <= JBit;
      NextState_prcTxB <= `SEND_BYTE_WAIT_RDY2;
    end
    `SEND_BYTE_WAIT_RDY2:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `SEND_BYTE_CHK_FIN;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= TXLineState;
        next_USBWireCtrl <= `DRIVE;
      end
    end
    `SEND_BYTE_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      if (i == 4'h8)
      begin
        NextState_prcTxB <= `STOP_CHK;
      end
      else
      begin
        NextState_prcTxB <= `SEND_BYTE_UPDATE_BYTE;
      end
    end
    `STOP_SND_SE0_2:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `STOP_SND_J;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
      end
    end
    `STOP_SND_SE0_1:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `STOP_SND_SE0_2;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
      end
    end
    `STOP_CHK:
    begin
      if (TxByteCtrl == `DATA_STOP)
      begin
        NextState_prcTxB <= `STOP_SND_SE0_1;
      end
      else
      begin
        NextState_prcTxB <= `PTBY_WAIT_EN;
      end
    end
    `STOP_SND_J:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `STOP_SND_IDLE;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
      end
    end
    `STOP_SND_IDLE:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_prcTxB <= `STOP_FIN;
        next_USBWireWEn <= 1'b1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
      end
    end
    `STOP_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      //release the wire
      NextState_prcTxB <= `PTBY_WAIT_EN;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_prcTxB <= `START_PTBY;
  else
    CurrState_prcTxB <= NextState_prcTxB;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    processTxByteRdy <= 1'b0;
    USBWireData <= 2'b00;
    USBWireCtrl <= `TRI_STATE;
    USBWireReq <= 1'b0;
    USBWireWEn <= 1'b0;
    i <= 4'h0;
    TxByte <= 8'h00;
    TxByteCtrl <= 8'h00;
    TXLineState <= 2'b0;
    TXOneCount <= 4'h0;
  end
  else 
  begin
    processTxByteRdy <= next_processTxByteRdy;
    USBWireData <= next_USBWireData;
    USBWireCtrl <= next_USBWireCtrl;
    USBWireReq <= next_USBWireReq;
    USBWireWEn <= next_USBWireWEn;
    i <= next_i;
    TxByte <= next_TxByte;
    TxByteCtrl <= next_TxByteCtrl;
    TXLineState <= next_TXLineState;
    TXOneCount <= next_TXOneCount;
  end
end

endmodule