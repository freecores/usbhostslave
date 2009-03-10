//////////////////////////////////////////////////////////////////////
////                                                              ////
//// USBSlaveControlBI.v                                          ////
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


`include "usbSlaveControl_h.v"
 
module USBSlaveControlBI (address, dataIn, dataOut, writeEn,
  strobe_i,
  clk, rst,
  SOFRxedIntOut, resetEventIntOut, resumeIntOut, transDoneIntOut, NAKSentIntOut,
  endP0TransTypeReg, endP0NAKTransTypeReg,
  endP1TransTypeReg, endP1NAKTransTypeReg,
  endP2TransTypeReg, endP2NAKTransTypeReg,
  endP3TransTypeReg, endP3NAKTransTypeReg,
  endP0ControlReg,
  endP1ControlReg,
  endP2ControlReg,
  endP3ControlReg,
  EP0StatusReg,
  EP1StatusReg,
  EP2StatusReg,
  EP3StatusReg,
  SCAddrReg, frameNum,
  connectStateIn,
  SOFRxedIn, resetEventIn, resumeIntIn, transDoneIn, NAKSentIn,
  slaveControlSelect,
  clrEP0Ready, clrEP1Ready, clrEP2Ready, clrEP3Ready,
  TxLineState,
  LineDirectControlEn,
  fullSpeedPol, 
  fullSpeedRate,
  SCGlobalEn
  );
input [4:0] address;
input [7:0] dataIn;
input writeEn; 
input strobe_i;
input clk;
input rst;
output [7:0] dataOut;
output SOFRxedIntOut;
output resetEventIntOut;
output resumeIntOut;
output transDoneIntOut;
output NAKSentIntOut;

input [1:0] endP0TransTypeReg;
input [1:0] endP0NAKTransTypeReg;
input [1:0] endP1TransTypeReg; 
input [1:0] endP1NAKTransTypeReg;
input [1:0] endP2TransTypeReg; 
input [1:0] endP2NAKTransTypeReg;
input [1:0] endP3TransTypeReg; 
input [1:0] endP3NAKTransTypeReg;
output [4:0] endP0ControlReg;
output [4:0] endP1ControlReg;
output [4:0] endP2ControlReg;
output [4:0] endP3ControlReg;
input [7:0] EP0StatusReg;
input [7:0] EP1StatusReg;
input [7:0] EP2StatusReg;
input [7:0] EP3StatusReg;
output [6:0] SCAddrReg;
input [10:0] frameNum;
input [1:0] connectStateIn;
input SOFRxedIn;
input resetEventIn;
input resumeIntIn;
input transDoneIn;
input NAKSentIn;
input slaveControlSelect;
input clrEP0Ready;
input clrEP1Ready;
input clrEP2Ready;
input clrEP3Ready;
output [1:0] TxLineState;
output LineDirectControlEn;
output fullSpeedPol; 
output fullSpeedRate;
output SCGlobalEn;

wire [4:0] address;
wire [7:0] dataIn;
wire writeEn;
wire strobe_i;
wire clk;
wire rst;
reg [7:0] dataOut;

reg SOFRxedIntOut;
reg resetEventIntOut;
reg resumeIntOut;
reg transDoneIntOut;
reg NAKSentIntOut;

wire [1:0] endP0TransTypeReg;
wire [1:0] endP0NAKTransTypeReg;
wire [1:0] endP1TransTypeReg; 
wire [1:0] endP1NAKTransTypeReg;
wire [1:0] endP2TransTypeReg; 
wire [1:0] endP2NAKTransTypeReg;
wire [1:0] endP3TransTypeReg; 
wire [1:0] endP3NAKTransTypeReg;
reg [4:0] endP0ControlReg;
reg [4:0] endP1ControlReg;
reg [4:0] endP2ControlReg;
reg [4:0] endP3ControlReg;
wire [7:0] EP0StatusReg;
wire [7:0] EP1StatusReg;
wire [7:0] EP2StatusReg;
wire [7:0] EP3StatusReg;
reg [6:0] SCAddrReg;
reg [3:0] TxEndPReg;
wire [10:0] frameNum;
wire [1:0] connectStateIn;

wire SOFRxedIn;
wire resetEventIn;
wire resumeIntIn;
wire transDoneIn;
wire NAKSentIn;
wire slaveControlSelect;
wire clrEP0Ready;
wire clrEP1Ready;
wire clrEP2Ready;
wire clrEP3Ready;
reg [1:0] TxLineState;
reg LineDirectControlEn;
reg fullSpeedPol; 
reg fullSpeedRate;
reg SCGlobalEn;

//internal wire and regs
reg [5:0] SCControlReg;
reg clrNAKReq;
reg clrSOFReq;
reg clrResetReq;
reg clrResInReq;
reg clrTransDoneReq;
reg SOFRxedInt;
reg resetEventInt;
reg resumeInt;
reg transDoneInt;
reg NAKSentInt;
reg [4:0] interruptMaskReg;
reg EP0SetReady;
reg EP1SetReady;
reg EP2SetReady;
reg EP3SetReady;
reg EP0SendStall;
reg EP1SendStall;
reg EP2SendStall;
reg EP3SendStall;
reg EP0IsoEn;
reg EP1IsoEn;
reg EP2IsoEn;
reg EP3IsoEn;
reg EP0DataSequence;
reg EP1DataSequence;
reg EP2DataSequence;
reg EP3DataSequence;
reg EP0Enable;
reg EP1Enable;
reg EP2Enable;
reg EP3Enable;
reg EP0Ready;
reg EP1Ready;
reg EP2Ready;
reg EP3Ready;


//sync write demux
always @(posedge clk)
begin   
  if (rst == 1'b1) begin
    EP0IsoEn <= 1'b0;
    EP0SendStall <= 1'b0;
    EP0DataSequence <= 1'b0;
    EP0Enable <= 1'b0;
    EP1IsoEn <= 1'b0;
    EP1SendStall <= 1'b0;
    EP1DataSequence <= 1'b0;
    EP1Enable <= 1'b0;
    EP2IsoEn <= 1'b0;
    EP2SendStall <= 1'b0;
    EP2DataSequence <= 1'b0;
    EP2Enable <= 1'b0;
    EP3IsoEn <= 1'b0;
    EP3SendStall <= 1'b0;
    EP3DataSequence <= 1'b0;
    EP3Enable <= 1'b0;
    SCControlReg <= 6'h00;
    SCAddrReg <= 7'h00;
    interruptMaskReg <= 5'h00;
  end
  else begin
    clrNAKReq <= 1'b0;
    clrSOFReq <= 1'b0;
    clrResetReq <= 1'b0;
    clrResInReq <= 1'b0;
    clrTransDoneReq <= 1'b0;
    EP0SetReady <= 1'b0;
    EP1SetReady <= 1'b0;
    EP2SetReady <= 1'b0;
    EP3SetReady <= 1'b0;
    if (writeEn == 1'b1 && strobe_i == 1'b1 && slaveControlSelect == 1'b1)
    begin
      case (address)
        `EP0_CTRL_REG : begin
          EP0IsoEn <= dataIn[`ENDPOINT_ISO_ENABLE_BIT];
          EP0SendStall <= dataIn[`ENDPOINT_SEND_STALL_BIT];
          EP0DataSequence <= dataIn[`ENDPOINT_OUTDATA_SEQUENCE_BIT];
          EP0SetReady <= dataIn[`ENDPOINT_READY_BIT];
          EP0Enable <= dataIn[`ENDPOINT_ENABLE_BIT];
        end
        `EP1_CTRL_REG : begin
          EP1IsoEn <= dataIn[`ENDPOINT_ISO_ENABLE_BIT];
          EP1SendStall <= dataIn[`ENDPOINT_SEND_STALL_BIT];
          EP1DataSequence <= dataIn[`ENDPOINT_OUTDATA_SEQUENCE_BIT];
          EP1SetReady <= dataIn[`ENDPOINT_READY_BIT];
          EP1Enable <= dataIn[`ENDPOINT_ENABLE_BIT];
        end
        `EP2_CTRL_REG : begin
          EP2IsoEn <= dataIn[`ENDPOINT_ISO_ENABLE_BIT];
          EP2SendStall <= dataIn[`ENDPOINT_SEND_STALL_BIT];
          EP2DataSequence <= dataIn[`ENDPOINT_OUTDATA_SEQUENCE_BIT];
          EP2SetReady <= dataIn[`ENDPOINT_READY_BIT];
          EP2Enable <= dataIn[`ENDPOINT_ENABLE_BIT];
        end
        `EP3_CTRL_REG : begin
          EP3IsoEn <= dataIn[`ENDPOINT_ISO_ENABLE_BIT];
          EP3SendStall <= dataIn[`ENDPOINT_SEND_STALL_BIT];
          EP3DataSequence <= dataIn[`ENDPOINT_OUTDATA_SEQUENCE_BIT];
          EP3SetReady <= dataIn[`ENDPOINT_READY_BIT];
          EP3Enable <= dataIn[`ENDPOINT_ENABLE_BIT];
        end
        `SC_CONTROL_REG : SCControlReg <= dataIn[5:0];
        `SC_ADDRESS : SCAddrReg <= dataIn[6:0];
        `SC_INTERRUPT_STATUS_REG : begin
          clrNAKReq <= dataIn[`NAK_SENT_INT_BIT];
          clrSOFReq <= dataIn[`SOF_RECEIVED_BIT];
          clrResetReq <= dataIn[`RESET_EVENT_BIT];
          clrResInReq <= dataIn[`RESUME_INT_BIT];
          clrTransDoneReq <= dataIn[`TRANS_DONE_BIT];
        end
        `SC_INTERRUPT_MASK_REG  : interruptMaskReg <= dataIn[4:0];
      endcase
    end
  end
end

//interrupt control 
always @(posedge clk)
begin
  if (rst == 1'b1) begin
    NAKSentInt <= 1'b0;
    SOFRxedInt <= 1'b0;
    resetEventInt <= 1'b0;
    resumeInt <= 1'b0;
    transDoneInt <= 1'b0;
  end
  else begin
    if (NAKSentIn == 1'b1)
      NAKSentInt <= 1'b1;
    else if (clrNAKReq == 1'b1)
      NAKSentInt <= 1'b0; 
    
    if (SOFRxedIn == 1'b1)
      SOFRxedInt <= 1'b1;
    else if (clrSOFReq == 1'b1)
      SOFRxedInt <= 1'b0;
    
    if (resetEventIn == 1'b1)
      resetEventInt <= 1'b1;
    else if (clrResetReq == 1'b1)
      resetEventInt <= 1'b0;
    
    if (resumeIntIn == 1'b1)
      resumeInt <= 1'b1;
    else if (clrResInReq == 1'b1)
      resumeInt <= 1'b0;  

    if (transDoneIn == 1'b1)
      transDoneInt <= 1'b1;
    else if (clrTransDoneReq == 1'b1)
      transDoneInt <= 1'b0;
  end
end

//mask interrupts
always @(interruptMaskReg or transDoneInt or resumeInt or resetEventInt or SOFRxedInt or NAKSentInt) begin
  transDoneIntOut <= transDoneInt & interruptMaskReg[`TRANS_DONE_BIT];
  resumeIntOut <= resumeInt & interruptMaskReg[`RESUME_INT_BIT];
  resetEventIntOut <= resetEventInt & interruptMaskReg[`RESET_EVENT_BIT];
  SOFRxedIntOut <= SOFRxedInt & interruptMaskReg[`SOF_RECEIVED_BIT];
  NAKSentIntOut <= NAKSentInt & interruptMaskReg[`NAK_SENT_INT_BIT];
end  

//end point ready, set/clear
always @(posedge clk)
begin
  if (rst == 1'b1) begin
    EP0Ready <= 1'b0;
    EP1Ready <= 1'b0;
    EP2Ready <= 1'b0;
    EP3Ready <= 1'b0;
  end
  else begin
    if (EP0SetReady == 1'b1)
      EP0Ready <= 1'b1;
    else if (clrEP0Ready == 1'b1)
      EP0Ready <= 1'b0;
    
    if (EP1SetReady == 1'b1)
      EP1Ready <= 1'b1;
    else if (clrEP1Ready == 1'b1)
      EP1Ready <= 1'b0;
    
    if (EP2SetReady == 1'b1)
      EP2Ready <= 1'b1;
    else if (clrEP2Ready == 1'b1)
      EP2Ready <= 1'b0;
    
    if (EP3SetReady == 1'b1)
      EP3Ready <= 1'b1;
    else if (clrEP3Ready == 1'b1)
      EP3Ready <= 1'b0;
  end
end  
  
//break out control signals
always @(SCControlReg) begin
  SCGlobalEn <= SCControlReg[`SC_GLOBAL_ENABLE_BIT];
  TxLineState <= SCControlReg[`SC_TX_LINE_STATE_MSBIT:`SC_TX_LINE_STATE_LSBIT];
  LineDirectControlEn <= SCControlReg[`SC_DIRECT_CONTROL_BIT];
  fullSpeedPol <= SCControlReg[`SC_FULL_SPEED_LINE_POLARITY_BIT]; 
  fullSpeedRate <= SCControlReg[`SC_FULL_SPEED_LINE_RATE_BIT];
end

//combine endpoint control signals 
always @(EP0IsoEn or EP0SendStall or EP0Ready or EP0DataSequence or EP0Enable or
  EP1IsoEn or EP1SendStall or EP1Ready or EP1DataSequence or EP1Enable or
  EP2IsoEn or EP2SendStall or EP2Ready or EP2DataSequence or EP2Enable or
  EP3IsoEn or EP3SendStall or EP3Ready or EP3DataSequence or EP3Enable) 
begin
  endP0ControlReg <= {EP0IsoEn, EP0SendStall, EP0DataSequence, EP0Ready, EP0Enable};
  endP1ControlReg <= {EP1IsoEn, EP1SendStall, EP1DataSequence, EP1Ready, EP1Enable};
  endP2ControlReg <= {EP2IsoEn, EP2SendStall, EP2DataSequence, EP2Ready, EP2Enable};
  endP3ControlReg <= {EP3IsoEn, EP3SendStall, EP3DataSequence, EP3Ready, EP3Enable};
end
      
      
      // async read mux
always @(address or
  EP0SendStall or EP0Ready or EP0DataSequence or EP0Enable or
  EP1SendStall or EP1Ready or EP1DataSequence or EP1Enable or
  EP2SendStall or EP2Ready or EP2DataSequence or EP2Enable or
  EP3SendStall or EP3Ready or EP3DataSequence or EP3Enable or
  EP0StatusReg or EP1StatusReg or EP2StatusReg or EP3StatusReg or
  endP0ControlReg or endP1ControlReg or endP2ControlReg or endP3ControlReg or
  endP0NAKTransTypeReg or endP1NAKTransTypeReg or endP2NAKTransTypeReg or endP3NAKTransTypeReg or 
  endP0TransTypeReg or endP1TransTypeReg or endP2TransTypeReg or endP3TransTypeReg or
  SCControlReg or connectStateIn or
  NAKSentInt or SOFRxedInt or resetEventInt or resumeInt or transDoneInt or
  interruptMaskReg or SCAddrReg or frameNum)
begin
  case (address)
      `EP0_CTRL_REG : dataOut <= endP0ControlReg;
      `EP0_STS_REG : dataOut <= EP0StatusReg;
      `EP0_TRAN_TYPE_STS_REG : dataOut <= endP0TransTypeReg;
      `EP0_NAK_TRAN_TYPE_STS_REG : dataOut <= endP0NAKTransTypeReg;
      `EP1_CTRL_REG : dataOut <= endP1ControlReg;
      `EP1_STS_REG :  dataOut <= EP1StatusReg;
      `EP1_TRAN_TYPE_STS_REG : dataOut <= endP1TransTypeReg;
      `EP1_NAK_TRAN_TYPE_STS_REG : dataOut <= endP1NAKTransTypeReg;
      `EP2_CTRL_REG : dataOut <= endP2ControlReg;
      `EP2_STS_REG :  dataOut <= EP2StatusReg;
      `EP2_TRAN_TYPE_STS_REG : dataOut <= endP2TransTypeReg;
      `EP2_NAK_TRAN_TYPE_STS_REG : dataOut <= endP2NAKTransTypeReg;
      `EP3_CTRL_REG : dataOut <= endP3ControlReg;
      `EP3_STS_REG :  dataOut <= EP3StatusReg;
      `EP3_TRAN_TYPE_STS_REG : dataOut <= endP3TransTypeReg;
      `EP3_NAK_TRAN_TYPE_STS_REG : dataOut <= endP3NAKTransTypeReg;
      `SC_CONTROL_REG : dataOut <= SCControlReg;
      `SC_LINE_STATUS_REG : dataOut <= {6'b000000, connectStateIn}; 
      `SC_INTERRUPT_STATUS_REG :  dataOut <= {3'b000, NAKSentInt, SOFRxedInt, resetEventInt, resumeInt, transDoneInt};
      `SC_INTERRUPT_MASK_REG  : dataOut <= {3'b000, interruptMaskReg};
      `SC_ADDRESS : dataOut <= {1'b0, SCAddrReg};
      `SC_FRAME_NUM_MSP : dataOut <= {5'b00000, frameNum[10:8]};
      `SC_FRAME_NUM_LSP : dataOut <= frameNum[7:0];
      default: dataOut <= 8'h00;
  endcase
end


endmodule