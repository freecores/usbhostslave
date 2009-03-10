
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveSendPacket
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
//
`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"

module slaveSendPacket (clk, fifoData, fifoEmpty, fifoReadEn, PID, rst, SCTxPortCntl, SCTxPortData, SCTxPortGnt, SCTxPortRdy, SCTxPortReq, SCTxPortWEn, sendPacketRdy, sendPacketWEn);
input   clk;
input   [7:0]fifoData;
input   fifoEmpty;
input   [3:0]PID;
input   rst;
input   SCTxPortGnt;
input   SCTxPortRdy;
input   sendPacketWEn;
output  fifoReadEn;
output  [7:0]SCTxPortCntl;
output  [7:0]SCTxPortData;
output  SCTxPortReq;
output  SCTxPortWEn;
output  sendPacketRdy;

wire    clk;
wire    [7:0]fifoData;
wire    fifoEmpty;
reg     fifoReadEn, next_fifoReadEn;
wire    [3:0]PID;
wire    rst;
reg     [7:0]SCTxPortCntl, next_SCTxPortCntl;
reg     [7:0]SCTxPortData, next_SCTxPortData;
wire    SCTxPortGnt;
wire    SCTxPortRdy;
reg     SCTxPortReq, next_SCTxPortReq;
reg     SCTxPortWEn, next_SCTxPortWEn;
reg     sendPacketRdy, next_sendPacketRdy;
wire    sendPacketWEn;

// diagram signals declarations
reg  [7:0]PIDNotPID;

// BINARY ENCODED state machine: slvSndPkt
// State codes definitions:
`define START_SP1 4'b0000
`define SP_WAIT_ENABLE 4'b0001
`define SP1_WAIT_GNT 4'b0010
`define SP_SEND_PID_WAIT_RDY 4'b0011
`define SP_SEND_PID_FIN 4'b0100
`define FIN_SP1 4'b0101
`define SP_D0_D1_READ_FIFO 4'b0110
`define SP_D0_D1_WAIT_READ_FIFO 4'b0111
`define SP_D0_D1_FIFO_EMPTY 4'b1000
`define SP_D0_D1_FIN 4'b1001
`define SP_D0_D1_TERM_BYTE 4'b1010
`define SP_NOT_DATA 4'b1011
`define SP_D0_D1_CLR_WEN 4'b1100
`define SP_D0_D1_CLR_REN 4'b1101

reg [3:0]CurrState_slvSndPkt, NextState_slvSndPkt;

// Diagram actions (continuous assignments allowed only: assign ...)
always @(PID)
begin
PIDNotPID <=  { (PID ^ 4'hf), PID };
end


// Machine: slvSndPkt

// NextState logic (combinatorial)
always @ (sendPacketWEn or SCTxPortGnt or SCTxPortRdy or PIDNotPID or PID or fifoData or fifoEmpty or sendPacketRdy or fifoReadEn or SCTxPortData or SCTxPortCntl or SCTxPortWEn or SCTxPortReq or CurrState_slvSndPkt)
begin
  NextState_slvSndPkt <= CurrState_slvSndPkt;
  // Set default values for outputs and signals
  next_sendPacketRdy <= sendPacketRdy;
  next_fifoReadEn <= fifoReadEn;
  next_SCTxPortData <= SCTxPortData;
  next_SCTxPortCntl <= SCTxPortCntl;
  next_SCTxPortWEn <= SCTxPortWEn;
  next_SCTxPortReq <= SCTxPortReq;
  case (CurrState_slvSndPkt)  // synopsys parallel_case full_case
    `START_SP1:
    begin
      NextState_slvSndPkt <= `SP_WAIT_ENABLE;
    end
    `SP_WAIT_ENABLE:
    begin
      if (sendPacketWEn == 1'b1)
      begin
        NextState_slvSndPkt <= `SP1_WAIT_GNT;
        next_sendPacketRdy <= 1'b0;
        next_SCTxPortReq <= 1'b1;
      end
    end
    `SP1_WAIT_GNT:
    begin
      if (SCTxPortGnt == 1'b1)
      begin
        NextState_slvSndPkt <= `SP_SEND_PID_WAIT_RDY;
      end
    end
    `FIN_SP1:
    begin
      NextState_slvSndPkt <= `SP_WAIT_ENABLE;
      next_sendPacketRdy <= 1'b1;
      next_SCTxPortReq <= 1'b0;
    end
    `SP_NOT_DATA:
    begin
      NextState_slvSndPkt <= `FIN_SP1;
    end
    `SP_SEND_PID_WAIT_RDY:
    begin
      if (SCTxPortRdy == 1'b1)
      begin
        NextState_slvSndPkt <= `SP_SEND_PID_FIN;
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= PIDNotPID;
        next_SCTxPortCntl <= `TX_PACKET_START;
      end
    end
    `SP_SEND_PID_FIN:
    begin
      next_SCTxPortWEn <= 1'b0;
      if (PID == `DATA0 || PID == `DATA1)
      begin
        NextState_slvSndPkt <= `SP_D0_D1_FIFO_EMPTY;
      end
      else
      begin
        NextState_slvSndPkt <= `SP_NOT_DATA;
      end
    end
    `SP_D0_D1_READ_FIFO:
    begin
      next_SCTxPortWEn <= 1'b1;
      next_SCTxPortData <= fifoData;
      next_SCTxPortCntl <= `TX_PACKET_STREAM;
      NextState_slvSndPkt <= `SP_D0_D1_CLR_WEN;
    end
    `SP_D0_D1_WAIT_READ_FIFO:
    begin
      if (SCTxPortRdy == 1'b1)
      begin
        NextState_slvSndPkt <= `SP_D0_D1_CLR_REN;
        next_fifoReadEn <= 1'b1;
      end
    end
    `SP_D0_D1_FIFO_EMPTY:
    begin
      if (fifoEmpty == 1'b0)
      begin
        NextState_slvSndPkt <= `SP_D0_D1_WAIT_READ_FIFO;
      end
      else
      begin
        NextState_slvSndPkt <= `SP_D0_D1_TERM_BYTE;
      end
    end
    `SP_D0_D1_FIN:
    begin
      next_SCTxPortWEn <= 1'b0;
      NextState_slvSndPkt <= `FIN_SP1;
    end
    `SP_D0_D1_TERM_BYTE:
    begin
      if (SCTxPortRdy == 1'b1)
      begin
        NextState_slvSndPkt <= `SP_D0_D1_FIN;
        //Last byte is not valid data,
        //but the 'TX_PACKET_STOP' flag is required
        //by the SIE state machine to detect end of data packet
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= 8'h00;
        next_SCTxPortCntl <= `TX_PACKET_STOP;
      end
    end
    `SP_D0_D1_CLR_WEN:
    begin
      next_SCTxPortWEn <= 1'b0;
      NextState_slvSndPkt <= `SP_D0_D1_FIFO_EMPTY;
    end
    `SP_D0_D1_CLR_REN:
    begin
      next_fifoReadEn <= 1'b0;
      NextState_slvSndPkt <= `SP_D0_D1_READ_FIFO;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_slvSndPkt <= `START_SP1;
  else
    CurrState_slvSndPkt <= NextState_slvSndPkt;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    sendPacketRdy <= 1'b1;
    fifoReadEn <= 1'b0;
    SCTxPortData <= 8'h00;
    SCTxPortCntl <= 8'h00;
    SCTxPortWEn <= 1'b0;
    SCTxPortReq <= 1'b0;
  end
  else 
  begin
    sendPacketRdy <= next_sendPacketRdy;
    fifoReadEn <= next_fifoReadEn;
    SCTxPortData <= next_SCTxPortData;
    SCTxPortCntl <= next_SCTxPortCntl;
    SCTxPortWEn <= next_SCTxPortWEn;
    SCTxPortReq <= next_SCTxPortReq;
  end
end

endmodule