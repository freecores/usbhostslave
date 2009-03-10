
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbTxWireArbiter
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
// $Id: usbTxWireArbiter.v,v 1.3 2004-12-31 14:40:43 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbConstants_h.v"
`include "usbSerialInterfaceEngine_h.v"



module USBTxWireArbiter (clk, prcTxByteCtrl, prcTxByteData, prcTxByteGnt, prcTxByteReq, prcTxByteWEn, rst, SIETxCtrl, SIETxData, SIETxGnt, SIETxReq, SIETxWEn, TxBits, TxCtl, USBWireRdyIn, USBWireRdyOut, USBWireWEn);
input   clk;
input   prcTxByteCtrl;
input   [1:0]prcTxByteData;
input   prcTxByteReq;
input   prcTxByteWEn;
input   rst;
input   SIETxCtrl;
input   [1:0]SIETxData;
input   SIETxReq;
input   SIETxWEn;
input   USBWireRdyIn;
output  prcTxByteGnt;
output  SIETxGnt;
output  [1:0]TxBits;
output  TxCtl;
output  USBWireRdyOut;
output  USBWireWEn;

wire    clk;
wire    prcTxByteCtrl;
wire    [1:0]prcTxByteData;
reg     prcTxByteGnt, next_prcTxByteGnt;
wire    prcTxByteReq;
wire    prcTxByteWEn;
wire    rst;
wire    SIETxCtrl;
wire    [1:0]SIETxData;
reg     SIETxGnt, next_SIETxGnt;
wire    SIETxReq;
wire    SIETxWEn;
reg     [1:0]TxBits, next_TxBits;
reg     TxCtl, next_TxCtl;
wire    USBWireRdyIn;
reg     USBWireRdyOut, next_USBWireRdyOut;
reg     USBWireWEn, next_USBWireWEn;

// diagram signals declarations
reg muxSIENotPTXB, next_muxSIENotPTXB;

// BINARY ENCODED state machine: txWireArb
// State codes definitions:
`define START_TARB 2'b00
`define TARB_WAIT_REQ 2'b01
`define PTXB_ACT 2'b10
`define SIE_TX_ACT 2'b11

reg [1:0]CurrState_txWireArb, NextState_txWireArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// processTxByte/SIETransmitter mux
always @(USBWireRdyIn)
begin
USBWireRdyOut <= USBWireRdyIn;
end
always @(muxSIENotPTXB or SIETxWEn or SIETxData or
SIETxCtrl or prcTxByteWEn or prcTxByteData or prcTxByteCtrl)
begin
if (muxSIENotPTXB  == 1'b1)
begin
USBWireWEn <= SIETxWEn;
TxBits <= SIETxData;
TxCtl <= SIETxCtrl;
end
else
begin
USBWireWEn <= prcTxByteWEn;
TxBits <= prcTxByteData;
TxCtl <= prcTxByteCtrl;
end
end


// Machine: txWireArb

// NextState logic (combinatorial)
always @ (prcTxByteReq or SIETxReq or prcTxByteGnt or SIETxGnt or muxSIENotPTXB or CurrState_txWireArb)
begin
  NextState_txWireArb <= CurrState_txWireArb;
  // Set default values for outputs and signals
  next_prcTxByteGnt <= prcTxByteGnt;
  next_SIETxGnt <= SIETxGnt;
  next_muxSIENotPTXB <= muxSIENotPTXB;
  case (CurrState_txWireArb)  // synopsys parallel_case full_case
    `START_TARB:
    begin
      NextState_txWireArb <= `TARB_WAIT_REQ;
    end
    `TARB_WAIT_REQ:
    begin
      if (prcTxByteReq == 1'b1)
      begin
        NextState_txWireArb <= `PTXB_ACT;
        next_prcTxByteGnt <= 1'b1;
        next_muxSIENotPTXB <= 1'b0;
      end
      else if (SIETxReq == 1'b1)
      begin
        NextState_txWireArb <= `SIE_TX_ACT;
        next_SIETxGnt <= 1'b1;
        next_muxSIENotPTXB <= 1'b1;
      end
    end
    `PTXB_ACT:
    begin
      if (prcTxByteReq == 1'b0)
      begin
        NextState_txWireArb <= `TARB_WAIT_REQ;
        next_prcTxByteGnt <= 1'b0;
      end
    end
    `SIE_TX_ACT:
    begin
      if (SIETxReq == 1'b0)
      begin
        NextState_txWireArb <= `TARB_WAIT_REQ;
        next_SIETxGnt <= 1'b0;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_txWireArb <= `START_TARB;
  else
    CurrState_txWireArb <= NextState_txWireArb;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    prcTxByteGnt <= 1'b0;
    SIETxGnt <= 1'b0;
    muxSIENotPTXB <= 1'b0;
  end
  else 
  begin
    prcTxByteGnt <= next_prcTxByteGnt;
    SIETxGnt <= next_SIETxGnt;
    muxSIENotPTXB <= next_muxSIENotPTXB;
  end
end

endmodule