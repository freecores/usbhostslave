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
`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"

module readUSBWireData (RxBitsIn, RxDataInTick, RxBitsOut, SIERxRdyIn, SIERxWEn, fullSpeedRate, TxWireActiveDrive, clk, rst, noActivityTimeOut);
input   [1:0] RxBitsIn;
output  RxDataInTick;
input   SIERxRdyIn;
input   clk;
input   fullSpeedRate;
input   rst;
input   TxWireActiveDrive;
output  [1:0] RxBitsOut;
output  SIERxWEn;
output noActivityTimeOut;

wire   [1:0] RxBitsIn;
reg    RxDataInTick;
wire   SIERxRdyIn;
wire   clk;
wire   fullSpeedRate;
wire   rst;
reg    [1:0] RxBitsOut;
reg    SIERxWEn;
reg    noActivityTimeOut;

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
reg [1:0] RxBitsInReg;
reg [15:0] timeOutCnt;
reg RxWireActive;

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
    RxWireActive <= 1'b0;
  end
  else begin
    RxBitsInReg <= RxBitsIn;      //sync to local clock to avoid metastability issues
    incBufferCnt <= 1'b0;         //default value
    oldRxBitsIn <= RxBitsInReg;
    if (oldRxBitsIn != RxBitsInReg) begin  //if edge detected then
      i <= 5'b00000;              //reset the counter
      RxWireActive <= 1'b1;       // flag receive activity
    end
    else begin
      i <= i + 1'b1;
      RxWireActive <= 1'b0;
    end
    if ( (fullSpeedRate == 1'b1 && i[1:0] == 2'b01) || (fullSpeedRate == 1'b0 && i == 5'b10000) )
    begin
      RxDataInTick <= !RxDataInTick;
      if (TxWireActiveDrive != 1'b1)  //do not read wire data when transmitter is active
      begin
        incBufferCnt <= 1'b1;
        bufferInIndex <= bufferInIndex + 1'b1;
        case (bufferInIndex)
          2'b00 : buffer0 <= RxBitsInReg;
          2'b01 : buffer1 <= RxBitsInReg;
          2'b10 : buffer2 <= RxBitsInReg;
          2'b11 : buffer3 <= RxBitsInReg;
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
            2'b00 :  RxBitsOut <= buffer0;
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

//generate time out flag if no tx or rx activity
always @(posedge clk) begin
  if (rst) begin
    timeOutCnt <= 16'h0000;
    noActivityTimeOut <= 1'b0;
  end
  else begin
    if (TxWireActiveDrive == 1'b1 || RxWireActive == 1'b1)
      timeOutCnt <= 16'h0000;
    else 
      timeOutCnt <= timeOutCnt + 1'b1;
    //if (timeOutCnt == `RX_PACKET_TOUT * `OVER_SAMPLE_RATE)
    if ( (fullSpeedRate == 1'b1 && timeOutCnt == `RX_PACKET_TOUT * `FS_OVER_SAMPLE_RATE)
          || (fullSpeedRate == 1'b0 && timeOutCnt == `RX_PACKET_TOUT * `LS_OVER_SAMPLE_RATE) )
    //if (timeOutCnt == 16'h200)  //temporary hack
      noActivityTimeOut <= 1'b1;
    else
      noActivityTimeOut <= 1'b0;
  end
end
      



endmodule