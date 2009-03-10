
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// slaveDirectControl
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

module slaveDirectControl (clk, directControlEn, directControlLineState, rst, SCTxPortCntl, SCTxPortData, SCTxPortGnt, SCTxPortRdy, SCTxPortReq, SCTxPortWEn);
input   clk;
input   directControlEn;
input   [1:0]directControlLineState;
input   rst;
input   SCTxPortGnt;
input   SCTxPortRdy;
output  [7:0]SCTxPortCntl;
output  [7:0]SCTxPortData;
output  SCTxPortReq;
output  SCTxPortWEn;

wire    clk;
wire    directControlEn;
wire    [1:0]directControlLineState;
wire    rst;
reg     [7:0]SCTxPortCntl, next_SCTxPortCntl;
reg     [7:0]SCTxPortData, next_SCTxPortData;
wire    SCTxPortGnt;
wire    SCTxPortRdy;
reg     SCTxPortReq, next_SCTxPortReq;
reg     SCTxPortWEn, next_SCTxPortWEn;

// BINARY ENCODED state machine: slvDrctCntl
// State codes definitions:
`define START_SDC 3'b000
`define CHK_DRCT_CNTL 3'b001
`define DRCT_CNTL_WAIT_GNT 3'b010
`define DRCT_CNTL_CHK_LOOP 3'b011
`define DRCT_CNTL_WAIT_RDY 3'b100
`define IDLE_FIN 3'b101
`define IDLE_WAIT_GNT 3'b110
`define IDLE_WAIT_RDY 3'b111

reg [2:0]CurrState_slvDrctCntl, NextState_slvDrctCntl;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


// Machine: slvDrctCntl

// NextState logic (combinatorial)
always @ (directControlEn or SCTxPortGnt or SCTxPortRdy or directControlLineState or SCTxPortCntl or SCTxPortData or SCTxPortWEn or SCTxPortReq or CurrState_slvDrctCntl)
begin
  NextState_slvDrctCntl <= CurrState_slvDrctCntl;
  // Set default values for outputs and signals
  next_SCTxPortCntl <= SCTxPortCntl;
  next_SCTxPortData <= SCTxPortData;
  next_SCTxPortWEn <= SCTxPortWEn;
  next_SCTxPortReq <= SCTxPortReq;
  case (CurrState_slvDrctCntl)  // synopsys parallel_case full_case
    `START_SDC:
    begin
      NextState_slvDrctCntl <= `CHK_DRCT_CNTL;
    end
    `CHK_DRCT_CNTL:
    begin
      if (directControlEn == 1'b1)
      begin
        NextState_slvDrctCntl <= `DRCT_CNTL_WAIT_GNT;
        next_SCTxPortReq <= 1'b1;
      end
      else
      begin
        NextState_slvDrctCntl <= `IDLE_WAIT_GNT;
        next_SCTxPortReq <= 1'b1;
      end
    end
    `DRCT_CNTL_WAIT_GNT:
    begin
      if (SCTxPortGnt == 1'b1)
      begin
        NextState_slvDrctCntl <= `DRCT_CNTL_WAIT_RDY;
      end
    end
    `DRCT_CNTL_CHK_LOOP:
    begin
      next_SCTxPortWEn <= 1'b0;
      if (directControlEn == 1'b0)
      begin
        NextState_slvDrctCntl <= `CHK_DRCT_CNTL;
        next_SCTxPortReq <= 1'b0;
      end
      else
      begin
        NextState_slvDrctCntl <= `DRCT_CNTL_WAIT_RDY;
      end
    end
    `DRCT_CNTL_WAIT_RDY:
    begin
      if (SCTxPortRdy == 1'b1)
      begin
        NextState_slvDrctCntl <= `DRCT_CNTL_CHK_LOOP;
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= {6'b000000, directControlLineState};
        next_SCTxPortCntl <= `TX_DIRECT_CONTROL;
      end
    end
    `IDLE_FIN:
    begin
      next_SCTxPortWEn <= 1'b0;
      next_SCTxPortReq <= 1'b0;
      NextState_slvDrctCntl <= `CHK_DRCT_CNTL;
    end
    `IDLE_WAIT_GNT:
    begin
      if (SCTxPortGnt == 1'b1)
      begin
        NextState_slvDrctCntl <= `IDLE_WAIT_RDY;
      end
    end
    `IDLE_WAIT_RDY:
    begin
      if (SCTxPortRdy == 1'b1)
      begin
        NextState_slvDrctCntl <= `IDLE_FIN;
        next_SCTxPortWEn <= 1'b1;
        next_SCTxPortData <= 8'h00;
        next_SCTxPortCntl <= `TX_IDLE;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_slvDrctCntl <= `START_SDC;
  else
    CurrState_slvDrctCntl <= NextState_slvDrctCntl;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    SCTxPortCntl <= 8'h00;
    SCTxPortData <= 8'h00;
    SCTxPortWEn <= 1'b0;
    SCTxPortReq <= 1'b0;
  end
  else 
  begin
    SCTxPortCntl <= next_SCTxPortCntl;
    SCTxPortData <= next_SCTxPortData;
    SCTxPortWEn <= next_SCTxPortWEn;
    SCTxPortReq <= next_SCTxPortReq;
  end
end

endmodule