//////////////////////////////////////////////////////////////////////
////                                                              ////
//// hostSlaveMuxBI.v                                             ////
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
`timescale 1ns / 1ps

`include "usbHostSlave_h.v"

 module hostSlaveMuxBI (dataIn, dataOut, address, writeEn, strobe_i, clk, rst,
  hostMode, hostSlaveMuxSel);

input [7:0] dataIn;
input address;
input writeEn;
input strobe_i;
input clk;
input rst;
output [7:0] dataOut;
input hostSlaveMuxSel;
output hostMode;

wire [7:0] dataIn;
wire address;
wire writeEn;
wire strobe_i;
wire clk;
wire rst;
reg [7:0] dataOut;
wire hostSlaveMuxSel;
reg hostMode;

//internal wire and regs

//sync write demux
always @(posedge clk)
begin
  if (rst == 1'b1)
    hostMode <= 1'b0;
  else begin
    if (writeEn == 1'b1 && hostSlaveMuxSel == 1'b1 && strobe_i == 1'b1 && address == `HOST_SLAVE_CONTROL_REG )
      hostMode <= dataIn[0];
  end
end


// async read mux
always @(address or hostMode)
begin
  case (address)
    `HOST_SLAVE_CONTROL_REG: dataOut <= {7'h0, hostMode};
    `HOST_SLAVE_VERSION_REG: dataOut <= `USBHOSTSLAVE_VERSION_NUM;
  endcase
end

endmodule