//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHostSlaveWrap.v                                               ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////   Top level module wrapper. Enable connection to Avalon bus
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
// $Id: usbHostSlaveWrap.v,v 1.1 2004-12-18 14:57:10 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

module usbHostSlaveWrap(
  clk, 
  reset,
  address, 
  writedata, 
  readdata, 
  write, 
  read,
  waitrequest,
  chipselect,
  irq,
  USBWireVPI,
  USBWireVMI,
  USBWireDataInTick,
  USBWireVPO,
  USBWireVMO,
  USBWireDataOutTick,
  USBWireOutEn_n,
  USBFullSpeed,
  DPlusPullUp,
  DMinusPullUp
   );

input clk;
input reset;
input [7:0] address; 
input [7:0] writedata; 
output [7:0] readdata; 
input write; 
input read;
output waitrequest;
input chipselect;
output irq;
input USBWireVPI;
input USBWireVMI;
output USBWireVPO;
output USBWireVMO;
output USBWireDataOutTick;
output USBWireDataInTick;
output USBWireOutEn_n;
output USBFullSpeed;
output DPlusPullUp;
output DMinusPullUp;

wire clk;
wire reset;
wire [7:0] address; 
wire [7:0] writedata; 
wire [7:0] readdata; 
wire write; 
wire read;
wire waitrequest;
wire chipselect;
wire irq;
wire USBWireVPI;
wire USBWireVMI;
wire USBWireVPO;
wire USBWireVMO;
wire USBWireDataOutTick;
wire USBWireDataInTick;
wire USBWireOutEn_n;
wire USBFullSpeed;
wire DPlusPullUp;
wire DMinusPullUp;

//internal wiring 
wire strobe_i;
wire ack_o;
wire hostSOFSentIntOut; 
wire hostConnEventIntOut; 
wire hostResumeIntOut; 
wire hostTransDoneIntOut;
wire slaveSOFRxedIntOut; 
wire slaveResetEventIntOut; 
wire slaveResumeIntOut; 
wire slaveTransDoneIntOut;
wire slaveNAKSentIntOut;
wire USBWireCtrlOut;
wire [1:0] USBWireDataIn;
wire [1:0] USBWireDataOut;


assign irq = hostSOFSentIntOut | hostConnEventIntOut |
             hostResumeIntOut | hostTransDoneIntOut |
             slaveSOFRxedIntOut | slaveResetEventIntOut |
             slaveResumeIntOut | slaveTransDoneIntOut |
             slaveNAKSentIntOut;

assign strobe_i = chipselect & ( read | write);
assign waitrequest = ~ack_o;

assign USBWireOutEn_n = ~USBWireCtrlOut; 

assign USBWireDataIn = {USBWireVPI, USBWireVMI};
assign {USBWireVPO, USBWireVMO} = USBWireDataOut;

assign USBFullSpeed = 1'b1;
assign DPlusPullUp = 1'b1;
assign DMinusPullUp = 1'bz;

//Parameters declaration: 
defparam usbHostSlaveInst.HOST_FIFO_DEPTH = 64;
parameter HOST_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.HOST_FIFO_ADDR_WIDTH = 6;
parameter HOST_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP0_FIFO_DEPTH = 64;
parameter EP0_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP0_FIFO_ADDR_WIDTH = 6;
parameter EP0_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP1_FIFO_DEPTH = 64;
parameter EP1_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP1_FIFO_ADDR_WIDTH = 6;
parameter EP1_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP2_FIFO_DEPTH = 64;
parameter EP2_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP2_FIFO_ADDR_WIDTH = 6;
parameter EP2_FIFO_ADDR_WIDTH = 6;
defparam usbHostSlaveInst.EP3_FIFO_DEPTH = 64;
parameter EP3_FIFO_DEPTH = 64;
defparam usbHostSlaveInst.EP3_FIFO_ADDR_WIDTH = 6;
parameter EP3_FIFO_ADDR_WIDTH = 6;
usbHostSlave usbHostSlaveInst (
  .clk(clk),
  .rst(reset),
  .address_i(address),
  .data_i(writedata),
  .data_o(readdata),
  .writeEn(write),
  .strobe_i(strobe_i),
  .ack_o(ack_o),
  .hostSOFSentIntOut(hostSOFSentIntOut),
  .hostConnEventIntOut(hostConnEventIntOut),
  .hostResumeIntOut(hostResumeIntOut),
  .hostTransDoneIntOut(hostTransDoneIntOut),
  .slaveSOFRxedIntOut(slaveSOFRxedIntOut),
  .slaveResetEventIntOut(slaveResetEventIntOut),
  .slaveResumeIntOut(slaveResumeIntOut),
  .slaveTransDoneIntOut(slaveTransDoneIntOut),
  .slaveNAKSentIntOut(slaveNAKSentIntOut),
  .USBWireDataIn(USBWireDataIn),
  .USBWireDataInTick(USBWireDataInTick),
  .USBWireDataOut(USBWireDataOut),
  .USBWireDataOutTick(USBWireDataOutTick),
  .USBWireCtrlOut(USBWireCtrlOut));


endmodule

  
  




