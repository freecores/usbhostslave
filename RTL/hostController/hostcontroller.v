
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hostController
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
// $Id: hostcontroller.v,v 1.3 2004-12-31 14:40:41 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbHostControl_h.v"
`include "usbConstants_h.v"


module hostcontroller (clearTXReq, clk, getPacketRdy, getPacketREn, rst, RXStatus, sendPacketArbiterGnt, sendPacketArbiterReq, sendPacketPID, sendPacketRdy, sendPacketWEn, transDone, transReq, transType);
input   clk;
input   getPacketRdy;
input   rst;
input   [7:0]RXStatus;
input   sendPacketArbiterGnt;
input   sendPacketRdy;
input   transReq;
input   [1:0]transType;
output  clearTXReq;
output  getPacketREn;
output  sendPacketArbiterReq;
output  [3:0]sendPacketPID;
output  sendPacketWEn;
output  transDone;

reg     clearTXReq, next_clearTXReq;
wire    clk;
wire    getPacketRdy;
reg     getPacketREn, next_getPacketREn;
wire    rst;
wire    [7:0]RXStatus;
wire    sendPacketArbiterGnt;
reg     sendPacketArbiterReq, next_sendPacketArbiterReq;
reg     [3:0]sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;
reg     transDone, next_transDone;
wire    transReq;
wire    [1:0]transType;

// BINARY ENCODED state machine: hstCntrl
// State codes definitions:
`define START_HC 5'b00000
`define TX_REQ 5'b00001
`define CHK_TYPE 5'b00010
`define FLAG 5'b00011
`define IN_WAIT_DATA_RXED 5'b00100
`define IN_CHK_FOR_ERROR 5'b00101
`define IN_CLR_SP_WEN2 5'b00110
`define SETUP_CLR_SP_WEN1 5'b00111
`define SETUP_CLR_SP_WEN2 5'b01000
`define FIN 5'b01001
`define WAIT_GNT 5'b01010
`define SETUP_WAIT_PKT_RXED 5'b01011
`define IN_WAIT_IN_SENT 5'b01100
`define OUT0_WAIT_RX_DATA 5'b01101
`define OUT0_WAIT_DATA0_SENT 5'b01110
`define OUT0_WAIT_OUT_SENT 5'b01111
`define SETUP_HC_WAIT_RDY 5'b10000
`define IN_WAIT_SP_RDY1 5'b10001
`define IN_WAIT_SP_RDY2 5'b10010
`define OUT0_WAIT_SP_RDY1 5'b10011
`define SETUP_WAIT_SETUP_SENT 5'b10100
`define SETUP_WAIT_DATA_SENT 5'b10101
`define IN_CLR_SP_WEN1 5'b10110
`define IN_WAIT_ACK_SENT 5'b10111
`define OUT0_CLR_WEN1 5'b11000
`define OUT0_CLR_WEN2 5'b11001
`define OUT1_WAIT_RX_DATA 5'b11010
`define OUT1_WAIT_OUT_SENT 5'b11011
`define OUT1_WAIT_DATA1_SENT 5'b11100
`define OUT1_WAIT_SP_RDY1 5'b11101
`define OUT1_CLR_WEN1 5'b11110
`define OUT1_CLR_WEN2 5'b11111

reg [4:0]CurrState_hstCntrl, NextState_hstCntrl;


// Machine: hstCntrl

// NextState logic (combinatorial)
always @ (transReq or transType or getPacketRdy or RXStatus or sendPacketArbiterGnt or sendPacketRdy or transDone or clearTXReq or getPacketREn or sendPacketArbiterReq or sendPacketPID or sendPacketWEn or CurrState_hstCntrl)
begin
  NextState_hstCntrl <= CurrState_hstCntrl;
  // Set default values for outputs and signals
  next_transDone <= transDone;
  next_clearTXReq <= clearTXReq;
  next_getPacketREn <= getPacketREn;
  next_sendPacketArbiterReq <= sendPacketArbiterReq;
  next_sendPacketPID <= sendPacketPID;
  next_sendPacketWEn <= sendPacketWEn;
  case (CurrState_hstCntrl)  // synopsys parallel_case full_case
    `START_HC:
    begin
      NextState_hstCntrl <= `TX_REQ;
    end
    `TX_REQ:
    begin
      if (transReq == 1'b1)
      begin
        NextState_hstCntrl <= `WAIT_GNT;
        next_sendPacketArbiterReq <= 1'b1;
      end
    end
    `CHK_TYPE:
    begin
      if (transType == `OUTDATA0_TRANS)
      begin
        NextState_hstCntrl <= `OUT0_WAIT_SP_RDY1;
      end
      else if (transType == `IN_TRANS)
      begin
        NextState_hstCntrl <= `IN_WAIT_SP_RDY1;
      end
      else if (transType == `SETUP_TRANS)
      begin
        NextState_hstCntrl <= `SETUP_HC_WAIT_RDY;
      end
      else if (transType == `OUTDATA1_TRANS)
      begin
        NextState_hstCntrl <= `OUT1_WAIT_SP_RDY1;
      end
    end
    `FLAG:
    begin
      next_transDone <= 1'b1;
      next_clearTXReq <= 1'b1;
      next_sendPacketArbiterReq <= 1'b0;
      NextState_hstCntrl <= `FIN;
    end
    `FIN:
    begin
      next_transDone <= 1'b0;
      next_clearTXReq <= 1'b0;
      NextState_hstCntrl <= `TX_REQ;
    end
    `WAIT_GNT:
    begin
      if (sendPacketArbiterGnt == 1'b1)
      begin
        NextState_hstCntrl <= `CHK_TYPE;
      end
    end
    `SETUP_CLR_SP_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `SETUP_WAIT_SETUP_SENT;
    end
    `SETUP_CLR_SP_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `SETUP_WAIT_DATA_SENT;
    end
    `SETUP_WAIT_PKT_RXED:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `FLAG;
      end
    end
    `SETUP_HC_WAIT_RDY:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `SETUP_CLR_SP_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `SETUP;
      end
    end
    `SETUP_WAIT_SETUP_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `SETUP_CLR_SP_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
    end
    `SETUP_WAIT_DATA_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `SETUP_WAIT_PKT_RXED;
        next_getPacketREn <= 1'b1;
      end
    end
    `IN_WAIT_DATA_RXED:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `IN_CHK_FOR_ERROR;
      end
    end
    `IN_CHK_FOR_ERROR:
    begin
      if (RXStatus [`HC_CRC_ERROR_BIT] == 1'b0 &&
        RXStatus [`HC_BIT_STUFF_ERROR_BIT] == 1'b0 &&
        RXStatus [`HC_RX_OVERFLOW_BIT] == 1'b0 &&
        RXStatus [`HC_NAK_RXED_BIT] == 1'b0 &&
        RXStatus [`HC_STALL_RXED_BIT] == 1'b0 &&
        RXStatus [`HC_RX_TIME_OUT_BIT] == 1'b0)
      begin
        NextState_hstCntrl <= `IN_WAIT_SP_RDY2;
      end
      else
      begin
        NextState_hstCntrl <= `FLAG;
      end
    end
    `IN_CLR_SP_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `IN_WAIT_ACK_SENT;
    end
    `IN_WAIT_IN_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `IN_WAIT_DATA_RXED;
        next_getPacketREn <= 1'b1;
      end
    end
    `IN_WAIT_SP_RDY1:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `IN_CLR_SP_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `IN;
      end
    end
    `IN_WAIT_SP_RDY2:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `IN_CLR_SP_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `ACK;
      end
    end
    `IN_CLR_SP_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `IN_WAIT_IN_SENT;
    end
    `IN_WAIT_ACK_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `FLAG;
      end
    end
    `OUT0_WAIT_RX_DATA:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `FLAG;
      end
    end
    `OUT0_WAIT_DATA0_SENT:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT0_WAIT_RX_DATA;
        next_getPacketREn <= 1'b1;
      end
    end
    `OUT0_WAIT_OUT_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT0_CLR_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
    end
    `OUT0_WAIT_SP_RDY1:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT0_CLR_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `OUT;
      end
    end
    `OUT0_CLR_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT0_WAIT_OUT_SENT;
    end
    `OUT0_CLR_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT0_WAIT_DATA0_SENT;
    end
    `OUT1_WAIT_RX_DATA:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `FLAG;
      end
    end
    `OUT1_WAIT_OUT_SENT:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT1_CLR_WEN2;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA1;
      end
    end
    `OUT1_WAIT_DATA1_SENT:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT1_WAIT_RX_DATA;
        next_getPacketREn <= 1'b1;
      end
    end
    `OUT1_WAIT_SP_RDY1:
    begin
      if (sendPacketRdy == 1'b1)
      begin
        NextState_hstCntrl <= `OUT1_CLR_WEN1;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `OUT;
      end
    end
    `OUT1_CLR_WEN1:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT1_WAIT_OUT_SENT;
    end
    `OUT1_CLR_WEN2:
    begin
      next_sendPacketWEn <= 1'b0;
      NextState_hstCntrl <= `OUT1_WAIT_DATA1_SENT;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_hstCntrl <= `START_HC;
  else
    CurrState_hstCntrl <= NextState_hstCntrl;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    transDone <= 1'b0;
    clearTXReq <= 1'b0;
    getPacketREn <= 1'b0;
    sendPacketArbiterReq <= 1'b0;
    sendPacketPID <= 4'b0;
    sendPacketWEn <= 1'b0;
  end
  else 
  begin
    transDone <= next_transDone;
    clearTXReq <= next_clearTXReq;
    getPacketREn <= next_getPacketREn;
    sendPacketArbiterReq <= next_sendPacketArbiterReq;
    sendPacketPID <= next_sendPacketPID;
    sendPacketWEn <= next_sendPacketWEn;
  end
end

endmodule