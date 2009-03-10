
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveGetPacket
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
`include "usbConstants_h.v"

module slaveGetPacket (ACKRxed, bitStuffError, clk, CRCError, dataSequence, endPointReady, getPacketEn, rst, RXDataIn, RXDataValid, RXFifoData, RXFifoFull, RXFifoWEn, RXOverflow, RXPacketRdy, RxPID, RXStreamStatusIn, RXTimeOut, SIERxTimeOut);
input   clk;
input   endPointReady;
input   getPacketEn;
input   rst;
input   [7:0]RXDataIn;
input   RXDataValid;
input   RXFifoFull;
input   [7:0]RXStreamStatusIn;
input   SIERxTimeOut;    // Single cycle pulse
output  ACKRxed;
output  bitStuffError;
output  CRCError;
output  dataSequence;
output  [7:0]RXFifoData;
output  RXFifoWEn;
output  RXOverflow;
output  RXPacketRdy;
output  [3:0]RxPID;
output  RXTimeOut;

reg     ACKRxed, next_ACKRxed;
reg     bitStuffError, next_bitStuffError;
wire    clk;
reg     CRCError, next_CRCError;
reg     dataSequence, next_dataSequence;
wire    endPointReady;
wire    getPacketEn;
wire    rst;
wire    [7:0]RXDataIn;
wire    RXDataValid;
reg     [7:0]RXFifoData, next_RXFifoData;
wire    RXFifoFull;
reg     RXFifoWEn, next_RXFifoWEn;
reg     RXOverflow, next_RXOverflow;
reg     RXPacketRdy, next_RXPacketRdy;
reg     [3:0]RxPID, next_RxPID;
wire    [7:0]RXStreamStatusIn;
reg     RXTimeOut, next_RXTimeOut;
wire    SIERxTimeOut;

// diagram signals declarations
reg  [7:0]RXByte, next_RXByte;
reg  [7:0]RXByteOld, next_RXByteOld;
reg  [7:0]RXByteOldest, next_RXByteOldest;
reg  [7:0]RXStreamStatus, next_RXStreamStatus;

// BINARY ENCODED state machine: slvGetPkt
// State codes definitions:
`define PROC_PKT_CHK_PID 5'b00000
`define PROC_PKT_HS 5'b00001
`define PROC_PKT_DATA_W_D1 5'b00010
`define PROC_PKT_DATA_CHK_D1 5'b00011
`define PROC_PKT_DATA_W_D2 5'b00100
`define PROC_PKT_DATA_FIN 5'b00101
`define PROC_PKT_DATA_CHK_D2 5'b00110
`define PROC_PKT_DATA_W_D3 5'b00111
`define PROC_PKT_DATA_CHK_D3 5'b01000
`define PROC_PKT_DATA_LOOP_CHK_FIFO 5'b01001
`define PROC_PKT_DATA_LOOP_FIFO_FULL 5'b01010
`define PROC_PKT_DATA_LOOP_W_D 5'b01011
`define START_GP 5'b01100
`define WAIT_PKT 5'b01101
`define CHK_PKT_START 5'b01110
`define WAIT_EN 5'b01111
`define PKT_RDY 5'b10000
`define PROC_PKT_DATA_LOOP_DELAY 5'b10001
`define PROC_PKT_DATA_LOOP_EP_N_RDY 5'b10010

reg [4:0]CurrState_slvGetPkt, NextState_slvGetPkt;


// Machine: slvGetPkt

// NextState logic (combinatorial)
always @ (RXByte or RXDataValid or RXDataIn or RXStreamStatusIn or RXStreamStatus or endPointReady or RXFifoFull or RXByteOldest or RXByteOld or SIERxTimeOut or getPacketEn or RXOverflow or ACKRxed or CRCError or bitStuffError or dataSequence or RXFifoWEn or RXFifoData or RXPacketRdy or RXTimeOut or RxPID or CurrState_slvGetPkt)
begin
  NextState_slvGetPkt <= CurrState_slvGetPkt;
  // Set default values for outputs and signals
  next_RXOverflow <= RXOverflow;
  next_ACKRxed <= ACKRxed;
  next_RXByte <= RXByte;
  next_RXStreamStatus <= RXStreamStatus;
  next_RXByteOldest <= RXByteOldest;
  next_CRCError <= CRCError;
  next_bitStuffError <= bitStuffError;
  next_dataSequence <= dataSequence;
  next_RXByteOld <= RXByteOld;
  next_RXFifoWEn <= RXFifoWEn;
  next_RXFifoData <= RXFifoData;
  next_RXPacketRdy <= RXPacketRdy;
  next_RXTimeOut <= RXTimeOut;
  next_RxPID <= RxPID;
  case (CurrState_slvGetPkt)  // synopsys parallel_case full_case
    `START_GP:
    begin
      NextState_slvGetPkt <= `WAIT_EN;
    end
    `WAIT_PKT:
    begin
      next_CRCError <= 1'b0;
      next_bitStuffError <= 1'b0;
      next_RXOverflow <= 1'b0;
      next_RXTimeOut <= 1'b0;
      next_ACKRxed <= 1'b0;
      next_dataSequence <= 1'b0;
      if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `CHK_PKT_START;
        next_RXByte <= RXDataIn;
        next_RXStreamStatus <= RXStreamStatusIn;
      end
      else if (SIERxTimeOut == 1'b1)
      begin
        NextState_slvGetPkt <= `PKT_RDY;
        next_RXTimeOut <= 1'b1;
      end
    end
    `CHK_PKT_START:
    begin
      if (RXStreamStatus == `RX_PACKET_START)
      begin
        NextState_slvGetPkt <= `PROC_PKT_CHK_PID;
        next_RxPID <= RXByte[3:0];
      end
      else
      begin
        NextState_slvGetPkt <= `PKT_RDY;
        next_RXTimeOut <= 1'b1;
      end
    end
    `WAIT_EN:
    begin
      next_RXPacketRdy <= 1'b0;
      if (getPacketEn == 1'b1)
      begin
        NextState_slvGetPkt <= `WAIT_PKT;
      end
    end
    `PKT_RDY:
    begin
      next_RXPacketRdy <= 1'b1;
      NextState_slvGetPkt <= `WAIT_EN;
    end
    `PROC_PKT_CHK_PID:
    begin
      if (RXByte[1:0] == `HANDSHAKE)
      begin
        NextState_slvGetPkt <= `PROC_PKT_HS;
      end
      else if (RXByte[1:0] == `DATA)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_W_D1;
      end
      else
      begin
        NextState_slvGetPkt <= `PKT_RDY;
      end
    end
    `PROC_PKT_HS:
    begin
      if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `PKT_RDY;
        next_RXOverflow <= RXDataIn[`RX_OVERFLOW_BIT];
        next_ACKRxed <= RXDataIn[`ACK_RXED_BIT];
      end
    end
    `PROC_PKT_DATA_W_D1:
    begin
      if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D1;
        next_RXByte <= RXDataIn;
        next_RXStreamStatus <= RXStreamStatusIn;
      end
    end
    `PROC_PKT_DATA_CHK_D1:
    begin
      if (RXStreamStatus == `RX_PACKET_STREAM)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_W_D2;
        next_RXByteOldest <= RXByte;
      end
      else
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
      end
    end
    `PROC_PKT_DATA_W_D2:
    begin
      if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D2;
        next_RXByte <= RXDataIn;
        next_RXStreamStatus <= RXStreamStatusIn;
      end
    end
    `PROC_PKT_DATA_FIN:
    begin
      next_CRCError <= RXByte[`CRC_ERROR_BIT];
      next_bitStuffError <= RXByte[`BIT_STUFF_ERROR_BIT];
      next_dataSequence <= RXByte[`DATA_SEQUENCE_BIT];
      NextState_slvGetPkt <= `PKT_RDY;
    end
    `PROC_PKT_DATA_CHK_D2:
    begin
      if (RXStreamStatus == `RX_PACKET_STREAM)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_W_D3;
        next_RXByteOld <= RXByte;
      end
      else
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
      end
    end
    `PROC_PKT_DATA_W_D3:
    begin
      if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D3;
        next_RXByte <= RXDataIn;
        next_RXStreamStatus <= RXStreamStatusIn;
      end
    end
    `PROC_PKT_DATA_CHK_D3:
    begin
      if (RXStreamStatus == `RX_PACKET_STREAM)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_CHK_FIFO;
      end
      else
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
      end
    end
    `PROC_PKT_DATA_LOOP_CHK_FIFO:
    begin
      if (endPointReady == 1'b0)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_EP_N_RDY;
      end
      else if (RXFifoFull == 1'b1)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_FIFO_FULL;
        next_RXOverflow <= 1'b1;
      end
      else
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_W_D;
        next_RXFifoWEn <= 1'b1;
        next_RXFifoData <= RXByteOldest;
        next_RXByteOldest <= RXByteOld;
        next_RXByteOld <= RXByte;
      end
    end
    `PROC_PKT_DATA_LOOP_FIFO_FULL:
    begin
      NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_W_D;
    end
    `PROC_PKT_DATA_LOOP_W_D:
    begin
      next_RXFifoWEn <= 1'b0;
      if ((RXDataValid == 1'b1) && (RXStreamStatusIn == `RX_PACKET_STREAM))
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_DELAY;
        next_RXByte <= RXDataIn;
      end
      else if (RXDataValid == 1'b1)
      begin
        NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
        next_RXByte <= RXDataIn;
      end
    end
    `PROC_PKT_DATA_LOOP_DELAY:
    begin
      NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_CHK_FIFO;
    end
    `PROC_PKT_DATA_LOOP_EP_N_RDY:    // Discard data
    begin
      NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_W_D;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_slvGetPkt <= `START_GP;
  else
    CurrState_slvGetPkt <= NextState_slvGetPkt;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    RXOverflow <= 1'b0;
    ACKRxed <= 1'b0;
    CRCError <= 1'b0;
    bitStuffError <= 1'b0;
    dataSequence <= 1'b0;
    RXFifoWEn <= 1'b0;
    RXFifoData <= 8'h00;
    RXPacketRdy <= 1'b0;
    RXTimeOut <= 1'b0;
    RxPID <= 4'h0;
    RXByte <= 8'h00;
    RXStreamStatus <= 8'h00;
    RXByteOldest <= 8'h00;
    RXByteOld <= 8'h00;
  end
  else 
  begin
    RXOverflow <= next_RXOverflow;
    ACKRxed <= next_ACKRxed;
    CRCError <= next_CRCError;
    bitStuffError <= next_bitStuffError;
    dataSequence <= next_dataSequence;
    RXFifoWEn <= next_RXFifoWEn;
    RXFifoData <= next_RXFifoData;
    RXPacketRdy <= next_RXPacketRdy;
    RXTimeOut <= next_RXTimeOut;
    RxPID <= next_RxPID;
    RXByte <= next_RXByte;
    RXStreamStatus <= next_RXStreamStatus;
    RXByteOldest <= next_RXByteOldest;
    RXByteOld <= next_RXByteOld;
  end
end

endmodule