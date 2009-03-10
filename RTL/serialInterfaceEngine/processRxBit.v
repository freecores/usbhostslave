
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// processrxbit
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
`include "usbSerialInterfaceEngine_h.v"


module processRxBit (clk, JBit, KBit, processRxBitRdy, processRxBitsWEn, processRxByteRdy, processRxByteWEn, resumeDetected, rst, RxBitsIn, RxCtrlOut, RxDataOut, RxWireActive);
input   clk;
input   [1:0]JBit;
input   [1:0]KBit;
input   processRxBitsWEn;
input   processRxByteRdy;
input   rst;
input   [1:0]RxBitsIn;
input   RxWireActive;
output  processRxBitRdy;
output  processRxByteWEn;
output  resumeDetected;
output  [7:0]RxCtrlOut;
output  [7:0]RxDataOut;

wire    clk;
wire    [1:0]JBit;
wire    [1:0]KBit;
reg     processRxBitRdy, next_processRxBitRdy;
wire    processRxBitsWEn;
wire    processRxByteRdy;
reg     processRxByteWEn, next_processRxByteWEn;
reg     resumeDetected, next_resumeDetected;
wire    rst;
wire    [1:0]RxBitsIn;
reg     [7:0]RxCtrlOut, next_RxCtrlOut;
reg     [7:0]RxDataOut, next_RxDataOut;
wire    RxWireActive;

// diagram signals declarations
reg bitStuffError, next_bitStuffError;
reg  [1:0]oldRXBits, next_oldRXBits;
reg  [4:0]resumeWaitCnt, next_resumeWaitCnt;
reg  [3:0]RXBitCount, next_RXBitCount;
reg  [1:0]RxBits, next_RxBits;
reg  [1:0]RXBitStMachCurrState, next_RXBitStMachCurrState;
reg  [7:0]RXByte, next_RXByte;
reg  [3:0]RXSameBitCount, next_RXSameBitCount;

// BINARY ENCODED state machine: prRxBit
// State codes definitions:
`define START 4'b0000
`define IDLE_FIRST_BIT 4'b0001
`define WAIT_BITS 4'b0010
`define IDLE_CHK_KBIT 4'b0011
`define DATA_RX_LAST_BIT 4'b0100
`define DATA_RX_CHK_SE0 4'b0101
`define DATA_RX_DATA_DESTUFF 4'b0110
`define DATA_RX_BYTE_SEND2 4'b0111
`define DATA_RX_BYTE_WAIT_RDY 4'b1000
`define RES_RX_CHK 4'b1001
`define DATA_RX_ERROR_CHK_RES 4'b1010
`define RES_END_CHK1 4'b1011
`define IDLE_WAIT_PRB_RDY 4'b1100
`define DATA_RX_WAIT_PRB_RDY 4'b1101
`define DATA_RX_ERROR_WAIT_RDY 4'b1110

reg [3:0]CurrState_prRxBit, NextState_prRxBit;


// Machine: prRxBit

// NextState logic (combinatorial)
always @ (RxBits or processRxBitsWEn or JBit or RxBitsIn or KBit or RxWireActive or RXSameBitCount or RXBitCount or RXByte or processRxByteRdy or resumeWaitCnt or processRxByteWEn or RxCtrlOut or RxDataOut or resumeDetected or RXBitStMachCurrState or oldRXBits or bitStuffError or processRxBitRdy or CurrState_prRxBit)
begin
  NextState_prRxBit <= CurrState_prRxBit;
  // Set default values for outputs and signals
  next_processRxByteWEn <= processRxByteWEn;
  next_RxCtrlOut <= RxCtrlOut;
  next_RxDataOut <= RxDataOut;
  next_resumeDetected <= resumeDetected;
  next_RXBitStMachCurrState <= RXBitStMachCurrState;
  next_RxBits <= RxBits;
  next_RXSameBitCount <= RXSameBitCount;
  next_RXBitCount <= RXBitCount;
  next_oldRXBits <= oldRXBits;
  next_RXByte <= RXByte;
  next_bitStuffError <= bitStuffError;
  next_resumeWaitCnt <= resumeWaitCnt;
  next_processRxBitRdy <= processRxBitRdy;
  case (CurrState_prRxBit)  // synopsys parallel_case full_case
    `START:
    begin
      next_processRxByteWEn <= 1'b0;
      next_RxCtrlOut <= 8'h00;
      next_RxDataOut <= 8'h00;
      next_resumeDetected <= 1'b0;
      next_RXBitStMachCurrState <= `IDLE_BIT_ST;
      next_RxBits <= 2'b00;
      next_RXSameBitCount <= 4'h0;
      next_RXBitCount <= 4'h0;
      next_oldRXBits <= 2'b00;
      next_RXByte <= 8'h00;
      next_bitStuffError <= 1'b0;
      next_resumeWaitCnt <= 5'h0;
      next_processRxBitRdy <= 1'b1;
      NextState_prRxBit <= `WAIT_BITS;
    end
    `WAIT_BITS:
    begin
      if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `DATA_RECEIVE_BIT_ST))
      begin
        NextState_prRxBit <= `DATA_RX_CHK_SE0;
        next_RxBits <= RxBitsIn;
        next_processRxBitRdy <= 1'b0;
      end
      else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `WAIT_RESUME_ST))
      begin
        NextState_prRxBit <= `RES_RX_CHK;
        next_RxBits <= RxBitsIn;
        next_processRxBitRdy <= 1'b0;
      end
      else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `RESUME_END_WAIT_ST))
      begin
        NextState_prRxBit <= `RES_END_CHK1;
        next_RxBits <= RxBitsIn;
        next_processRxBitRdy <= 1'b0;
      end
      else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `IDLE_BIT_ST))
      begin
        NextState_prRxBit <= `IDLE_CHK_KBIT;
        next_RxBits <= RxBitsIn;
        next_processRxBitRdy <= 1'b0;
      end
    end
    `IDLE_FIRST_BIT:
    begin
      next_processRxByteWEn <= 1'b0;
      next_RXBitStMachCurrState <= `DATA_RECEIVE_BIT_ST;
      next_RXSameBitCount <= 4'h0;
      next_RXBitCount <= 4'h1;
      next_oldRXBits <= RxBits;
      //zero is always the first RZ data bit of a new packet
      next_RXByte <= 8'h00;
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
    `IDLE_CHK_KBIT:
    begin
      if ((RxBits == KBit) && (RxWireActive == 1'b1))
      begin
        NextState_prRxBit <= `IDLE_WAIT_PRB_RDY;
      end
      else
      begin
        NextState_prRxBit <= `WAIT_BITS;
        next_processRxBitRdy <= 1'b1;
      end
    end
    `IDLE_WAIT_PRB_RDY:
    begin
      if (processRxByteRdy == 1'b1)
      begin
        NextState_prRxBit <= `IDLE_FIRST_BIT;
        next_RxDataOut <= 8'h00;
        //redundant data
        next_RxCtrlOut <= `DATA_START;
        //start of packet
        next_processRxByteWEn <= 1'b1;
      end
    end
    `DATA_RX_LAST_BIT:
    begin
      next_processRxByteWEn <= 1'b0;
      next_RXBitStMachCurrState <= `IDLE_BIT_ST;
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
    `DATA_RX_CHK_SE0:
    begin
      next_bitStuffError <= 1'b0;
      if (RxBits == `SE0)
      begin
        NextState_prRxBit <= `DATA_RX_WAIT_PRB_RDY;
      end
      else
      begin
        NextState_prRxBit <= `DATA_RX_DATA_DESTUFF;
        if (RxBits == oldRXBits)                 //if the current 'RxBits' are the same as the old 'RxBits', then
        begin
        next_RXSameBitCount <= RXSameBitCount + 1'b1;
        //inc 'RXSameBitCount'
        if (RXSameBitCount == `MAX_CONSEC_SAME_BITS) //if 'RXSameBitCount' == 6 there has been a bit stuff error
        next_bitStuffError <= 1'b1;
        //flag 'bitStuffError'
        else                                          //else no bit stuffing error
        begin
        next_RXBitCount <= RXBitCount + 1'b1;
        if (RXBitCount != `MAX_CONSEC_SAME_BITS_PLUS1) begin
        next_processRxBitRdy <= 1'b1;
        //early indication of ready
        end
        next_RXByte <= { 1'b1, RXByte[7:1]};
        //RZ bit <= 1 (ie no change in 'RxBits')
        end
        end
        else                                            //else current 'RxBits' are different from old 'RxBits'
        begin
        if (RXSameBitCount != `MAX_CONSEC_SAME_BITS)  //if this is not the RZ 0 bit after 6 consecutive RZ 1s, then
        begin
        next_RXBitCount <= RXBitCount + 1'b1;
        if (RXBitCount != 4'h7) begin
        next_processRxBitRdy <= 1'b1;
        //early indication of ready
        end
        next_RXByte <= {1'b0, RXByte[7:1]};
        //RZ bit <= 0 (ie current'RxBits' is different than old 'RxBits')
        end
        next_RXSameBitCount <= 4'h0;
        //reset 'RXSameBitCount'
        end
        next_oldRXBits <= RxBits;
      end
    end
    `DATA_RX_WAIT_PRB_RDY:
    begin
      if (processRxByteRdy == 1'b1)
      begin
        NextState_prRxBit <= `DATA_RX_LAST_BIT;
        next_RxDataOut <= 8'h00;
        //redundant data
        next_RxCtrlOut <= `DATA_STOP;
        //end of packet
        next_processRxByteWEn <= 1'b1;
      end
    end
    `DATA_RX_DATA_DESTUFF:
    begin
      if (RXBitCount == 4'h8 & bitStuffError == 1'b0)
      begin
        NextState_prRxBit <= `DATA_RX_BYTE_WAIT_RDY;
      end
      else if (bitStuffError == 1'b1)
      begin
        NextState_prRxBit <= `DATA_RX_ERROR_WAIT_RDY;
      end
      else
      begin
        NextState_prRxBit <= `WAIT_BITS;
        next_processRxBitRdy <= 1'b1;
      end
    end
    `DATA_RX_BYTE_SEND2:
    begin
      next_processRxByteWEn <= 1'b0;
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
    `DATA_RX_BYTE_WAIT_RDY:
    begin
      if (processRxByteRdy == 1'b1)
      begin
        NextState_prRxBit <= `DATA_RX_BYTE_SEND2;
        next_RXBitCount <= 4'h0;
        next_RxDataOut <= RXByte;
        next_RxCtrlOut <= `DATA_STREAM;
        next_processRxByteWEn <= 1'b1;
      end
    end
    `DATA_RX_ERROR_CHK_RES:
    begin
      next_processRxByteWEn <= 1'b0;
      if (RxBits == JBit)                           //if current bit is a JBit, then
      next_RXBitStMachCurrState <= `IDLE_BIT_ST;
      //next state is idle
      else                                          //else
      begin
      next_RXBitStMachCurrState <= `WAIT_RESUME_ST;
      //check for resume
      next_resumeWaitCnt <= 5'h0;
      end
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
    `DATA_RX_ERROR_WAIT_RDY:
    begin
      if (processRxByteRdy == 1'b1)
      begin
        NextState_prRxBit <= `DATA_RX_ERROR_CHK_RES;
        next_RxDataOut <= 8'h00;
        //redundant data
        next_RxCtrlOut <= `DATA_BIT_STUFF_ERROR;
        next_processRxByteWEn <= 1'b1;
      end
    end
    `RES_RX_CHK:
    begin
      if (RxBits != KBit)  //can only be a resume if line remains in Kbit state
      next_RXBitStMachCurrState <= `IDLE_BIT_ST;
      else
      begin
      next_resumeWaitCnt <= resumeWaitCnt + 1'b1;
      //if we've waited long enough, then
      if (resumeWaitCnt == `RESUME_RX_WAIT_TIME)
      begin
      next_RXBitStMachCurrState <= `RESUME_END_WAIT_ST;
      next_resumeDetected <= 1'b1;
      //report resume detected
      end
      end
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
    `RES_END_CHK1:
    begin
      if (RxBits != KBit)  //line must leave KBit state for the end of resume
      begin
      next_RXBitStMachCurrState <= `IDLE_BIT_ST;
      next_resumeDetected <= 1'b0;
      //clear resume detected flag
      end
      NextState_prRxBit <= `WAIT_BITS;
      next_processRxBitRdy <= 1'b1;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_prRxBit <= `START;
  else
    CurrState_prRxBit <= NextState_prRxBit;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    processRxByteWEn <= 1'b0;
    RxCtrlOut <= 8'h00;
    RxDataOut <= 8'h00;
    resumeDetected <= 1'b0;
    processRxBitRdy <= 1'b1;
    RXBitStMachCurrState <= `IDLE_BIT_ST;
    RxBits <= 2'b00;
    RXSameBitCount <= 4'h0;
    RXBitCount <= 4'h0;
    oldRXBits <= 2'b00;
    RXByte <= 8'h00;
    bitStuffError <= 1'b0;
    resumeWaitCnt <= 5'h0;
  end
  else 
  begin
    processRxByteWEn <= next_processRxByteWEn;
    RxCtrlOut <= next_RxCtrlOut;
    RxDataOut <= next_RxDataOut;
    resumeDetected <= next_resumeDetected;
    processRxBitRdy <= next_processRxBitRdy;
    RXBitStMachCurrState <= next_RXBitStMachCurrState;
    RxBits <= next_RxBits;
    RXSameBitCount <= next_RXSameBitCount;
    RXBitCount <= next_RXBitCount;
    oldRXBits <= next_oldRXBits;
    RXByte <= next_RXByte;
    bitStuffError <= next_bitStuffError;
    resumeWaitCnt <= next_resumeWaitCnt;
  end
end

endmodule