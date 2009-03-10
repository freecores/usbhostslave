//////////////////////////////////////////////////////////////////////
////                                                              ////
//// fifoMem.v                                                    ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
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
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: fifoMem.v,v 1.1.1.1 2004-10-11 04:00:51 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`timescale 1ns / 1ps

module fifoMem(	addrIn, addrOut, clk, dataIn, writeEn, readEn, dataOut);
  //FIFO_DEPTH = ADDR_WIDTH^2
  parameter FIFO_WIDTH = 8;
	parameter FIFO_DEPTH = 64; 
  parameter ADDR_WIDTH = 6;   
  
input clk;
input [FIFO_WIDTH-1:0] dataIn;
output [FIFO_WIDTH-1:0] dataOut;
input writeEn;
input readEn;
input [ADDR_WIDTH-1:0] addrIn;
input [ADDR_WIDTH-1:0] addrOut;

wire clk;
wire [FIFO_WIDTH-1:0] dataIn;
wire [FIFO_WIDTH-1:0] dataOut;
wire writeEn;
wire readEn;
wire [ADDR_WIDTH-1:0] addrIn;
wire [ADDR_WIDTH-1:0] addrOut;


/* generic_dpram #(ADDR_WIDTH, FIFO_WIDTH) u_generic_dpram(
	// Generic synchronous dual-port RAM interface
	.rclk(clk), 
  .rrst(1'b0), 
  .rce(1'b1), 
  .oe(readEn), 
  .raddr(addrOut), 
  .do(dataOut),
	.wclk(clk), 
  .wrst(1'b0), 
  .wce(1'b1),
  .we(writeEn), 
  .waddr(addrIn), 
  .di(dataIn)
); */


 simFifoMem #(FIFO_WIDTH, FIFO_DEPTH, ADDR_WIDTH)  u_simFifoMem (
	.addrIn(addrIn),
	.addrOut(addrOut),
	.clk(clk),
	.dataIn(dataIn),
	.writeEn(writeEn),
	.readEn(readEn),
	.dataOut(dataOut));  

endmodule