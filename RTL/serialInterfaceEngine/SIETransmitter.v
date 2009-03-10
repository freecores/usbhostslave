
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SIETransmitter
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
// $Id: SIETransmitter.v,v 1.3 2004-12-31 14:40:43 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"


module SIETransmitter (clk, CRC16En, CRC16Result, CRC16UpdateRdy, CRC5_8Bit, CRC5En, CRC5Result, CRC5UpdateRdy, CRCData, JBit, KBit, processTxByteRdy, processTxByteWEn, rst, rstCRC, SIEPortCtrlIn, SIEPortDataIn, SIEPortTxRdy, SIEPortWEn, TxByteOut, TxByteOutCtrl, USBWireCtrl, USBWireData, USBWireGnt, USBWireRdy, USBWireReq, USBWireWEn);
input   clk;
input   [15:0]CRC16Result;
input   CRC16UpdateRdy;
input   [4:0]CRC5Result;
input   CRC5UpdateRdy;
input   [1:0]JBit;
input   [1:0]KBit;
input   processTxByteRdy;
input   rst;
input   [7:0]SIEPortCtrlIn;
input   [7:0]SIEPortDataIn;
input   SIEPortWEn;
input   USBWireGnt;
input   USBWireRdy;
output  CRC16En;
output  CRC5_8Bit;
output  CRC5En;
output  [7:0]CRCData;
output  processTxByteWEn;
output  rstCRC;
output  SIEPortTxRdy;
output  [7:0]TxByteOut;
output  [7:0]TxByteOutCtrl;
output  USBWireCtrl;
output  [1:0]USBWireData;
output  USBWireReq;
output  USBWireWEn;

wire    clk;
reg     CRC16En, next_CRC16En;
wire    [15:0]CRC16Result;
wire    CRC16UpdateRdy;
reg     CRC5_8Bit, next_CRC5_8Bit;
reg     CRC5En, next_CRC5En;
wire    [4:0]CRC5Result;
wire    CRC5UpdateRdy;
reg     [7:0]CRCData, next_CRCData;
wire    [1:0]JBit;
wire    [1:0]KBit;
wire    processTxByteRdy;
reg     processTxByteWEn, next_processTxByteWEn;
wire    rst;
reg     rstCRC, next_rstCRC;
wire    [7:0]SIEPortCtrlIn;
wire    [7:0]SIEPortDataIn;
reg     SIEPortTxRdy, next_SIEPortTxRdy;
wire    SIEPortWEn;
reg     [7:0]TxByteOut, next_TxByteOut;
reg     [7:0]TxByteOutCtrl, next_TxByteOutCtrl;
reg     USBWireCtrl, next_USBWireCtrl;
reg     [1:0]USBWireData, next_USBWireData;
wire    USBWireGnt;
wire    USBWireRdy;
reg     USBWireReq, next_USBWireReq;
reg     USBWireWEn, next_USBWireWEn;

// diagram signals declarations
reg  [4:0]i, next_i;
reg  [7:0]SIEPortCtrl, next_SIEPortCtrl;
reg  [7:0]SIEPortData, next_SIEPortData;

// BINARY ENCODED state machine: SIETx
// State codes definitions:
`define RES_ST_CHK_FIN 6'b000000
`define IDLE_CHK_FIN 6'b000001
`define DIR_CTL_CHK_FIN 6'b000010
`define PKT_ST_CHK_PID 6'b000011
`define PKT_ST_DATA_DATA_CHK_STOP 6'b000100
`define PKT_ST_SPCL_PKT_SENT 6'b000101
`define PKT_ST_TKN_CRC_PKT_SENT 6'b000110
`define PKT_ST_TKN_PID_PKT_SENT 6'b000111
`define PKT_ST_DATA_DATA_PKT_SENT 6'b001000
`define PKT_ST_DATA_PID_PKT_SENT 6'b001001
`define PKT_ST_HS_PKT_SENT 6'b001010
`define PKT_ST_DATA_CRC_PKT_SENT1 6'b001011
`define PKT_ST_TKN_BYTE1_PKT_SENT1 6'b001100
`define PKT_ST_DATA_CRC_PKT_SENT2 6'b001101
`define RES_ST_S1 6'b001110
`define RES_ST_S3 6'b001111
`define RES_ST_S4 6'b010000
`define RES_ST_S5 6'b010001
`define RES_ST_S6 6'b010010
`define PKT_ST_SPCL_SEND_IDLE1 6'b010011
`define PKT_ST_SPCL_SEND_IDLE2 6'b010100
`define PKT_ST_SPCL_SEND_IDLE3 6'b010101
`define START_SIETX 6'b010110
`define STX_CHK_ST 6'b010111
`define STX_WAIT_BYTE 6'b011000
`define IDLE_STX_WAIT_GNT 6'b011001
`define IDLE_STX_WAIT_RDY 6'b011010
`define PKT_ST_TKN_CRC_UPD_CRC 6'b011011
`define PKT_ST_DATA_DATA_UPD_CRC 6'b011100
`define PKT_ST_TKN_BYTE1_UPD_CRC 6'b011101
`define PKT_ST_TKN_CRC_WAIT_BYTE 6'b011110
`define PKT_ST_TKN_BYTE1_WAIT_BYTE 6'b011111
`define PKT_ST_DATA_DATA_WAIT_BYTE 6'b100000
`define DIR_CTL_WAIT_GNT 6'b100001
`define RES_ST_WAIT_GNT 6'b100010
`define PKT_ST_HS_WAIT_RDY 6'b100011
`define PKT_ST_DATA_PID_WAIT_RDY 6'b100100
`define PKT_ST_SPCL_WAIT_RDY 6'b100101
`define RES_ST_WAIT_RDY 6'b100110
`define PKT_ST_DATA_DATA_WAIT_RDY 6'b100111
`define PKT_ST_TKN_PID_WAIT_RDY 6'b101000
`define PKT_ST_TKN_CRC_WAIT_RDY 6'b101001
`define PKT_ST_TKN_BYTE1_WAIT_RDY 6'b101010
`define DIR_CTL_WAIT_RDY 6'b101011
`define PKT_ST_DATA_CRC_WAIT_RDY1 6'b101100
`define PKT_ST_DATA_CRC_WAIT_RDY2 6'b101101
`define PKT_ST_WAIT_RDY_PKT 6'b101110
`define PKT_ST_SPCL_WAIT_WIRE 6'b101111
`define PKT_ST_WAIT_RDY_WIRE 6'b110000
`define PKT_ST_WAIT_GNT 6'b110001
`define PKT_ST_TKN_CRC_WAIT_CRC_RDY 6'b110010
`define PKT_ST_DATA_DATA_WAIT_CRC_RDY 6'b110011
`define PKT_ST_TKN_BYTE1_WAIT_CRC_RDY 6'b110100

reg [5:0]CurrState_SIETx, NextState_SIETx;


// Machine: SIETx

// NextState logic (combinatorial)
always @ (i or SIEPortData or SIEPortCtrl or USBWireRdy or JBit or SIEPortWEn or SIEPortDataIn or SIEPortCtrlIn or USBWireGnt or processTxByteRdy or KBit or CRC5Result or CRC16Result or CRC5UpdateRdy or CRC16UpdateRdy or USBWireWEn or USBWireReq or processTxByteWEn or rstCRC or USBWireData or USBWireCtrl or TxByteOut or TxByteOutCtrl or CRCData or CRC5En or CRC5_8Bit or CRC16En or SIEPortTxRdy or CurrState_SIETx)
begin
  NextState_SIETx <= CurrState_SIETx;
  // Set default values for outputs and signals
  next_USBWireWEn <= USBWireWEn;
  next_i <= i;
  next_USBWireReq <= USBWireReq;
  next_processTxByteWEn <= processTxByteWEn;
  next_rstCRC <= rstCRC;
  next_USBWireData <= USBWireData;
  next_USBWireCtrl <= USBWireCtrl;
  next_TxByteOut <= TxByteOut;
  next_TxByteOutCtrl <= TxByteOutCtrl;
  next_CRCData <= CRCData;
  next_CRC5En <= CRC5En;
  next_CRC5_8Bit <= CRC5_8Bit;
  next_CRC16En <= CRC16En;
  next_SIEPortTxRdy <= SIEPortTxRdy;
  next_SIEPortData <= SIEPortData;
  next_SIEPortCtrl <= SIEPortCtrl;
  case (CurrState_SIETx)  // synopsys parallel_case full_case
    `START_SIETX:
    begin
      next_processTxByteWEn <= 1'b0;
      next_TxByteOut <= 8'h00;
      next_TxByteOutCtrl <= 8'h00;
      next_USBWireData <= 2'b00;
      next_USBWireCtrl <= `TRI_STATE;
      next_USBWireReq <= 1'b0;
      next_USBWireWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      next_CRCData <= 8'h00;
      next_CRC5En <= 1'b0;
      next_CRC5_8Bit <= 1'b0;
      next_CRC16En <= 1'b0;
      next_SIEPortTxRdy <= 1'b0;
      next_SIEPortData <= 8'h00;
      next_SIEPortCtrl <= 8'h00;
      next_i <= 5'h0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `STX_CHK_ST:
    begin
      if (SIEPortCtrl == `TX_PACKET_START)
      begin
        NextState_SIETx <= `PKT_ST_WAIT_GNT;
        next_USBWireReq <= 1'b1;
      end
      else if (SIEPortCtrl == `TX_IDLE)
      begin
        NextState_SIETx <= `IDLE_STX_WAIT_GNT;
        next_USBWireReq <= 1'b1;
      end
      else if (SIEPortCtrl == `TX_DIRECT_CONTROL)
      begin
        NextState_SIETx <= `DIR_CTL_WAIT_GNT;
        next_USBWireReq <= 1'b1;
      end
      else if (SIEPortCtrl == `TX_RESUME_START)
      begin
        NextState_SIETx <= `RES_ST_WAIT_GNT;
        next_USBWireReq <= 1'b1;
        next_i <= 5'h0;
      end
    end
    `STX_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)
      begin
        NextState_SIETx <= `STX_CHK_ST;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `DIR_CTL_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      next_i <= i + 1'b1;
      if (i == 5'h7)
      begin
        NextState_SIETx <= `STX_WAIT_BYTE;
        next_USBWireReq <= 1'b0;
      end
      else
      begin
        NextState_SIETx <= `DIR_CTL_WAIT_RDY;
      end
    end
    `DIR_CTL_WAIT_GNT:
    begin
      next_i <= 5'h0;
      if (USBWireGnt == 1'b1)
      begin
        NextState_SIETx <= `DIR_CTL_WAIT_RDY;
      end
    end
    `DIR_CTL_WAIT_RDY:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `DIR_CTL_CHK_FIN;
        next_USBWireData <= SIEPortData[1:0];
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `IDLE_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      next_i <= i + 1'b1;
      if (i == 5'h7)
      begin
        NextState_SIETx <= `STX_WAIT_BYTE;
        next_USBWireReq <= 1'b0;
      end
      else
      begin
        NextState_SIETx <= `IDLE_STX_WAIT_RDY;
      end
    end
    `IDLE_STX_WAIT_GNT:
    begin
      next_i <= 5'h0;
      if (USBWireGnt == 1'b1)
      begin
        NextState_SIETx <= `IDLE_STX_WAIT_RDY;
      end
    end
    `IDLE_STX_WAIT_RDY:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `IDLE_CHK_FIN;
        next_USBWireData <= 2'b00;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `PKT_ST_CHK_PID:
    begin
      next_processTxByteWEn <= 1'b0;
      if (SIEPortData[1:0] == `HANDSHAKE)
      begin
        NextState_SIETx <= `PKT_ST_HS_WAIT_RDY;
      end
      else if (SIEPortData[1:0] == `TOKEN)
      begin
        NextState_SIETx <= `PKT_ST_TKN_PID_WAIT_RDY;
      end
      else if (SIEPortData[1:0] == `SPECIAL)
      begin
        NextState_SIETx <= `PKT_ST_SPCL_WAIT_RDY;
      end
      else if (SIEPortData[1:0] == `DATA)
      begin
        NextState_SIETx <= `PKT_ST_DATA_PID_WAIT_RDY;
      end
    end
    `PKT_ST_WAIT_RDY_PKT:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_CHK_PID;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= `SYNC_BYTE;
        next_TxByteOutCtrl <= `DATA_START;
      end
    end
    `PKT_ST_WAIT_RDY_WIRE:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_WAIT_RDY_PKT;
        //actively drive the first J bit
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `PKT_ST_WAIT_GNT:
    begin
      if (USBWireGnt == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_WAIT_RDY_WIRE;
      end
    end
    `PKT_ST_DATA_CRC_PKT_SENT1:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_CRC_WAIT_RDY2;
    end
    `PKT_ST_DATA_CRC_PKT_SENT2:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_DATA_CRC_WAIT_RDY1:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_CRC_PKT_SENT1;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= ~CRC16Result[7:0];
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    end
    `PKT_ST_DATA_CRC_WAIT_RDY2:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_CRC_PKT_SENT2;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= ~CRC16Result[15:8];
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    end
    `PKT_ST_DATA_DATA_CHK_STOP:
    begin
      if (SIEPortCtrl == `TX_PACKET_STOP)
      begin
        NextState_SIETx <= `PKT_ST_DATA_CRC_WAIT_RDY1;
      end
      else
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_CRC_RDY;
      end
    end
    `PKT_ST_DATA_DATA_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_BYTE;
    end
    `PKT_ST_DATA_DATA_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC16En <= 1'b1;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_RDY;
    end
    `PKT_ST_DATA_DATA_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_CHK_STOP;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_DATA_DATA_WAIT_RDY:
    begin
      next_CRC16En <= 1'b0;
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    end
    `PKT_ST_DATA_DATA_WAIT_CRC_RDY:
    begin
      if (CRC16UpdateRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_DATA_UPD_CRC;
      end
    end
    `PKT_ST_DATA_PID_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      NextState_SIETx <= `PKT_ST_DATA_DATA_WAIT_BYTE;
    end
    `PKT_ST_DATA_PID_WAIT_RDY:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_DATA_PID_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
        next_rstCRC <= 1'b1;
      end
    end
    `PKT_ST_HS_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_HS_WAIT_RDY:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_HS_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    end
    `PKT_ST_SPCL_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_SPCL_WAIT_WIRE;
    end
    `PKT_ST_SPCL_SEND_IDLE1:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_SPCL_SEND_IDLE2;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `PKT_ST_SPCL_SEND_IDLE2:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_SPCL_SEND_IDLE3;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `PKT_ST_SPCL_SEND_IDLE3:
    begin
      next_USBWireWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_SPCL_WAIT_RDY:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_SPCL_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    end
    `PKT_ST_SPCL_WAIT_WIRE:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_SPCL_SEND_IDLE1;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `PKT_ST_TKN_BYTE1_PKT_SENT1:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_BYTE;
    end
    `PKT_ST_TKN_BYTE1_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC5_8Bit <= 1'b1;
      next_CRC5En <= 1'b1;
      NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_RDY;
    end
    `PKT_ST_TKN_BYTE1_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_CRC_RDY;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_TKN_BYTE1_WAIT_RDY:
    begin
      next_CRC5En <= 1'b0;
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_PKT_SENT1;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
      end
    end
    `PKT_ST_TKN_BYTE1_WAIT_CRC_RDY:
    begin
      if (CRC5UpdateRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_BYTE1_UPD_CRC;
      end
    end
    `PKT_ST_TKN_CRC_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `PKT_ST_TKN_CRC_UPD_CRC:
    begin
      next_CRCData <= SIEPortData;
      next_CRC5_8Bit <= 1'b0;
      next_CRC5En <= 1'b1;
      NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_RDY;
    end
    `PKT_ST_TKN_CRC_WAIT_BYTE:
    begin
      next_SIEPortTxRdy <= 1'b1;
      if (SIEPortWEn == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_CRC_WAIT_CRC_RDY;
        next_SIEPortData <= SIEPortDataIn;
        next_SIEPortCtrl <= SIEPortCtrlIn;
        next_SIEPortTxRdy <= 1'b0;
      end
    end
    `PKT_ST_TKN_CRC_WAIT_RDY:
    begin
      next_CRC5En <= 1'b0;
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_CRC_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= {~CRC5Result, SIEPortData[2:0] };
        next_TxByteOutCtrl <= `DATA_STOP;
      end
    end
    `PKT_ST_TKN_CRC_WAIT_CRC_RDY:
    begin
      if (CRC5UpdateRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_CRC_UPD_CRC;
      end
    end
    `PKT_ST_TKN_PID_PKT_SENT:
    begin
      next_processTxByteWEn <= 1'b0;
      next_rstCRC <= 1'b0;
      NextState_SIETx <= `PKT_ST_TKN_BYTE1_WAIT_BYTE;
    end
    `PKT_ST_TKN_PID_WAIT_RDY:
    begin
      if (processTxByteRdy == 1'b1)
      begin
        NextState_SIETx <= `PKT_ST_TKN_PID_PKT_SENT;
        next_processTxByteWEn <= 1'b1;
        next_TxByteOut <= SIEPortData;
        next_TxByteOutCtrl <= `DATA_STREAM;
        next_rstCRC <= 1'b1;
      end
    end
    `RES_ST_CHK_FIN:
    begin
      next_USBWireWEn <= 1'b0;
      if (i == `RESUME_LEN)
      begin
        NextState_SIETx <= `RES_ST_S1;
      end
      else
      begin
        NextState_SIETx <= `RES_ST_WAIT_RDY;
      end
    end
    `RES_ST_S1:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_S3;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `RES_ST_S3:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_S4;
        next_USBWireData <= `SE0;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `RES_ST_S4:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_S5;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `RES_ST_S5:
    begin
      next_USBWireWEn <= 1'b0;
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_S6;
        next_USBWireData <= JBit;
        next_USBWireCtrl <= `TRI_STATE;
        next_USBWireWEn <= 1'b1;
      end
    end
    `RES_ST_S6:
    begin
      next_USBWireWEn <= 1'b0;
      next_USBWireReq <= 1'b0;
      NextState_SIETx <= `STX_WAIT_BYTE;
    end
    `RES_ST_WAIT_GNT:
    begin
      if (USBWireGnt == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_WAIT_RDY;
      end
    end
    `RES_ST_WAIT_RDY:
    begin
      if (USBWireRdy == 1'b1)
      begin
        NextState_SIETx <= `RES_ST_CHK_FIN;
        next_USBWireData <= KBit;
        next_USBWireCtrl <= `DRIVE;
        next_USBWireWEn <= 1'b1;
        next_i <= i + 1'b1;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_SIETx <= `START_SIETX;
  else
    CurrState_SIETx <= NextState_SIETx;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    USBWireWEn <= 1'b0;
    USBWireReq <= 1'b0;
    processTxByteWEn <= 1'b0;
    rstCRC <= 1'b0;
    USBWireData <= 2'b00;
    USBWireCtrl <= `TRI_STATE;
    TxByteOut <= 8'h00;
    TxByteOutCtrl <= 8'h00;
    CRCData <= 8'h00;
    CRC5En <= 1'b0;
    CRC5_8Bit <= 1'b0;
    CRC16En <= 1'b0;
    SIEPortTxRdy <= 1'b0;
    i <= 5'h0;
    SIEPortData <= 8'h00;
    SIEPortCtrl <= 8'h00;
  end
  else 
  begin
    USBWireWEn <= next_USBWireWEn;
    USBWireReq <= next_USBWireReq;
    processTxByteWEn <= next_processTxByteWEn;
    rstCRC <= next_rstCRC;
    USBWireData <= next_USBWireData;
    USBWireCtrl <= next_USBWireCtrl;
    TxByteOut <= next_TxByteOut;
    TxByteOutCtrl <= next_TxByteOutCtrl;
    CRCData <= next_CRCData;
    CRC5En <= next_CRC5En;
    CRC5_8Bit <= next_CRC5_8Bit;
    CRC16En <= next_CRC16En;
    SIEPortTxRdy <= next_SIEPortTxRdy;
    i <= next_i;
    SIEPortData <= next_SIEPortData;
    SIEPortCtrl <= next_SIEPortCtrl;
  end
end

endmodule