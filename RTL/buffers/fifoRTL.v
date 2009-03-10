//////////////////////////////////////////////////////////////////////
////                                                              ////
//// fifoRTL.v                                                    ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////  parameterized fifo. fifo depth is restricted to 2^ADDR_WIDTH
////  No protection against over runs and under runs.
////  User must check full and empty flags before accessing fifo
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
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: fifoRTL.v,v 1.1.1.1 2004-10-11 04:00:51 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`timescale 1ns / 1ps

module fifoRTL(clk, rst, dataIn, dataOut, fifoWEn, fifoREn, fifoFull, fifoEmpty, forceEmpty, numElementsInFifo);
//FIFO_DEPTH = ADDR_WIDTH^2. Min = 2, Max = 66536
  parameter FIFO_WIDTH = 8;
	parameter FIFO_DEPTH = 64; 
  parameter ADDR_WIDTH = 6;   
  
input clk;
input rst;
input [FIFO_WIDTH-1:0] dataIn;
output [FIFO_WIDTH-1:0] dataOut;
input fifoWEn;
input fifoREn;
output fifoFull;
output fifoEmpty;
input forceEmpty;
output [15:0]numElementsInFifo; //note that this implies a max fifo depth of 65536

wire clk;
wire rst;
wire [FIFO_WIDTH-1:0] dataIn;
reg [FIFO_WIDTH-1:0] dataOut;
wire fifoWEn;
wire fifoREn;
reg fifoFull;
reg fifoEmpty;
wire forceEmpty;
reg  [15:0]numElementsInFifo;


// local registers
reg  [ADDR_WIDTH-1:0]bufferInIndex;
reg  [ADDR_WIDTH-1:0]bufferOutIndex;
reg  [ADDR_WIDTH:0]bufferCnt;
reg  fifoREnDelayed;
wire [FIFO_WIDTH-1:0] dataFromMem;

always @(posedge clk)
begin
  if (rst == 1'b1 || forceEmpty == 1'b1)
  begin
    bufferCnt <= 0;
    fifoFull <= 1'b0;
    fifoEmpty <= 1'b1;
		bufferInIndex <= 0;
		bufferOutIndex <= 0;
    fifoREnDelayed <= 1'b0;
	end
    else
    begin
      if (fifoREn == 1'b1 && fifoREnDelayed == 1'b0) begin
        dataOut <= dataFromMem;
      end
      fifoREnDelayed <= fifoREn;
      if (fifoWEn == 1'b1 && fifoREn == 1'b0) begin
        bufferCnt <= bufferCnt + 1;
        bufferInIndex <= bufferInIndex + 1;
      end 
      else if (fifoWEn == 1'b0 && fifoREn == 1'b1 && fifoREnDelayed == 1'b0) begin
        bufferCnt <= bufferCnt - 1;
        bufferOutIndex <= bufferOutIndex + 1;
      end
      else if (fifoWEn == 1'b1 && fifoREn == 1'b1 && fifoREnDelayed == 1'b0) begin
        bufferOutIndex <= bufferOutIndex + 1;
        bufferInIndex <= bufferInIndex + 1;
      end
      if (bufferCnt[ADDR_WIDTH] == 1'b1)
        fifoFull <= 1'b1;
      else
        fifoFull <= 1'b0;
      if (|bufferCnt == 1'b0) 
        fifoEmpty <= 1'b1;
      else
        fifoEmpty <= 1'b0;
    end
end

//pad bufferCnt with leading zeroes
always @(bufferCnt) begin
  numElementsInFifo <= { {16-ADDR_WIDTH+1{1'b0}}, bufferCnt };
end

fifoMem #(FIFO_WIDTH, FIFO_DEPTH, ADDR_WIDTH)  u_fifoMem (
	.addrIn(bufferInIndex),
	.addrOut(bufferOutIndex),
	.clk(clk),
	.dataIn(dataIn),
	.writeEn(fifoWEn),
	.readEn(fifoREn),
	.dataOut(dataFromMem));

endmodule