//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHostSlave.v                                               ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////   Top level module
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
// $Id: usbHostSlave.v,v 1.1.1.1 2004-10-11 04:01:11 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module usbHostSlave(
	clk, 
  rst,
  address_i, 
  data_i, 
  data_o, 
  writeEn, 
  strobe_i,
  ack_o,
  hostSOFSentIntOut, 
  hostConnEventIntOut, 
  hostResumeIntOut, 
  hostTransDoneIntOut,
  slaveNAKSentIntOut,
  slaveSOFRxedIntOut, 
  slaveResetEventIntOut, 
  slaveResumeIntOut, 
  slaveTransDoneIntOut,
	USBWireDataIn,
	USBWireDataInTick,
  USBWireDataOut,
  USBWireDataOutTick,
	USBWireCtrlOut
	 );
	parameter HOST_FIFO_DEPTH = 64; //HOST_FIFO_DEPTH = HOST_ADDR_WIDTH^2
  parameter HOST_FIFO_ADDR_WIDTH = 6;   
	parameter EP0_FIFO_DEPTH = 64; 
  parameter EP0_FIFO_ADDR_WIDTH = 6;   
	parameter EP1_FIFO_DEPTH = 64; 
  parameter EP1_FIFO_ADDR_WIDTH = 6;   
	parameter EP2_FIFO_DEPTH = 64; 
  parameter EP2_FIFO_ADDR_WIDTH = 6;   
	parameter EP3_FIFO_DEPTH = 64; 
  parameter EP3_FIFO_ADDR_WIDTH = 6;   

input clk;
input rst;
input [7:0] address_i; 
input [7:0] data_i; 
output [7:0] data_o; 
input writeEn; 
input strobe_i;
output ack_o;
output hostSOFSentIntOut; 
output hostConnEventIntOut; 
output hostResumeIntOut; 
output hostTransDoneIntOut;
output slaveSOFRxedIntOut; 
output slaveResetEventIntOut; 
output slaveResumeIntOut; 
output slaveTransDoneIntOut;
output slaveNAKSentIntOut;
input [1:0] USBWireDataIn;
output [1:0] USBWireDataOut;
output USBWireDataOutTick;
output USBWireDataInTick;
output USBWireCtrlOut;

wire clk;
wire rst;
wire [7:0] address_i; 
wire [7:0] data_i; 
wire [7:0] data_o; 
wire writeEn; 
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
wire [1:0] USBWireDataIn;
wire [1:0] USBWireDataOut;
wire USBWireDataOutTick;
wire USBWireDataInTick;
wire USBWireCtrlOut;

//internal wiring
wire hostControlSel;
wire slaveControlSel;
wire hostRxFifoSel; 
wire hostTxFifoSel;
wire hostSlaveMuxSel;
wire [7:0] dataFromHostControl;
wire [7:0] dataFromSlaveControl;
wire [7:0] dataFromHostRxFifo;
wire [7:0] dataFromHostTxFifo;
wire [7:0] dataFromHostSlaveMux;
wire hostTxFifoRE; 
wire [7:0] hostTxFifoData; 
wire hostTxFifoEmpty;
wire hostRxFifoWE; 
wire [7:0] hostRxFifoData; 
wire hostRxFifoFull;
wire [7:0] RxCtrlOut; 
wire [7:0] RxDataFromSIE; 
wire RxDataOutWEn;
wire fullSpeedBitRateFromHost; 
wire fullSpeedBitRateFromSlave; 
wire fullSpeedPolarityFromHost;
wire fullSpeedPolarityFromSlave;
wire SIEPortWEnFromHost; 
wire SIEPortWEnFromSlave; 
wire SIEPortTxRdy;
wire [7:0] SIEPortDataInFromHost; 
wire [7:0] SIEPortDataInFromSlave; 
wire [7:0] SIEPortCtrlInFromHost;
wire [7:0] SIEPortCtrlInFromSlave;
wire [1:0] connectState; 
wire resumeDetected;
wire [7:0] SIEPortDataInToSIE;
wire SIEPortWEnToSIE;
wire [7:0] SIEPortCtrlInToSIE;
wire fullSpeedPolarityToSIE;
wire fullSpeedBitRateToSIE;
wire noActivityTimeOut;
wire TxFifoEP0REn;
wire TxFifoEP1REn;
wire TxFifoEP2REn;
wire TxFifoEP3REn;
wire [7:0] TxFifoEP0Data;
wire [7:0] TxFifoEP1Data;
wire [7:0] TxFifoEP2Data;
wire [7:0] TxFifoEP3Data;
wire TxFifoEP0Empty;
wire TxFifoEP1Empty;
wire TxFifoEP2Empty;
wire TxFifoEP3Empty;
wire RxFifoEP0WEn;
wire RxFifoEP1WEn;
wire RxFifoEP2WEn;
wire RxFifoEP3WEn;
wire RxFifoEP0Full;
wire RxFifoEP1Full;
wire RxFifoEP2Full;
wire RxFifoEP3Full;
wire [7:0] slaveRxFifoData;
wire [7:0] dataFromEP0RxFifo;
wire [7:0] dataFromEP1RxFifo;
wire [7:0] dataFromEP2RxFifo;
wire [7:0] dataFromEP3RxFifo;
wire [7:0] dataFromEP0TxFifo;
wire [7:0] dataFromEP1TxFifo;
wire [7:0] dataFromEP2TxFifo;
wire [7:0] dataFromEP3TxFifo;
wire slaveEP0RxFifoSel;
wire slaveEP1RxFifoSel;
wire slaveEP2RxFifoSel;
wire slaveEP3RxFifoSel;
wire slaveEP0TxFifoSel;
wire slaveEP1TxFifoSel;
wire slaveEP2TxFifoSel;
wire slaveEP3TxFifoSel;

usbHostControl u_usbHostControl(
  .clk(clk), 
  .rst(rst),
	.TxFifoRE(hostTxFifoRE), 
  .TxFifoData(hostTxFifoData), 
  .TxFifoEmpty(hostTxFifoEmpty),
	.RxFifoWE(hostRxFifoWE), 
  .RxFifoData(hostRxFifoData), 
  .RxFifoFull(hostRxFifoFull),
	.RxByteStatus(RxCtrlOut), 
  .RxData(RxDataFromSIE), 
  .RxDataValid(RxDataOutWEn),
	.SIERxTimeOut(noActivityTimeOut),
	.fullSpeedRate(fullSpeedBitRateFromHost), 
  .fullSpeedPol(fullSpeedPolarityFromHost),
	.HCTxPortEn(SIEPortWEnFromHost), 
  .HCTxPortRdy(SIEPortTxRdy),
	.HCTxPortData(SIEPortDataInFromHost), 
  .HCTxPortCtrl(SIEPortCtrlInFromHost),
	.connectStateIn(connectState), 
	.resumeDetectedIn(resumeDetected),
  .busAddress(address_i[3:0]),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostControl), 
  .busWriteEn(writeEn),
  .busStrobe_i(strobe_i),
	.SOFSentIntOut(hostSOFSentIntOut), 
  .connEventIntOut(hostConnEventIntOut), 
  .resumeIntOut(hostResumeIntOut), 
  .transDoneIntOut(hostTransDoneIntOut),
  .hostControlSelect(hostControlSel) );
  

usbSlaveControl u_usbSlaveControl(
  .clk(clk), 
  .rst(rst),
	.RxByteStatus(RxCtrlOut), 
  .RxData(RxDataFromSIE), 
  .RxDataValid(RxDataOutWEn),
	.SIERxTimeOut(noActivityTimeOut), 
  .RxFifoData(slaveRxFifoData),
	.fullSpeedRate(fullSpeedBitRateFromSlave), 
  .fullSpeedPol(fullSpeedPolarityFromSlave),
	.SCTxPortEn(SIEPortWEnFromSlave), 
  .SCTxPortRdy(SIEPortTxRdy),
	.SCTxPortData(SIEPortDataInFromSlave), 
  .SCTxPortCtrl(SIEPortCtrlInFromSlave),
	.connectStateIn(connectState), 
	.resumeDetectedIn(resumeDetected),
  .busAddress(address_i[4:0]),
  .busDataIn(data_i), 
  .busDataOut(dataFromSlaveControl), 
  .busWriteEn(writeEn),
  .busStrobe_i(strobe_i),
	.SOFRxedIntOut(slaveSOFRxedIntOut), 
  .resetEventIntOut(slaveResetEventIntOut), 
  .resumeIntOut(slaveResumeIntOut), 
  .transDoneIntOut(slaveTransDoneIntOut),
  .NAKSentIntOut(slaveNAKSentIntOut),
  .slaveControlSelect(slaveControlSel),
  .TxFifoEP0REn(TxFifoEP0REn),
  .TxFifoEP1REn(TxFifoEP1REn),
  .TxFifoEP2REn(TxFifoEP2REn),
  .TxFifoEP3REn(TxFifoEP3REn),
  .TxFifoEP0Data(TxFifoEP0Data),
  .TxFifoEP1Data(TxFifoEP1Data),
  .TxFifoEP2Data(TxFifoEP2Data),
  .TxFifoEP3Data(TxFifoEP3Data),
  .TxFifoEP0Empty(TxFifoEP0Empty),
  .TxFifoEP1Empty(TxFifoEP1Empty),
  .TxFifoEP2Empty(TxFifoEP2Empty),
  .TxFifoEP3Empty(TxFifoEP3Empty),
  .RxFifoEP0WEn(RxFifoEP0WEn),
  .RxFifoEP1WEn(RxFifoEP1WEn),
  .RxFifoEP2WEn(RxFifoEP2WEn),
  .RxFifoEP3WEn(RxFifoEP3WEn),
  .RxFifoEP0Full(RxFifoEP0Full),
  .RxFifoEP1Full(RxFifoEP1Full),
  .RxFifoEP2Full(RxFifoEP2Full),
  .RxFifoEP3Full(RxFifoEP3Full)
  );

wishBoneBI u_wishBoneBI (
  .address(address_i), 
  .dataIn(data_i), 
  .dataOut(data_o), 
  .writeEn(writeEn), 
  .strobe_i(strobe_i),
  .ack_o(ack_o),
  .clk(clk), 
  .rst(rst),
	.hostControlSel(hostControlSel), 
  .hostRxFifoSel(hostRxFifoSel), 
  .hostTxFifoSel(hostTxFifoSel),
  .slaveControlSel(slaveControlSel),
  .slaveEP0RxFifoSel(slaveEP0RxFifoSel), 
  .slaveEP1RxFifoSel(slaveEP1RxFifoSel), 
  .slaveEP2RxFifoSel(slaveEP2RxFifoSel), 
  .slaveEP3RxFifoSel(slaveEP3RxFifoSel), 
  .slaveEP0TxFifoSel(slaveEP0TxFifoSel), 
  .slaveEP1TxFifoSel(slaveEP1TxFifoSel), 
  .slaveEP2TxFifoSel(slaveEP2TxFifoSel), 
  .slaveEP3TxFifoSel(slaveEP3TxFifoSel), 
  .hostSlaveMuxSel(hostSlaveMuxSel),
  .dataFromHostControl(dataFromHostControl),
  .dataFromHostRxFifo(dataFromHostRxFifo),
  .dataFromHostTxFifo(dataFromHostTxFifo),
  .dataFromSlaveControl(dataFromSlaveControl),
  .dataFromEP0RxFifo(dataFromEP0RxFifo), 
  .dataFromEP1RxFifo(dataFromEP1RxFifo), 
  .dataFromEP2RxFifo(dataFromEP2RxFifo), 
  .dataFromEP3RxFifo(dataFromEP3RxFifo),
  .dataFromEP0TxFifo(dataFromEP0TxFifo), 
  .dataFromEP1TxFifo(dataFromEP1TxFifo), 
  .dataFromEP2TxFifo(dataFromEP2TxFifo), 
  .dataFromEP3TxFifo(dataFromEP3TxFifo),
  .dataFromHostSlaveMux(dataFromHostSlaveMux)
	 );

hostSlaveMux u_hostSlaveMux(
	.SIEPortCtrlInToSIE(SIEPortCtrlInToSIE),
	.SIEPortCtrlInFromHost(SIEPortCtrlInFromHost),
	.SIEPortCtrlInFromSlave(SIEPortCtrlInFromSlave),
	.SIEPortDataInToSIE(SIEPortDataInToSIE), 
	.SIEPortDataInFromHost(SIEPortDataInFromHost), 
	.SIEPortDataInFromSlave(SIEPortDataInFromSlave), 
	.SIEPortWEnToSIE(SIEPortWEnToSIE), 
	.SIEPortWEnFromHost(SIEPortWEnFromHost), 
	.SIEPortWEnFromSlave(SIEPortWEnFromSlave), 
	.fullSpeedPolarityToSIE(fullSpeedPolarityToSIE),
	.fullSpeedPolarityFromHost(fullSpeedPolarityFromHost),
	.fullSpeedPolarityFromSlave(fullSpeedPolarityFromSlave),
	.fullSpeedBitRateToSIE(fullSpeedBitRateToSIE),
	.fullSpeedBitRateFromHost(fullSpeedBitRateFromHost),
	.fullSpeedBitRateFromSlave(fullSpeedBitRateFromSlave),
  .dataIn(data_i), 
  .dataOut(dataFromHostSlaveMux), 
  .writeEn(writeEn),
  .strobe_i(strobe_i),
  .clk(clk), 
  .rst(rst),
  .hostSlaveMuxSel(hostSlaveMuxSel)  );

usbSerialInterfaceEngine u_usbSerialInterfaceEngine(
  .clk(clk), 
  .rst(rst),
	.USBWireDataIn(USBWireDataIn),
	.USBWireDataOut(USBWireDataOut),
	.USBWireDataInTick(USBWireDataInTick),
	.USBWireDataOutTick(USBWireDataOutTick),
	.USBWireCtrlOut(USBWireCtrlOut),
	.connectState(connectState),
	.resumeDetected(resumeDetected),
	.RxCtrlOut(RxCtrlOut), 
	.RxDataOutWEn(RxDataOutWEn), 
	.RxDataOut(RxDataFromSIE), 
	.SIEPortCtrlIn(SIEPortCtrlInToSIE),
	.SIEPortDataIn(SIEPortDataInToSIE), 
	.SIEPortTxRdy(SIEPortTxRdy), 
	.SIEPortWEn(SIEPortWEnToSIE), 
	.fullSpeedPolarity(fullSpeedPolarityToSIE),
	.fullSpeedBitRate(fullSpeedBitRateToSIE),
  .noActivityTimeOut(noActivityTimeOut)
);

//---Host fifos
TxFifo #(HOST_FIFO_DEPTH, HOST_FIFO_ADDR_WIDTH) HostTxFifo (
  .clk(clk), 
  .rst(rst), 
  .fifoREn(hostTxFifoRE), 
  .fifoEmpty(hostTxFifoEmpty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(hostTxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostTxFifo),
  .fifoDataOut(hostTxFifoData) );


RxFifo #(HOST_FIFO_DEPTH, HOST_FIFO_ADDR_WIDTH) HostRxFifo(
  .clk(clk), 
  .rst(rst), 
  .fifoWEn(hostRxFifoWE), 
  .fifoFull(hostRxFifoFull),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(hostRxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromHostRxFifo),
  .fifoDataIn(hostRxFifoData)  );

//---Slave fifos

TxFifo #(EP0_FIFO_DEPTH, EP0_FIFO_ADDR_WIDTH) EP0TxFifo (
  .clk(clk), 
  .rst(rst), 
  .fifoREn(TxFifoEP0REn), 
  .fifoEmpty(TxFifoEP0Empty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP0TxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP0TxFifo),
  .fifoDataOut(TxFifoEP0Data) );

TxFifo #(EP1_FIFO_DEPTH, EP1_FIFO_ADDR_WIDTH) EP1TxFifo (
  .clk(clk), 
  .rst(rst), 
  .fifoREn(TxFifoEP1REn), 
  .fifoEmpty(TxFifoEP1Empty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP1TxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP1TxFifo),
  .fifoDataOut(TxFifoEP1Data) );

  TxFifo #(EP2_FIFO_DEPTH, EP2_FIFO_ADDR_WIDTH) EP2TxFifo (
  .clk(clk), 
  .rst(rst), 
  .fifoREn(TxFifoEP2REn), 
  .fifoEmpty(TxFifoEP2Empty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP2TxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP2TxFifo),
  .fifoDataOut(TxFifoEP2Data) );

  TxFifo #(EP3_FIFO_DEPTH, EP3_FIFO_ADDR_WIDTH) EP3TxFifo (
  .clk(clk), 
  .rst(rst), 
  .fifoREn(TxFifoEP3REn), 
  .fifoEmpty(TxFifoEP3Empty),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP3TxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP3TxFifo),
  .fifoDataOut(TxFifoEP3Data) );

RxFifo #(EP0_FIFO_DEPTH, EP0_FIFO_ADDR_WIDTH) EP0RxFifo(
  .clk(clk), 
  .rst(rst), 
  .fifoWEn(RxFifoEP0WEn), 
  .fifoFull(RxFifoEP0Full),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP0RxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP0RxFifo),
  .fifoDataIn(slaveRxFifoData)  );

RxFifo #(EP1_FIFO_DEPTH, EP1_FIFO_ADDR_WIDTH) EP1RxFifo(
  .clk(clk), 
  .rst(rst), 
  .fifoWEn(RxFifoEP1WEn), 
  .fifoFull(RxFifoEP1Full),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP1RxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP1RxFifo),
  .fifoDataIn(slaveRxFifoData)  );

RxFifo #(EP2_FIFO_DEPTH, EP2_FIFO_ADDR_WIDTH) EP2RxFifo(
  .clk(clk), 
  .rst(rst), 
  .fifoWEn(RxFifoEP2WEn), 
  .fifoFull(RxFifoEP2Full),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP2RxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP2RxFifo),
  .fifoDataIn(slaveRxFifoData)  );

RxFifo #(EP3_FIFO_DEPTH, EP3_FIFO_ADDR_WIDTH) EP3RxFifo(
  .clk(clk), 
  .rst(rst), 
  .fifoWEn(RxFifoEP3WEn), 
  .fifoFull(RxFifoEP3Full),
  .busAddress(address_i[2:0]), 
  .busWriteEn(writeEn), 
  .busStrobe_i(strobe_i),
  .busFifoSelect(slaveEP3RxFifoSel),
  .busDataIn(data_i), 
  .busDataOut(dataFromEP3RxFifo),
  .fifoDataIn(slaveRxFifoData)  );

endmodule

	
	




