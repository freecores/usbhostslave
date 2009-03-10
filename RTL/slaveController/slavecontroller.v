
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveController
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
`include "usbSlaveControl_h.v"
`include "usbConstants_h.v"


module slavecontroller (bitStuffError, clk, clrEPRdy, CRCError, endPMuxErrorsWEn, frameNum, getPacketRdy, getPacketREn, NAKSent, rst, RxByte, RxDataWEn, RxOverflow, RxStatus, RxTimeOut, SCGlobalEn, sendPacketPID, sendPacketRdy, sendPacketWEn, SOFRxed, stallSent, transDone, USBEndP, USBEndPControlReg, USBEndPNakTransTypeReg, USBEndPTransTypeReg, USBTgtAddress);
input   bitStuffError;
input   clk;
input   CRCError;
input   getPacketRdy;
input   rst;
input   [7:0]RxByte;
input   RxDataWEn;
input   RxOverflow;
input   [7:0]RxStatus;
input   RxTimeOut;
input   SCGlobalEn;
input   sendPacketRdy;
input   [3:0]USBEndPControlReg;
input   [6:0]USBTgtAddress;
output  clrEPRdy;
output  endPMuxErrorsWEn;
output  [10:0]frameNum;
output  getPacketREn;
output  NAKSent;
output  [3:0]sendPacketPID;
output  sendPacketWEn;
output  SOFRxed;
output  stallSent;
output  transDone;
output  [3:0]USBEndP;
output  [1:0]USBEndPNakTransTypeReg;
output  [1:0]USBEndPTransTypeReg;

wire    bitStuffError;
wire    clk;
reg     clrEPRdy, next_clrEPRdy;
wire    CRCError;
reg     endPMuxErrorsWEn, next_endPMuxErrorsWEn;
reg     [10:0]frameNum, next_frameNum;
wire    getPacketRdy;
reg     getPacketREn, next_getPacketREn;
reg     NAKSent, next_NAKSent;
wire    rst;
wire    [7:0]RxByte;
wire    RxDataWEn;
wire    RxOverflow;
wire    [7:0]RxStatus;
wire    RxTimeOut;
wire    SCGlobalEn;
reg     [3:0]sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;
reg     SOFRxed, next_SOFRxed;
reg     stallSent, next_stallSent;
reg     transDone, next_transDone;
reg     [3:0]USBEndP, next_USBEndP;
wire    [3:0]USBEndPControlReg;
reg     [1:0]USBEndPNakTransTypeReg, next_USBEndPNakTransTypeReg;
reg     [1:0]USBEndPTransTypeReg, next_USBEndPTransTypeReg;
wire    [6:0]USBTgtAddress;

// diagram signals declarations
reg  [7:0]addrEndPTemp, next_addrEndPTemp;
reg  [7:0]endpCRCTemp, next_endpCRCTemp;
reg  [7:0]PIDByte, next_PIDByte;
reg  [1:0]tempUSBEndPTransTypeReg, next_tempUSBEndPTransTypeReg;
reg  [6:0]USBAddress, next_USBAddress;

// BINARY ENCODED state machine: slvCntrl
// State codes definitions:
`define WAIT_RX1 5'b00000
`define FIN_SC 5'b00001
`define GET_TOKEN_WAIT_CRC 5'b00010
`define GET_TOKEN_WAIT_ADDR 5'b00011
`define GET_TOKEN_WAIT_STOP 5'b00100
`define CHK_PID 5'b00101
`define GET_TOKEN_CHK_SOF 5'b00110
`define PID_ERROR 5'b00111
`define CHK_RDY 5'b01000
`define IN_NAK_STALL 5'b01001
`define IN_CHK_RDY 5'b01010
`define IN_DATA 5'b01011
`define IN_GET_RESP 5'b01100
`define SETUP_OUT_CHK 5'b01101
`define SETUP_OUT_SEND 5'b01110
`define SETUP_OUT_GET_PKT 5'b01111
`define START_S1 5'b10000
`define GET_TOKEN_DELAY 5'b10001
`define GET_TOKEN_CHK_ADDR 5'b10010

reg [4:0]CurrState_slvCntrl, NextState_slvCntrl;


// Machine: slvCntrl

// NextState logic (combinatorial)
always @ (RxDataWEn or RxStatus or CRCError or bitStuffError or RxOverflow or RxTimeOut or RxByte or PIDByte or endpCRCTemp or addrEndPTemp or USBEndPControlReg or tempUSBEndPTransTypeReg or NAKSent or sendPacketRdy or getPacketRdy or USBEndP or USBAddress or USBTgtAddress or SCGlobalEn or stallSent or SOFRxed or transDone or clrEPRdy or endPMuxErrorsWEn or frameNum or USBEndPTransTypeReg or USBEndPNakTransTypeReg or sendPacketWEn or sendPacketPID or getPacketREn or CurrState_slvCntrl)
begin
  NextState_slvCntrl <= CurrState_slvCntrl;
  // Set default values for outputs and signals
  next_stallSent <= stallSent;
  next_NAKSent <= NAKSent;
  next_SOFRxed <= SOFRxed;
  next_PIDByte <= PIDByte;
  next_transDone <= transDone;
  next_clrEPRdy <= clrEPRdy;
  next_endPMuxErrorsWEn <= endPMuxErrorsWEn;
  next_endpCRCTemp <= endpCRCTemp;
  next_addrEndPTemp <= addrEndPTemp;
  next_tempUSBEndPTransTypeReg <= tempUSBEndPTransTypeReg;
  next_frameNum <= frameNum;
  next_USBAddress <= USBAddress;
  next_USBEndP <= USBEndP;
  next_USBEndPTransTypeReg <= USBEndPTransTypeReg;
  next_USBEndPNakTransTypeReg <= USBEndPNakTransTypeReg;
  next_sendPacketWEn <= sendPacketWEn;
  next_sendPacketPID <= sendPacketPID;
  next_getPacketREn <= getPacketREn;
  case (CurrState_slvCntrl)  // synopsys parallel_case full_case
    `WAIT_RX1:
    begin
      next_stallSent <= 1'b0;
      next_NAKSent <= 1'b0;
      next_SOFRxed <= 1'b0;
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_START && 
        RxByte[1:0] == `TOKEN)
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_ADDR;
        next_PIDByte <= RxByte;
      end
    end
    `FIN_SC:
    begin
      next_transDone <= 1'b0;
      next_clrEPRdy <= 1'b0;
      next_endPMuxErrorsWEn <= 1'b0;
      NextState_slvCntrl <= `WAIT_RX1;
    end
    `CHK_PID:
    begin
      if (PIDByte[3:0] == `SETUP)
      begin
        NextState_slvCntrl <= `SETUP_OUT_GET_PKT;
        next_tempUSBEndPTransTypeReg <= `SC_SETUP_TRANS;
        next_getPacketREn <= 1'b1;
      end
      else if (PIDByte[3:0] == `OUT)
      begin
        NextState_slvCntrl <= `SETUP_OUT_GET_PKT;
        next_tempUSBEndPTransTypeReg <= `SC_OUTDATA_TRANS;
        next_getPacketREn <= 1'b1;
      end
      else if (PIDByte[3:0] == `IN)
      begin
        NextState_slvCntrl <= `IN_CHK_RDY;
        next_tempUSBEndPTransTypeReg <= `SC_IN_TRANS;
      end
      else
      begin
        NextState_slvCntrl <= `PID_ERROR;
      end
    end
    `PID_ERROR:
    begin
      NextState_slvCntrl <= `WAIT_RX1;
    end
    `CHK_RDY:
    begin
      if (USBEndPControlReg [`ENDPOINT_READY_BIT] == 1'b1)
      begin
        NextState_slvCntrl <= `FIN_SC;
        next_transDone <= 1'b1;
        next_clrEPRdy <= 1'b1;
        next_USBEndPTransTypeReg <= tempUSBEndPTransTypeReg;
        next_endPMuxErrorsWEn <= 1'b1;
      end
      else if (NAKSent == 1'b1)
      begin
        NextState_slvCntrl <= `FIN_SC;
        next_USBEndPNakTransTypeReg <= tempUSBEndPTransTypeReg;
        next_endPMuxErrorsWEn <= 1'b1;
      end
      else
      begin
        NextState_slvCntrl <= `FIN_SC;
      end
    end
    `SETUP_OUT_CHK:
    begin
      if (USBEndPControlReg [`ENDPOINT_READY_BIT] == 1'b0)
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `NAK;
        next_NAKSent <= 1'b1;
      end
      else if (USBEndPControlReg [`ENDPOINT_SEND_STALL_BIT] == 1'b1)
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `STALL;
        next_stallSent <= 1'b1;
      end
      else
      begin
        NextState_slvCntrl <= `SETUP_OUT_SEND;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `ACK;
      end
    end
    `SETUP_OUT_SEND:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)
      begin
        NextState_slvCntrl <= `CHK_RDY;
      end
    end
    `SETUP_OUT_GET_PKT:
    begin
      next_getPacketREn <= 1'b0;
      if ((getPacketRdy == 1'b1) && (CRCError == 1'b0 &&
        bitStuffError == 1'b0 && 
        RxOverflow == 1'b0 && 
        RxTimeOut == 1'b0))
      begin
        NextState_slvCntrl <= `SETUP_OUT_CHK;
      end
      else if (getPacketRdy == 1'b1)
      begin
        NextState_slvCntrl <= `CHK_RDY;
      end
    end
    `IN_NAK_STALL:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)
      begin
        NextState_slvCntrl <= `CHK_RDY;
      end
    end
    `IN_CHK_RDY:
    begin
      if (USBEndPControlReg [`ENDPOINT_READY_BIT] == 1'b0)
      begin
        NextState_slvCntrl <= `IN_NAK_STALL;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `NAK;
        next_NAKSent <= 1'b1;
      end
      else if (USBEndPControlReg [`ENDPOINT_SEND_STALL_BIT] == 1'b1)
      begin
        NextState_slvCntrl <= `IN_NAK_STALL;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `STALL;
        next_stallSent <= 1'b1;
      end
      else if (USBEndPControlReg [`ENDPOINT_OUTDATA_SEQUENCE_BIT] == 1'b0)
      begin
        NextState_slvCntrl <= `IN_DATA;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA0;
      end
      else
      begin
        NextState_slvCntrl <= `IN_DATA;
        next_sendPacketWEn <= 1'b1;
        next_sendPacketPID <= `DATA1;
      end
    end
    `IN_DATA:
    begin
      next_sendPacketWEn <= 1'b0;
      if (sendPacketRdy == 1'b1)
      begin
        NextState_slvCntrl <= `IN_GET_RESP;
        next_getPacketREn <= 1'b1;
      end
    end
    `IN_GET_RESP:
    begin
      next_getPacketREn <= 1'b0;
      if (getPacketRdy == 1'b1)
      begin
        NextState_slvCntrl <= `CHK_RDY;
      end
    end
    `START_S1:
    begin
      NextState_slvCntrl <= `WAIT_RX1;
    end
    `GET_TOKEN_WAIT_CRC:
    begin
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_STREAM)
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_STOP;
        next_endpCRCTemp <= RxByte;
      end
      else if (RxDataWEn == 1'b1 && 
        RxStatus != `RX_PACKET_STREAM)
      begin
        NextState_slvCntrl <= `WAIT_RX1;
      end
    end
    `GET_TOKEN_WAIT_ADDR:
    begin
      if (RxDataWEn == 1'b1 && 
        RxStatus == `RX_PACKET_STREAM)
      begin
        NextState_slvCntrl <= `GET_TOKEN_WAIT_CRC;
        next_addrEndPTemp <= RxByte;
      end
      else if (RxDataWEn == 1'b1 && 
        RxStatus != `RX_PACKET_STREAM)
      begin
        NextState_slvCntrl <= `WAIT_RX1;
      end
    end
    `GET_TOKEN_WAIT_STOP:
    begin
      if ((RxDataWEn == 1'b1) && (RxByte[`CRC_ERROR_BIT] == 1'b0 &&
        RxByte[`BIT_STUFF_ERROR_BIT] == 1'b0 &&
        RxByte [`RX_OVERFLOW_BIT] == 1'b0))
      begin
        NextState_slvCntrl <= `GET_TOKEN_CHK_SOF;
      end
      else if (RxDataWEn == 1'b1)
      begin
        NextState_slvCntrl <= `WAIT_RX1;
      end
    end
    `GET_TOKEN_CHK_SOF:
    begin
      if (PIDByte[3:0] == `SOF)
      begin
        NextState_slvCntrl <= `WAIT_RX1;
        next_frameNum <= {endpCRCTemp[2:0],addrEndPTemp};
        next_SOFRxed <= 1'b1;
      end
      else
      begin
        NextState_slvCntrl <= `GET_TOKEN_DELAY;
        next_USBAddress <= addrEndPTemp[6:0];
        next_USBEndP <= { endpCRCTemp[2:0], addrEndPTemp[7]};
      end
    end
    `GET_TOKEN_DELAY:    // Insert delay to allow USBEndPControlReg to update
    begin
      NextState_slvCntrl <= `GET_TOKEN_CHK_ADDR;
    end
    `GET_TOKEN_CHK_ADDR:
    begin
      if (USBEndP < `NUM_OF_ENDPOINTS  &&
        USBAddress == USBTgtAddress &&
        SCGlobalEn == 1'b1 &&
        USBEndPControlReg[`ENDPOINT_ENABLE_BIT] == 1'b1)
      begin
        NextState_slvCntrl <= `CHK_PID;
      end
      else
      begin
        NextState_slvCntrl <= `WAIT_RX1;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_slvCntrl <= `START_S1;
  else
    CurrState_slvCntrl <= NextState_slvCntrl;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    stallSent <= 1'b0;
    NAKSent <= 1'b0;
    SOFRxed <= 1'b0;
    transDone <= 1'b0;
    clrEPRdy <= 1'b0;
    endPMuxErrorsWEn <= 1'b0;
    frameNum <= 11'b00000000000;
    USBEndP <= 4'h0;
    USBEndPTransTypeReg <= 2'b00;
    USBEndPNakTransTypeReg <= 2'b00;
    sendPacketWEn <= 1'b0;
    sendPacketPID <= 4'b0;
    getPacketREn <= 1'b0;
    PIDByte <= 8'h00;
    endpCRCTemp <= 8'h00;
    addrEndPTemp <= 8'h00;
    tempUSBEndPTransTypeReg <= 2'b00;
    USBAddress <= 7'b0000000;
  end
  else 
  begin
    stallSent <= next_stallSent;
    NAKSent <= next_NAKSent;
    SOFRxed <= next_SOFRxed;
    transDone <= next_transDone;
    clrEPRdy <= next_clrEPRdy;
    endPMuxErrorsWEn <= next_endPMuxErrorsWEn;
    frameNum <= next_frameNum;
    USBEndP <= next_USBEndP;
    USBEndPTransTypeReg <= next_USBEndPTransTypeReg;
    USBEndPNakTransTypeReg <= next_USBEndPNakTransTypeReg;
    sendPacketWEn <= next_sendPacketWEn;
    sendPacketPID <= next_sendPacketPID;
    getPacketREn <= next_getPacketREn;
    PIDByte <= next_PIDByte;
    endpCRCTemp <= next_endpCRCTemp;
    addrEndPTemp <= next_addrEndPTemp;
    tempUSBEndPTransTypeReg <= next_tempUSBEndPTransTypeReg;
    USBAddress <= next_USBAddress;
  end
end

endmodule