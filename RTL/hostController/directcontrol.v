
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// directControl
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
// $Id: directcontrol.v,v 1.3 2004-12-31 14:40:41 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"

module directControl (clk, directControlEn, directControlLineState, HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, rst);
input   clk;
input   directControlEn;
input   [1:0]directControlLineState;
input   HCTxPortGnt;
input   HCTxPortRdy;
input   rst;
output  [7:0]HCTxPortCntl;
output  [7:0]HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;

wire    clk;
wire    directControlEn;
wire    [1:0]directControlLineState;
reg     [7:0]HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0]HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    rst;

// BINARY ENCODED state machine: drctCntl
// State codes definitions:
`define START_DC 3'b000
`define CHK_DRCT_CNTL 3'b001
`define DRCT_CNTL_WAIT_GNT 3'b010
`define DRCT_CNTL_CHK_LOOP 3'b011
`define DRCT_CNTL_WAIT_RDY 3'b100
`define IDLE_FIN 3'b101
`define IDLE_WAIT_GNT 3'b110
`define IDLE_WAIT_RDY 3'b111

reg [2:0]CurrState_drctCntl, NextState_drctCntl;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


// Machine: drctCntl

// NextState logic (combinatorial)
always @ (directControlEn or HCTxPortGnt or HCTxPortRdy or directControlLineState or HCTxPortCntl or HCTxPortData or HCTxPortWEn or HCTxPortReq or CurrState_drctCntl)
begin
  NextState_drctCntl <= CurrState_drctCntl;
  // Set default values for outputs and signals
  next_HCTxPortCntl <= HCTxPortCntl;
  next_HCTxPortData <= HCTxPortData;
  next_HCTxPortWEn <= HCTxPortWEn;
  next_HCTxPortReq <= HCTxPortReq;
  case (CurrState_drctCntl)  // synopsys parallel_case full_case
    `START_DC:
    begin
      NextState_drctCntl <= `CHK_DRCT_CNTL;
    end
    `CHK_DRCT_CNTL:
    begin
      if (directControlEn == 1'b1)
      begin
        NextState_drctCntl <= `DRCT_CNTL_WAIT_GNT;
        next_HCTxPortReq <= 1'b1;
      end
      else
      begin
        NextState_drctCntl <= `IDLE_WAIT_GNT;
        next_HCTxPortReq <= 1'b1;
      end
    end
    `DRCT_CNTL_WAIT_GNT:
    begin
      if (HCTxPortGnt == 1'b1)
      begin
        NextState_drctCntl <= `DRCT_CNTL_WAIT_RDY;
      end
    end
    `DRCT_CNTL_CHK_LOOP:
    begin
      next_HCTxPortWEn <= 1'b0;
      if (directControlEn == 1'b0)
      begin
        NextState_drctCntl <= `CHK_DRCT_CNTL;
        next_HCTxPortReq <= 1'b0;
      end
      else
      begin
        NextState_drctCntl <= `DRCT_CNTL_WAIT_RDY;
      end
    end
    `DRCT_CNTL_WAIT_RDY:
    begin
      if (HCTxPortRdy == 1'b1)
      begin
        NextState_drctCntl <= `DRCT_CNTL_CHK_LOOP;
        next_HCTxPortWEn <= 1'b1;
        next_HCTxPortData <= {6'b000000, directControlLineState};
        next_HCTxPortCntl <= `TX_DIRECT_CONTROL;
      end
    end
    `IDLE_FIN:
    begin
      next_HCTxPortWEn <= 1'b0;
      next_HCTxPortReq <= 1'b0;
      NextState_drctCntl <= `CHK_DRCT_CNTL;
    end
    `IDLE_WAIT_GNT:
    begin
      if (HCTxPortGnt == 1'b1)
      begin
        NextState_drctCntl <= `IDLE_WAIT_RDY;
      end
    end
    `IDLE_WAIT_RDY:
    begin
      if (HCTxPortRdy == 1'b1)
      begin
        NextState_drctCntl <= `IDLE_FIN;
        next_HCTxPortWEn <= 1'b1;
        next_HCTxPortData <= 8'h00;
        next_HCTxPortCntl <= `TX_IDLE;
      end
    end
  endcase
end

// Current State Logic (sequential)
always @ (posedge clk)
begin
  if (rst)
    CurrState_drctCntl <= `START_DC;
  else
    CurrState_drctCntl <= NextState_drctCntl;
end

// Registered outputs logic
always @ (posedge clk)
begin
  if (rst)
  begin
    HCTxPortCntl <= 8'h00;
    HCTxPortData <= 8'h00;
    HCTxPortWEn <= 1'b0;
    HCTxPortReq <= 1'b0;
  end
  else 
  begin
    HCTxPortCntl <= next_HCTxPortCntl;
    HCTxPortData <= next_HCTxPortData;
    HCTxPortWEn <= next_HCTxPortWEn;
    HCTxPortReq <= next_HCTxPortReq;
  end
end

endmodule