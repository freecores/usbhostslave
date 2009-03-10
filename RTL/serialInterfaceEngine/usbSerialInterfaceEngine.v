//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbSerialInterfaceEngine.v                                   ////
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
// $Id: usbSerialInterfaceEngine.v,v 1.1.1.1 2004-10-11 04:01:04 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module usbSerialInterfaceEngine(
	clk, rst,
	//readUSBWireData
	USBWireDataIn,
	USBWireDataInTick,
	//writeUSBWireData
	USBWireDataOut,
	USBWireCtrlOut,
	USBWireDataOutTick,
	//SIEReceiver
	connectState,
	//processRxBit
	resumeDetected,
	//processRxByte
	RxCtrlOut, 
	RxDataOutWEn, 
	RxDataOut, 
    //SIETransmitter
	SIEPortCtrlIn,
	SIEPortDataIn, 
	SIEPortTxRdy, 
	SIEPortWEn, 
    //lineControlUpdate
	fullSpeedPolarity,
	fullSpeedBitRate,
  noActivityTimeOut
);

input clk, rst;
//readUSBWireData
input [1:0] USBWireDataIn;
output USBWireDataInTick;

//writeUSBWireData
output [1:0] USBWireDataOut;
output USBWireCtrlOut;
output noActivityTimeOut;
output USBWireDataOutTick;

//SIEReceiver
output [1:0] connectState;
//processRxBit
output resumeDetected;
//processRxByte
output [7:0] RxCtrlOut; 
output RxDataOutWEn; 
output [7:0] RxDataOut; 
//SIETransmitter
input [7:0] SIEPortCtrlIn;
input [7:0] SIEPortDataIn;
output SIEPortTxRdy; 
input SIEPortWEn;
//lineControlUpdate
input fullSpeedPolarity;
input fullSpeedBitRate;

wire clk, rst;
//readUSBWireData
wire [1:0] USBWireDataIn;
wire USBWireDataInTick;
//writeUSBWireData
wire [1:0] USBWireDataOut;
wire USBWireCtrlOut;
wire noActivityTimeOut;
wire USBWireDataOutTick;
//SIEReceiver
wire [1:0] connectState;
//processRxBit
wire resumeDetected;
//processRxByte
wire [7:0] RxCtrlOut; 
wire RxDataOutWEn; 
wire [7:0] RxDataOut; 
//SIETransmitter
wire [7:0] SIEPortCtrlIn;
wire [7:0] SIEPortDataIn;
wire SIEPortTxRdy; 
wire SIEPortWEn;
//lineControlUpdate
wire fullSpeedPolarity;
wire fullSpeedBitRate;

//internal wiring
wire [1:0] RxBitsFromSIERxToPrRxBit;
wire processRxBitsWEn;
wire processRxBitRdy;
wire [1:0] RxWireDataFromWireRxToSIERx;
wire RxWireDataWEn;
wire SIERxRdyOut;
wire disableWireRead;
wire [1:0] TxBitsFromArbToWire;
wire TxCtrlFromArbToWire;
wire USBWireRdy;
wire USBWireWEn;
wire USBWireReadyFromTxArb;
wire prcTxByteCtrl;
wire [1:0] prcTxByteData;
wire prcTxByteGnt;
wire prcTxByteReq;
wire prcTxByteWEn;
wire SIETxCtrl;
wire [1:0] SIETxData;
wire SIETxGnt;
wire SIETxReq;
wire SIETxWEn;
wire [7:0] TxByteFromSIEToPrcTxByte;
wire [7:0] TxCtrlFromSIEToPrcTxByte;
wire [1:0] JBit;
wire [1:0] KBit;
wire processRxByteWEn;
wire [7:0] RxDataFromPrcRxBitToPrcRxByte;
wire [7:0] RxCtrlFromPrcRxBitToPrcRxByte;
wire processRxByteRdy;
//Rx CRC
wire RxCRC16En; 
wire [15:0] RxCRC16Result;
wire RxCRC16UpdateRdy;
wire RxCRC5En; 
wire [4:0] RxCRC5Result; 
wire RxCRC5_8Bit; 
wire [7:0] RxCRCData; 
wire RxRstCRC;
wire RxCRC5UpdateRdy;
//Tx CRC
wire TxCRC16En; 
wire [15:0] TxCRC16Result;
wire TxCRC16UpdateRdy;
wire TxCRC5En; 
wire [4:0] TxCRC5Result; 
wire TxCRC5_8Bit; 
wire [7:0] TxCRCData; 
wire TxRstCRC; 
wire TxCRC5UpdateRdy;

wire processTxByteRdy; 
wire processTxByteWEn; 

lineControlUpdate u_lineControlUpdate
	(.fullSpeedPolarity(fullSpeedPolarity),
	.fullSpeedBitRate(fullSpeedBitRate),
	.JBit(JBit),
	.KBit(KBit) );

SIEReceiver u_SIEReceiver
	(.RxBitsOut(RxBitsFromSIERxToPrRxBit),
	.RxWireDataIn(RxWireDataFromWireRxToSIERx), 
	.RxWireDataWEn(RxWireDataWEn), 
	.SIERxRdyOut(SIERxRdyOut), 
	.clk(clk),
	.connectState(connectState),
	.processRxBitRdyIn(processRxBitRdy), 
	.processRxBitsWEn(processRxBitsWEn), 
	.rst(rst) );
	
processRxBit u_processRxBit
	(.JBit(JBit), 
	.KBit(KBit), 
	.RxBitsIn(RxBitsFromSIERxToPrRxBit), 
	.RxCtrlOut(RxCtrlFromPrcRxBitToPrcRxByte), 
	.RxDataOut(RxDataFromPrcRxBitToPrcRxByte), 
	.clk(clk), 
	.processRxBitRdy(processRxBitRdy), 
	.processRxBitsWEn(processRxBitsWEn), 
	.processRxByteWEn(processRxByteWEn), 
	.resumeDetected(resumeDetected), 
	.rst(rst),
  .processRxByteRdy(processRxByteRdy) );
	
processRxByte u_processRxByte
	(.CRC16En(RxCRC16En), 
	.CRC16Result(RxCRC16Result), 
  .CRC16UpdateRdy(RxCRC16UpdateRdy),
	.CRC5En(RxCRC5En), 
	.CRC5Result(RxCRC5Result), 
	.CRC5_8Bit(RxCRC5_8Bit),
  .CRC5UpdateRdy(RxCRC5UpdateRdy),
	.CRCData(RxCRCData), 
	.RxByteIn(RxDataFromPrcRxBitToPrcRxByte), 
	.RxCtrlIn(RxCtrlFromPrcRxBitToPrcRxByte), 
	.RxCtrlOut(RxCtrlOut), 
	.RxDataOutWEn(RxDataOutWEn), 
	.RxDataOut(RxDataOut), 
	.clk(clk), 
	.processRxDataInWEn(processRxByteWEn), 
	.rst(rst), 
	.rstCRC(RxRstCRC),
  .processRxByteRdy(processRxByteRdy) ); 
	
	
updateCRC5 RxUpdateCRC5
	(.rstCRC(RxRstCRC), 
	.CRCResult(RxCRC5Result), 
	.CRCEn(RxCRC5En), 
	.CRC5_8BitIn(RxCRC5_8Bit), 
	.dataIn(RxCRCData), 
  .ready(RxCRC5UpdateRdy),
	.clk(clk), 
	.rst(rst) );  
	
updateCRC16 RxUpdateCRC16
	(.rstCRC(RxRstCRC), 
	.CRCResult(RxCRC16Result), 
	.CRCEn(RxCRC16En), 
	.dataIn(RxCRCData), 
  .ready(RxCRC16UpdateRdy),
	.clk(clk), 
	.rst(rst) );	
	
SIETransmitter u_SIETransmitter
	(.CRC16En(TxCRC16En), 
	.CRC16Result(TxCRC16Result), 
	.CRC5En(TxCRC5En), 
	.CRC5Result(TxCRC5Result), 
	.CRC5_8Bit(TxCRC5_8Bit), 
	.CRCData(TxCRCData),
  .CRC5UpdateRdy(TxCRC5UpdateRdy),
  .CRC16UpdateRdy(TxCRC16UpdateRdy),
	.JBit(JBit), 
	.KBit(KBit), 
	.SIEPortCtrlIn(SIEPortCtrlIn),
	.SIEPortDataIn(SIEPortDataIn), 
	.SIEPortTxRdy(SIEPortTxRdy), 
	.SIEPortWEn(SIEPortWEn), 
	.TxByteOutCtrl(TxCtrlFromSIEToPrcTxByte), 
	.TxByteOut(TxByteFromSIEToPrcTxByte), 
	.USBWireCtrl(SIETxCtrl), 
	.USBWireData(SIETxData), 
	.USBWireGnt(SIETxGnt), 
	.USBWireRdy(USBWireReadyFromTxArb), 
	.USBWireReq(SIETxReq), 
	.USBWireWEn(SIETxWEn), 
	.clk(clk), 
	.processTxByteRdy(processTxByteRdy), 
	.processTxByteWEn(processTxByteWEn), 
	.rst(rst), 
	.rstCRC(TxRstCRC) );	  

updateCRC5 TxUpdateCRC5
	(.rstCRC(TxRstCRC), 
	.CRCResult(TxCRC5Result), 
	.CRCEn(TxCRC5En), 
	.CRC5_8BitIn(TxCRC5_8Bit), 
	.dataIn(TxCRCData),
  .ready(TxCRC5UpdateRdy),
	.clk(clk), 
	.rst(rst) );  
	
updateCRC16 TxUpdateCRC16
	(.rstCRC(TxRstCRC), 
	.CRCResult(TxCRC16Result), 
	.CRCEn(TxCRC16En), 
	.dataIn(TxCRCData), 
  .ready(TxCRC16UpdateRdy),
	.clk(clk), 
	.rst(rst) );	

processTxByte u_processTxByte
	(.JBit(JBit), 
	.KBit(KBit), 
	.TxByteCtrlIn(TxCtrlFromSIEToPrcTxByte), 
	.TxByteIn(TxByteFromSIEToPrcTxByte), 
	.USBWireCtrl(prcTxByteCtrl), 
	.USBWireData(prcTxByteData), 
	.USBWireGnt(prcTxByteGnt), 
	.USBWireRdy(USBWireReadyFromTxArb), 
	.USBWireReq(prcTxByteReq), 
	.USBWireWEn(prcTxByteWEn), 
	.clk(clk), 
	.processTxByteRdy(processTxByteRdy), 
	.processTxByteWEn(processTxByteWEn), 
	.rst(rst) ); 
	
USBWireTxArbiter u_USBWireTxArbiter
	(.SIETxCtrl(SIETxCtrl), 
	.SIETxData(SIETxData), 
	.SIETxGnt(SIETxGnt), 
	.SIETxReq(SIETxReq), 
	.SIETxWEn(SIETxWEn), 
	.TxBits(TxBitsFromArbToWire), 
	.TxCtl(TxCtrlFromArbToWire), 
	.USBWireRdyIn(USBWireRdy), 
	.USBWireRdyOut(USBWireReadyFromTxArb), 
	.USBWireWEn(USBWireWEn),
	.clk(clk), 
	.prcTxByteCtrl(prcTxByteCtrl), 
	.prcTxByteData(prcTxByteData), 
	.prcTxByteGnt(prcTxByteGnt), 
	.prcTxByteReq(prcTxByteReq), 
	.prcTxByteWEn(prcTxByteWEn), 
	.rst(rst) ); 
	
writeUSBWireData u_writeUSBWireData
	(.TxBitsIn(TxBitsFromArbToWire), 
	.TxBitsOut(USBWireDataOut), 
	.TxDataOutTick(USBWireDataOutTick),
	.TxCtrlIn(TxCtrlFromArbToWire), 
	.TxCtrlOut(USBWireCtrlOut), 
	.USBWireRdy(USBWireRdy), 
	.USBWireWEn(USBWireWEn),
	.disableWireReadOut(disableWireRead),
	.fullSpeedRate(fullSpeedBitRate), 
	.clk(clk),
	.rst(rst),
  .noActivityTimeOut(noActivityTimeOut) );  
	
readUSBWireData u_readUSBWireData
	(.RxBitsIn(USBWireDataIn), 
	.RxDataInTick(USBWireDataInTick),
	.RxBitsOut(RxWireDataFromWireRxToSIERx), 
	.SIERxRdyIn(SIERxRdyOut), 
	.SIERxWEn(RxWireDataWEn), 
	.fullSpeedRate(fullSpeedBitRate), 
	.disableWireRead(disableWireRead),
	.clk(clk),
	.rst(rst) );


endmodule

	
	




