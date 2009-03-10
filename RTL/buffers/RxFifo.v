//////////////////////////////////////////////////////////////////////
////                                                              ////
//// RxFifo.v                                                     ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////  parameterized RxFifo wrapper. Min depth = 2, Max depth = 65536
////  fifo read access via bus interface, fifo write access is direct
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
// $Id: RxFifo.v,v 1.1.1.1 2004-10-11 04:00:51 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`timescale 1ns / 1ps

module RxFifo(
  clk, 
  rst, 
  fifoWEn, 
  fifoFull,
  busAddress, 
  busWriteEn, 
  busStrobe_i,
  busFifoSelect,
  busDataIn, 
  busDataOut,
  fifoDataIn  );
  //FIFO_DEPTH = ADDR_WIDTH^2
	parameter FIFO_DEPTH = 64; 
  parameter ADDR_WIDTH = 6;   
  
input clk; 
input rst; 
input fifoWEn;
output fifoFull;
input [2:0] busAddress; 
input busWriteEn; 
input busStrobe_i;
input busFifoSelect;
input [7:0] busDataIn; 
output [7:0] busDataOut;
input [7:0] fifoDataIn;

wire clk; 
wire rst; 
wire fifoWEn; 
wire fifoFull;
wire [2:0] busAddress; 
wire busWriteEn; 
wire busStrobe_i;
wire busFifoSelect;
wire [7:0] busDataIn; 
wire [7:0] busDataOut;
wire [7:0] fifoDataIn;

//internal wires and regs
wire [7:0] dataFromFifoToBus;
wire fifoREn;
wire forceEmpty;
wire [15:0] numElementsInFifo;
wire fifoEmpty;

fifoRTL #(8, FIFO_DEPTH, ADDR_WIDTH) u_fifo(
  .clk(clk), 
  .rst(rst), 
  .dataIn(fifoDataIn), 
  .dataOut(dataFromFifoToBus), 
  .fifoWEn(fifoWEn), 
  .fifoREn(fifoREn), 
  .fifoFull(fifoFull), 
  .fifoEmpty(fifoEmpty), 
  .forceEmpty(forceEmpty), 
  .numElementsInFifo(numElementsInFifo) );
  
RxfifoBI u_RxfifoBI(
  .address(busAddress), 
  .writeEn(busWriteEn), 
  .strobe_i(busStrobe_i),
  .clk(clk), 
  .rst(rst), 
  .fifoSelect(busFifoSelect),
  .fifoDataIn(dataFromFifoToBus),
  .busDataIn(busDataIn), 
  .busDataOut(busDataOut),
  .fifoREn(fifoREn),
  .fifoEmpty(fifoEmpty),
  .forceEmpty(forceEmpty),
  .numElementsInFifo(numElementsInFifo)
  );

endmodule