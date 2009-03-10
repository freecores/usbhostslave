//////////////////////////////////////////////////////////////////////
////                                                              ////
//// readUSBWireData.v                                            ////
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
// $Id: readUSBWireData.v,v 1.1.1.1 2004-10-11 04:01:01 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"

module readUSBWireData (RxBitsIn, RxDataInTick, RxBitsOut, SIERxRdyIn, SIERxWEn, fullSpeedRate, disableWireRead, clk, rst);
input   [1:0] RxBitsIn;
output  RxDataInTick;
input   SIERxRdyIn;
input   clk;
input   fullSpeedRate;
input   rst;
input   disableWireRead;
output  [1:0] RxBitsOut;
output  SIERxWEn;

wire   [1:0] RxBitsIn;
reg    RxDataInTick;
wire   SIERxRdyIn;
wire   clk;
wire   fullSpeedRate;
wire   rst;
reg    [1:0] RxBitsOut;
reg    SIERxWEn;

// local registers
reg  [1:0]buffer0;
reg  [1:0]buffer1;
reg  [1:0]buffer2;
reg  [1:0]buffer3;
reg  [2:0]bufferCnt;
reg  [1:0]bufferInIndex;
reg  [1:0]bufferOutIndex;
reg decBufferCnt;
reg  [4:0]i;
reg incBufferCnt;
reg  [1:0]oldRxBitsIn;

// buffer output state machine state codes:
`define WAIT_BUFFER_NOT_EMPTY 2'b00
`define WAIT_SIE_RX_READY 2'b01
`define SIE_RX_WRITE 2'b10

reg [1:0] bufferOutStMachCurrState;


always @(posedge clk) begin
  if (rst == 1'b1)
  begin
    bufferCnt <= 3'b000;
	end
  else begin
    if (incBufferCnt == 1'b1 && decBufferCnt == 1'b0)
      bufferCnt <= bufferCnt + 1'b1;
    else if (incBufferCnt == 1'b0 && decBufferCnt == 1'b1)
      bufferCnt <= bufferCnt - 1'b1;
  end
end



//Perform line rate clock recovery
//Recover the wire data, and store data to buffer
always @(posedge clk) begin
  if (rst == 1'b1)
  begin
    i <= 5'b00000;
 		incBufferCnt <= 1'b0;
		bufferInIndex <= 2'b00;
		buffer0 <= 2'b00;
		buffer1 <= 2'b00;
		buffer2 <= 2'b00;
		buffer3 <= 2'b00;
    RxDataInTick <= 1'b0;
	end
  else begin
	  incBufferCnt <= 1'b0;         //default value
	  oldRxBitsIn <= RxBitsIn;
	  if (oldRxBitsIn != RxBitsIn)  //if edge detected then
		  i <= 5'b00000;              //reset the counter
	  else
		  i <= i + 1'b1;
    if ( (fullSpeedRate == 1'b1 && i[1:0] == 2'b10) || (fullSpeedRate == 1'b0 && i == 5'b10000) )
	  begin
      RxDataInTick <= !RxDataInTick;
      if (disableWireRead != 1'b1)  //do not read wire data when transmitter is active
      begin
        incBufferCnt <= 1'b1;
		    bufferInIndex <= bufferInIndex + 1'b1;
		    case (bufferInIndex)
			    2'b00 : buffer0 <= RxBitsIn;
			    2'b01 : buffer1 <= RxBitsIn;
			    2'b10 : buffer2 <= RxBitsIn;
			    2'b11 : buffer3 <= RxBitsIn;
		    endcase
      end
	  end
  end
end

				

//read from buffer, and output to SIEReceiver
always @(posedge clk) begin
  if (rst == 1'b1)
  begin
		decBufferCnt <= 1'b0;
		bufferOutIndex <= 2'b00;
		RxBitsOut <= 2'b00;
		SIERxWEn <= 1'b0;
		bufferOutStMachCurrState <= `WAIT_BUFFER_NOT_EMPTY;
	end
  else begin
	  case (bufferOutStMachCurrState)
		  `WAIT_BUFFER_NOT_EMPTY:
		  begin
			  if (bufferCnt != 3'b000)
				  bufferOutStMachCurrState <= `WAIT_SIE_RX_READY;
		  end
		  `WAIT_SIE_RX_READY:
		  begin
			  if (SIERxRdyIn == 1'b1)
			  begin 
				  SIERxWEn <= 1'b1;
				  bufferOutStMachCurrState <= `SIE_RX_WRITE;
				  decBufferCnt <= 1'b1;
				  bufferOutIndex <= bufferOutIndex + 1'b1;
				  case (bufferOutIndex)
  			    2'b00 :	RxBitsOut <= buffer0;
					  2'b01 : RxBitsOut <= buffer1;
					  2'b10 : RxBitsOut <= buffer2;
					  2'b11 : RxBitsOut <= buffer3;
				  endcase
			  end
		  end
		  `SIE_RX_WRITE:
		  begin
			  SIERxWEn <= 1'b0;
			  decBufferCnt <= 1'b0;
			  bufferOutStMachCurrState <= `WAIT_BUFFER_NOT_EMPTY;
		  end
	  endcase
  end
end

			



endmodule