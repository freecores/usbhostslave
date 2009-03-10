
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// processRxByte
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
// $Id: processRxByte.v,v 1.3 2004-12-31 14:40:43 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"

module processRxByte (clk, CRC16En, CRC16Result, CRC16UpdateRdy, CRC5_8Bit, CRC5En, CRC5Result, CRC5UpdateRdy, CRCData, processRxByteRdy, processRxDataInWEn, rst, rstCRC, RxByteIn, RxCtrlIn, RxCtrlOut, RxDataOut, RxDataOutWEn);
input   clk;
input   [15:0]CRC16Result;
input   CRC16UpdateRdy;
input   [4:0]CRC5Result;
input   CRC5UpdateRdy;
input   processRxDataInWEn;
input   rst;
input   [7:0]RxByteIn;
input   [7:0]RxCtrlIn;
output  CRC16En;
output  CRC5_8Bit;
output  CRC5En;
output  [7:0]CRCData;
output  processRxByteRdy;
output  rstCRC;
output  [7:0]RxCtrlOut;
output  [7:0]RxDataOut;
output  RxDataOutWEn;

wire    clk;
reg     CRC16En, next_CRC16En;
wire    [15:0]CRC16Result;
wire    CRC16UpdateRdy;
reg     CRC5_8Bit, next_CRC5_8Bit;
reg     CRC5En, next_CRC5En;
wire    [4:0]CRC5Result;
wire    CRC5UpdateRdy;
reg     [7:0]CRCData, next_CRCData;
reg     processRxByteRdy, next_processRxByteRdy;
wire    processRxDataInWEn;
wire    rst;
reg     rstCRC, next_rstCRC;
wire    [7:0]RxByteIn;
wire    [7:0]RxCtrlIn;
reg     [7:0]RxCtrlOut, next_RxCtrlOut;
reg     [7:0]RxDataOut, next_RxDataOut;
reg     RxDataOutWEn, next_RxDataOutWEn;

// diagram signals declarations
reg ACKRxed, next_ACKRxed;
reg bitStuffError, next_bitStuffError;
reg CRCError, next_CRCError;
reg dataSequence, next_dataSequence;
reg NAKRxed, next_NAKRxed;
reg  [7:0]RxByte, next_RxByte;
reg  [2:0]RXByteStMachCurrState, next_RXByteStMachCurrState;
reg  [7:0]RxCtrl, next_RxCtrl;
reg  [9:0]RXDataByteCnt, next_RXDataByteCnt;
reg RxOverflow, next_RxOverflow;
reg  [7:0]RxStatus;
reg RxTimeOut, next_RxTimeOut;
reg Signal1, next_Signal1;
reg stallRxed, next_stallRxed;

// BINARY ENCODED state machine: prRxByte
// State codes definitions:
`define CHK_ST 4'b0000
`define START_PRBY 4'b0001
`define WAIT_BYTE 4'b0010
`define IDLE_CHK_START 4'b0011
`define CHK_SYNC_DO 4'b0100
`define CHK_PID_DO_CHK 4'b0101
`define CHK_PID_FIRST_BYTE_PROC 4'b0110
`define HSHAKE_FIN 4'b0111
`define HSHAKE_CHK 4'b1000
`define TOKEN_CHK_STRM 4'b1001
`define TOKEN_FIN 4'b1010
`define DATA_FIN 4'b1011
`define DATA_CHK_STRM 4'b1100
`define TOKEN_WAIT_CRC 4'b1101
`define DATA_WAIT_CRC 4'b1110

reg [3:0]CurrState_prRxByte, NextState_prRxByte;

// Diagram actions (continuous assignments allowed only: assign ...)
always @
(next_CRCError or next_bitStuffError or
next_RxOverflow or next_NAKRxed or
next_stallRxed or next_ACKRxed or
next_dataSequence)
begin
RxStatus <=
{1'b0, next_dataSequence,
next_ACKRxed,
next_stallRxed, next_NAKRxed,
next_RxOverflow,
next_bitStuffError, next_CRCError };
end


// Machine: prRxByte

// NextState logic (combinatorial)
always @ (RXByteStMachCurrState or processRxDataInWEn or CRC16Result or CRC5Result or RxByteIn or RxCtrlIn or RxByte or RxStatus or RXDataByteCnt or CRC5UpdateRdy or CRC16UpdateRdy or RxCtrl or CRCError or bitStuffError or RxOverflow or RxTimeOut or NAKRxed or stallRxed or ACKRxed or dataSequence or RxDataOut or RxCtrlOut or RxDataOutWEn or rstCRC or CRCData or CRC5En or CRC5_8Bit or CRC16En or processRxByteRdy or CurrState_prRxByte)
begin
  NextState_prRxByte <= CurrState_prRxByte;
  // Set default values for outputs and signals
  next_RxByte <= RxByte;
  next_RxCtrl <= RxCtrl;
  next_RXByteStMachCurrState <= RXByteStMachCurrState;
  next_CRCError <= CRCError;
  next_bitStuffError <= bitStuffError;
  next_RxOverflow <= RxOverflow;
  next_RxTimeOut <= RxTimeOut;
  next_NAKRxed <= NAKRxed;
  next_stallRxed <= stallRxed;
  next_ACKRxed <= ACKRxed;
  next_dataSequence <= dataSequence;
  next_RxDataOut <= RxDataOut;
  next_RxCtrlOut <= RxCtrlOut;
  next_RxDataOutWEn <= RxDataOutWEn;
  next_rstCRC <= rstCRC;
  next_CRCData <= CRCData;
  next_CRC5En <= CRC5En;
  next_CRC5_8Bit <= CRC5_8Bit;
  next_CRC16En <= CRC16En;
  next_RXDataByteCnt <= RXDataByteCnt;
  next_processRxByteRdy <= processRxByteRdy;
  case (CurrState_prRxByte)  // synopsys parallel_case full_case
    `CHK_ST:
    begin
      if (RXByteStMachCurrState == `HS_BYTE_ST)
      begin
        NextState_prRxByte <= `HSHAKE_CHK;
      end
      else if (RXByteStMachCurrState == `TOKEN_BYTE_ST)
      begin
        NextState_prRxByte <= `TOKEN_WAIT_CRC;
      end
      else if (RXByteStMachCurrState == `DATA_BYTE_ST)
      begin
        NextState_prRxByte <= `DATA_WAIT_CRC;
      end
      else if (RXByteStMachCurrState == `IDLE_BYTE_ST)
      begin
        NextState_prRxByte <= `IDLE_CHK_START;
      end
      else if (RXByteStMachCurrState == `CHECK_SYNC_ST)
      begin
        NextState_prRxByte <= `CHK_SYNC_DO;
      end
      else if (RXByteStMachCurrState == `CHECK_PID_ST)
      begin
        NextState_prRxByte <= `CHK_PID_DO_CHK;
      end
    end
    `START_PRBY:
    begin
      next_RxByte <= 8'h00;
      next_RxCtrl <= 8'h00;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      next_CRCError <= 1'b0;
      next_bitStuffError <= 1'b0;
      next_RxOverflow <= 1'b0;
      next_RxTimeOut <= 1'b0;
      next_NAKRxed <= 1'b0;
      next_stallRxed <= 1'b0;
      next_ACKRxed <= 1'b0;
      next_dataSequence <= 1'b0;
      next_RxDataOut <= 8'h00;
      next_RxCtrlOut <= 8'h00;
      next_RxDataOutWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      next_CRCData <= 8'h00;
      next_CRC5En <= 1'b0;
      next_CRC5_8Bit <= 1'b0;
      next_CRC16En <= 1'b0;
      next_RXDataByteCnt <= 10'h00;
      next_processRxByteRdy <= 1'b1;
      NextState_prRxByte <= `WAIT_BYTE;
    end
    `WAIT_BYTE:
    begin
      if (processRxDataInWEn == 1'b1)
      begin
        NextState_prRxByte <= `CHK_ST;
        next_RxByte <= RxByteIn;
        next_RxCtrl <= RxCtrlIn;
        next_processRxByteRdy <= 1'b0;
      end
    end
    `HSHAKE_FIN:
    begin
      next_RxDataOutWEn <= 1'b0;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `HSHAKE_CHK:
    begin
      NextState_prRxByte <= `HSHAKE_FIN;
      if (RxCtrl != `DATA_STOP) //If more than PID rxed, then report error
      next_RxOverflow <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RxDataOutWEn <= 1'b1;
    end
    `CHK_PID_DO_CHK:
    begin
      if ((RxByte[7:4] ^ RxByte[3:0] ) != 4'hf)
      begin
        NextState_prRxByte <= `WAIT_BYTE;
        next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
        next_processRxByteRdy <= 1'b1;
      end
      else
      begin
        NextState_prRxByte <= `CHK_PID_FIRST_BYTE_PROC;
        next_CRCError <= 1'b0;
        next_bitStuffError <= 1'b0;
        next_RxOverflow <= 1'b0;
        next_NAKRxed <= 1'b0;
        next_stallRxed <= 1'b0;
        next_ACKRxed <= 1'b0;
        next_dataSequence <= 1'b0;
        next_RxTimeOut <= 1'b0;
        next_RXDataByteCnt <= 0;
        next_RxDataOut <= RxByte;
        next_RxCtrlOut <= `RX_PACKET_START;
        next_RxDataOutWEn <= 1'b1;
        next_rstCRC <= 1'b1;
      end
    end
    `CHK_PID_FIRST_BYTE_PROC:
    begin
      next_rstCRC <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      case (RxByte[1:0] )
      `SPECIAL:                              //Special PID.
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      `TOKEN:                                //Token PID
      begin
      next_RXByteStMachCurrState <= `TOKEN_BYTE_ST;
      next_RXDataByteCnt <= 0;
      end
      `HANDSHAKE:                            //Handshake PID
      begin
      case (RxByte[3:2] )
      2'b00:
      next_ACKRxed <= 1'b1;
      2'b10:
      next_NAKRxed <= 1'b1;
      2'b11:
      next_stallRxed <= 1'b1;
      default:
      begin
      $display ("Invalid Handshake PID detected in ProcessRXByte\n");
      end
      endcase
      next_RXByteStMachCurrState <= `HS_BYTE_ST;
      end
      `DATA:                                  //Data PID
      begin
      case (RxByte[3:2] )
      2'b00:
      next_dataSequence <= 1'b0;
      2'b10:
      next_dataSequence <= 1'b1;
      default:
      $display ("Invalid DATA PID detected in ProcessRXByte\n");
      endcase
      next_RXByteStMachCurrState <= `DATA_BYTE_ST;
      next_RXDataByteCnt <= 0;
      end
      endcase
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `DATA_FIN:
    begin
      next_CRC16En <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `DATA_CHK_STRM:
    begin
      next_RXDataByteCnt <= RXDataByteCnt + 1'b1;
      case (RxCtrl)
      `DATA_STOP:
      begin
      if (CRC16Result != 16'hb001)
      next_CRCError <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      end
      `DATA_BIT_STUFF_ERROR:
      begin
      next_bitStuffError <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      end
      `DATA_STREAM:
      begin
      next_RxDataOut <= RxByte;
      next_RxCtrlOut <= `RX_PACKET_STREAM;
      next_CRCData <= RxByte;
      next_CRC16En <= 1'b1;
      end
      endcase
      next_RxDataOutWEn <= 1'b1;
      NextState_prRxByte <= `DATA_FIN;
    end
    `DATA_WAIT_CRC:
    begin
      if (CRC16UpdateRdy == 1'b1)
      begin
        NextState_prRxByte <= `DATA_CHK_STRM;
      end
    end
    `TOKEN_CHK_STRM:
    begin
      next_RXDataByteCnt <= RXDataByteCnt + 1'b1;
      case (RxCtrl)
      `DATA_STOP:
      begin
      if (CRC5Result != 5'h6)
      next_CRCError <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      end
      `DATA_BIT_STUFF_ERROR:
      begin
      next_bitStuffError <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      end
      `DATA_STREAM:
      begin
      if (RXDataByteCnt > 10'h2)
      begin
      next_RxOverflow <= 1'b1;
      next_RxDataOut <= RxStatus;
      next_RxCtrlOut <= `RX_PACKET_STOP;
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      end
      else
      begin
      next_RxDataOut <= RxByte;
      next_RxCtrlOut <= `RX_PACKET_STREAM;
      next_CRCData <= RxByte;
      next_CRC5_8Bit <= 1'b1;
      next_CRC5En <= 1'b1;
      end
      end
      endcase
      next_RxDataOutWEn <= 1'b1;
      NextState_prRxByte <= `TOKEN_FIN;
    end
    `TOKEN_FIN:
    begin
      next_CRC5En <= 1'b0;
      next_RxDataOutWEn <= 1'b0;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `TOKEN_WAIT_CRC:
    begin
      if (CRC5UpdateRdy == 1'b1)
      begin
        NextState_prRxByte <= `TOKEN_CHK_STRM;
      end
    end
    `CHK_SYNC_DO:
    begin
      if (RxByte == `SYNC_BYTE)
      next_RXByteStMachCurrState <= `CHECK_PID_ST;
      else
      next_RXByteStMachCurrState <= `IDLE_BYTE_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
    `IDLE_CHK_START:
    begin
      if (RxCtrl == `DATA_START)
      next_RXByteStMachCurrState <= `CHECK_SYNC_ST;
      NextState_prRxByte <= `WAIT_BYTE;
      next_processRxByteRdy <= 1'b1;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_prRxByte <= `START_PRBY;
  else
    CurrState_prRxByte <= NextState_prRxByte;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    RxDataOut <= 8'h00;
    RxCtrlOut <= 8'h00;
    RxDataOutWEn <= 1'b0;
    rstCRC <= 1'b0;
    CRCData <= 8'h00;
    CRC5En <= 1'b0;
    CRC5_8Bit <= 1'b0;
    CRC16En <= 1'b0;
    processRxByteRdy <= 1'b1;
    RxByte <= 8'h00;
    RxCtrl <= 8'h00;
    RXByteStMachCurrState <= `IDLE_BYTE_ST;
    CRCError <= 1'b0;
    bitStuffError <= 1'b0;
    RxOverflow <= 1'b0;
    RxTimeOut <= 1'b0;
    NAKRxed <= 1'b0;
    stallRxed <= 1'b0;
    ACKRxed <= 1'b0;
    dataSequence <= 1'b0;
    RXDataByteCnt <= 10'h00;
  end
  else 
  begin
    RxDataOut <= next_RxDataOut;
    RxCtrlOut <= next_RxCtrlOut;
    RxDataOutWEn <= next_RxDataOutWEn;
    rstCRC <= next_rstCRC;
    CRCData <= next_CRCData;
    CRC5En <= next_CRC5En;
    CRC5_8Bit <= next_CRC5_8Bit;
    CRC16En <= next_CRC16En;
    processRxByteRdy <= next_processRxByteRdy;
    RxByte <= next_RxByte;
    RxCtrl <= next_RxCtrl;
    RXByteStMachCurrState <= next_RXByteStMachCurrState;
    CRCError <= next_CRCError;
    bitStuffError <= next_bitStuffError;
    RxOverflow <= next_RxOverflow;
    RxTimeOut <= next_RxTimeOut;
    NAKRxed <= next_NAKRxed;
    stallRxed <= next_stallRxed;
    ACKRxed <= next_ACKRxed;
    dataSequence <= next_dataSequence;
    RXDataByteCnt <= next_RXDataByteCnt;
  end
end

endmodule