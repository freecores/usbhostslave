//////////////////////////////////////////////////////////////////////
////                                                              ////
//// RxfifoBI.v                                                   ////
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
// $Id: RxFifoBI.v,v 1.1.1.1 2004-10-11 04:00:51 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`include "wishBoneBus_h.v"

module RxfifoBI (
  address, 
  writeEn, 
  strobe_i,
  clk, 
  rst, 
  fifoSelect,
  fifoDataIn,
  busDataIn, 
  busDataOut,
  fifoREn,
  fifoEmpty,
  forceEmpty,
  numElementsInFifo
  );
input [2:0] address;
input writeEn;
input strobe_i;
input clk;
input rst;
input [7:0] fifoDataIn;
input [7:0] busDataIn; 
output [7:0] busDataOut;
output fifoREn;
input fifoEmpty;
output forceEmpty;
input [15:0] numElementsInFifo;
input fifoSelect;


wire [2:0] address;
wire writeEn;
wire strobe_i;
wire clk;
wire rst;
wire [7:0] fifoDataIn;
wire [7:0] busDataIn; 
reg [7:0] busDataOut;
reg fifoREn;
wire fifoEmpty;
reg forceEmpty;
wire [15:0] numElementsInFifo;
wire fifoSelect;


//sync write
always @(posedge clk)
begin
	if (writeEn == 1'b1 && fifoSelect == 1'b1 && 
  address == `FIFO_CONTROL_REG && strobe_i == 1'b1 && busDataIn[0] == 1'b1)
    forceEmpty <= 1'b1;
  else
    forceEmpty <= 1'b0;
end


// async read mux
always @(address or fifoDataIn or numElementsInFifo or fifoEmpty)
begin
	case (address)
      `FIFO_DATA_REG : busDataOut <= fifoDataIn;
      `FIFO_STATUS_REG : busDataOut <= {7'b0000000, fifoEmpty};
      `FIFO_DATA_COUNT_MSB : busDataOut <= numElementsInFifo[15:8];
      `FIFO_DATA_COUNT_LSB : busDataOut <= numElementsInFifo[7:0];
      default: busDataOut <= 8'h00; 
	endcase
end

//generate fifo read strobe
always @(address or writeEn or strobe_i or fifoSelect) begin
  if (address == `FIFO_DATA_REG &&   writeEn == 1'b0 && 
  strobe_i == 1'b1 &&   fifoSelect == 1'b1)
    fifoREn <= 1'b1;
  else
    fifoREn <= 1'b0;
end


endmodule