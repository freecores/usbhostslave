
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sofcontroller
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

module SOFController (clk, HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, rst, SOFEnable, SOFTimer, SOFTimerClr);
input   clk;
input   HCTxPortGnt;
input   HCTxPortRdy;
input   rst;
input   SOFEnable;
input   SOFTimerClr;
output  [7:0]HCTxPortCntl;
output  [7:0]HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;
output  [15:0]SOFTimer;

wire    clk;
reg     [7:0]HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0]HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    rst;
wire    SOFEnable;
reg     [15:0]SOFTimer, next_SOFTimer;
wire    SOFTimerClr;

// BINARY ENCODED state machine: sofCntl
// State codes definitions:
`define START_SC 3'b000
`define WAIT_SOF_EN 3'b001
`define WAIT_SEND_RESUME 3'b010
`define INC_TIMER 3'b011
`define SC_WAIT_GNT 3'b100
`define CLR_WEN 3'b101

reg [2:0]CurrState_sofCntl, NextState_sofCntl;


// Machine: sofCntl

// NextState logic (combinatorial)
always @ (SOFTimerClr or SOFEnable or HCTxPortRdy or SOFTimer or HCTxPortGnt or HCTxPortCntl or HCTxPortData or HCTxPortWEn or HCTxPortReq or CurrState_sofCntl)
begin
  NextState_sofCntl <= CurrState_sofCntl;
  // Set default values for outputs and signals
  next_SOFTimer <= SOFTimer;
  next_HCTxPortCntl <= HCTxPortCntl;
  next_HCTxPortData <= HCTxPortData;
  next_HCTxPortWEn <= HCTxPortWEn;
  next_HCTxPortReq <= HCTxPortReq;
  case (CurrState_sofCntl)  // synopsys parallel_case full_case
    `START_SC:
    begin
      NextState_sofCntl <= `WAIT_SOF_EN;
    end
    `WAIT_SOF_EN:
    begin
      if (SOFEnable == 1'b1)
      begin
        NextState_sofCntl <= `SC_WAIT_GNT;
        next_HCTxPortReq <= 1'b1;
      end
    end
    `WAIT_SEND_RESUME:
    begin
      if (HCTxPortRdy == 1'b1)
      begin
        NextState_sofCntl <= `CLR_WEN;
        next_HCTxPortWEn <= 1'b1;
        next_HCTxPortData <= 8'h00;
        next_HCTxPortCntl <= `TX_RESUME_START;
      end
    end
    `INC_TIMER:
    begin
      next_HCTxPortReq <= 1'b0;
      if (SOFTimerClr == 1'b1)
      next_SOFTimer <= 16'h0000;
      else
      next_SOFTimer <= SOFTimer + 1'b1;
      if (SOFEnable == 1'b0)
      begin
        NextState_sofCntl <= `WAIT_SOF_EN;
        next_SOFTimer <= 16'h0000;
      end
    end
    `SC_WAIT_GNT:
    begin
      if (HCTxPortGnt == 1'b1)
      begin
        NextState_sofCntl <= `WAIT_SEND_RESUME;
      end
    end
    `CLR_WEN:
    begin
      next_HCTxPortWEn <= 1'b0;
      NextState_sofCntl <= `INC_TIMER;
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_sofCntl <= `START_SC;
  else
    CurrState_sofCntl <= NextState_sofCntl;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    SOFTimer <= 16'h0000;
    HCTxPortCntl <= 8'h00;
    HCTxPortData <= 8'h00;
    HCTxPortWEn <= 1'b0;
    HCTxPortReq <= 1'b0;
  end
  else 
  begin
    SOFTimer <= next_SOFTimer;
    HCTxPortCntl <= next_HCTxPortCntl;
    HCTxPortData <= next_HCTxPortData;
    HCTxPortWEn <= next_HCTxPortWEn;
    HCTxPortReq <= next_HCTxPortReq;
  end
end

endmodule