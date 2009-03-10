//////////////////////////////////////////////////////////////////////
////                                                              ////
//// USBHostControlBI.v                                           ////
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


`include "usbHostControl_h.v"
 
module USBHostControlBI (address, dataIn, dataOut, writeEn,
  strobe_i,
  clk, rst,
  SOFSentIntOut, connEventIntOut, resumeIntOut, transDoneIntOut,
  TxTransTypeReg, TxSOFEnableReg,
  TxAddrReg, TxEndPReg, frameNumIn, 
  RxPktStatusIn, RxPIDIn,
  connectStateIn,
  SOFSentIn, connEventIn, resumeIntIn, transDoneIn,
  hostControlSelect,
  clrTransReq,
  preambleEn,
  SOFSync,
  TxLineState,
  LineDirectControlEn,
  fullSpeedPol, 
  fullSpeedRate,
  transReq
  );
input [3:0] address;
input [7:0] dataIn;
input writeEn; 
input strobe_i;
input clk;
input rst;
output [7:0] dataOut;
output SOFSentIntOut;
output connEventIntOut;
output resumeIntOut;
output transDoneIntOut;

output [1:0] TxTransTypeReg;
output TxSOFEnableReg;
output [6:0] TxAddrReg;
output [3:0] TxEndPReg;
input [10:0] frameNumIn;
input [7:0] RxPktStatusIn;
input [3:0] RxPIDIn;
input [1:0] connectStateIn;
input SOFSentIn;
input connEventIn;
input resumeIntIn;
input transDoneIn;
input hostControlSelect;
input clrTransReq;
output preambleEn;
output SOFSync;
output [1:0] TxLineState;
output LineDirectControlEn;
output fullSpeedPol; 
output fullSpeedRate;
output transReq;

wire [3:0] address;
wire [7:0] dataIn;
wire writeEn;
wire strobe_i;
wire clk;
wire rst;
reg [7:0] dataOut;

reg SOFSentIntOut;
reg connEventIntOut;
reg resumeIntOut;
reg transDoneIntOut;

reg [1:0] TxTransTypeReg;
reg TxSOFEnableReg;
reg [6:0] TxAddrReg;
reg [3:0] TxEndPReg;
wire [10:0] frameNumIn;
wire [7:0] RxPktStatusIn;
wire [3:0] RxPIDIn;
wire [1:0] connectStateIn;

wire SOFSentIn;
wire connEventIn;
wire resumeIntIn;
wire transDoneIn;
wire hostControlSelect;
wire clrTransReq;
reg preambleEn;
reg SOFSync;
reg [1:0] TxLineState;
reg LineDirectControlEn;
reg fullSpeedPol; 
reg fullSpeedRate;
reg transReq;

//internal wire and regs
reg [1:0] TxControlReg;
reg [4:0] TxLineControlReg;
reg clrSOFReq;
reg clrConnEvtReq;
reg clrResInReq;
reg clrTransDoneReq;
reg SOFSentInt;
reg connEventInt;
reg resumeInt;
reg transDoneInt;
reg [3:0] interruptMaskReg;
reg setTransReq;

//sync write demux
always @(posedge clk)
begin
  clrSOFReq <= 1'b0;
  clrConnEvtReq <= 1'b0;
  clrResInReq <= 1'b0;
  clrTransDoneReq <= 1'b0;
  setTransReq <= 1'b0;
  if (writeEn == 1'b1 && strobe_i == 1'b1 && hostControlSelect == 1'b1)
  begin
    case (address)
      `TX_CONTROL_REG : begin
        preambleEn <= dataIn[2];
        SOFSync <= dataIn[1];
        setTransReq <= dataIn[0];
      end
      `TX_TRANS_TYPE_REG : TxTransTypeReg <= dataIn[1:0];
      `TX_LINE_CONTROL_REG : TxLineControlReg <= dataIn[4:0];
      `TX_SOF_ENABLE_REG : TxSOFEnableReg <= dataIn[0];
      `TX_ADDR_REG : TxAddrReg <= dataIn[6:0];
      `TX_ENDP_REG : TxEndPReg <= dataIn[3:0];
      `INTERRUPT_STATUS_REG :  begin
        clrSOFReq <= dataIn[3];
        clrConnEvtReq <= dataIn[2];
        clrResInReq <= dataIn[1];
        clrTransDoneReq <= dataIn[0];
      end
      `INTERRUPT_MASK_REG  : interruptMaskReg <= dataIn[3:0];
    endcase
  end
end

//interrupt control
always @(posedge clk)
begin
  if (SOFSentIn == 1'b1)
    SOFSentInt <= 1'b1;
  else if (clrSOFReq == 1'b1)
    SOFSentInt <= 1'b0;
    
  if (connEventIn == 1'b1)
    connEventInt <= 1'b1;
  else if (clrConnEvtReq == 1'b1)
    connEventInt <= 1'b0;
    
  if (resumeIntIn == 1'b1)
    resumeInt <= 1'b1;
  else if (clrResInReq == 1'b1)
    resumeInt <= 1'b0;  

  if (transDoneIn == 1'b1)
    transDoneInt <= 1'b1;
  else if (clrTransDoneReq == 1'b1)
    transDoneInt <= 1'b0;
end

//mask interrupts
always @(interruptMaskReg or transDoneInt or resumeInt or connEventInt or SOFSentInt) begin
  transDoneIntOut <= transDoneInt & interruptMaskReg[`TRANS_DONE_BIT];
  resumeIntOut <= resumeInt & interruptMaskReg[`RESUME_INT_BIT];
  connEventIntOut <= connEventInt & interruptMaskReg[`CONNECTION_EVENT_BIT];
  SOFSentIntOut <= SOFSentInt & interruptMaskReg[`SOF_SENT_BIT];
end  
  
//transaction request set/clear
always @(posedge clk)
begin
  if (setTransReq == 1'b1)
    transReq <= 1'b1;
  else if (clrTransReq == 1'b1)
    transReq <= 1'b0;
end  
  
//break out control signals
always @(TxControlReg or TxLineControlReg) begin
  TxLineState <= TxLineControlReg[`TX_LINE_STATE_MSBIT:`TX_LINE_STATE_LSBIT];
  LineDirectControlEn <= TxLineControlReg[`DIRECT_CONTROL_BIT];
  fullSpeedPol <= TxLineControlReg[`FULL_SPEED_LINE_POLARITY_BIT]; 
  fullSpeedRate <= TxLineControlReg[`FULL_SPEED_LINE_RATE_BIT];
end
  
// async read mux
always @(address or
  TxControlReg or TxTransTypeReg or TxLineControlReg or TxSOFEnableReg or
  TxAddrReg or TxEndPReg or frameNumIn or 
  SOFSentInt or connEventInt or resumeInt or transDoneInt or
  interruptMaskReg or RxPktStatusIn or RxPIDIn or connectStateIn or
  preambleEn or SOFSync or transReq)
begin
  case (address)
      `TX_CONTROL_REG : dataOut <= {5'b00000, preambleEn, SOFSync, transReq} ;
      `TX_TRANS_TYPE_REG : dataOut <= {6'b000000, TxTransTypeReg};
      `TX_LINE_CONTROL_REG : dataOut <= {3'b000, TxLineControlReg};
      `TX_SOF_ENABLE_REG : dataOut <= {7'b0000000, TxSOFEnableReg};
      `TX_ADDR_REG : dataOut <= {1'b0, TxAddrReg};
      `TX_ENDP_REG : dataOut <= {4'h0, TxEndPReg};
      `FRAME_NUM_MSB_REG : dataOut <= {5'b00000, frameNumIn[10:8]};
      `FRAME_NUM_LSB_REG : dataOut <= frameNumIn[7:0];
      `INTERRUPT_STATUS_REG :  dataOut <= {4'h0, SOFSentInt, connEventInt, resumeInt, transDoneInt};
      `INTERRUPT_MASK_REG  : dataOut <= {4'h0, interruptMaskReg};
      `RX_STATUS_REG  : dataOut <= RxPktStatusIn;
      `RX_PID_REG  : dataOut <= {4'b0000, RxPIDIn};
      `RX_CONNECT_STATE_REG : dataOut <= {6'b000000, connectStateIn};
      default: dataOut <= 8'h00;
  endcase
end


endmodule