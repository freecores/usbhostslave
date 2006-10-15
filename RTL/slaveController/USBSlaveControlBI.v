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
`include "timescale.v"
`include "usbSlaveControl_h.v"
 
module USBSlaveControlBI (address, dataIn, dataOut, writeEn,
  strobe_i,
  busClk, 
  rstSyncToBusClk,
  usbClk, 
  rstSyncToUsbClk,
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
input busClk; 
input rstSyncToBusClk;
input usbClk; 
input rstSyncToUsbClk;
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
wire busClk; 
wire rstSyncToBusClk;
wire usbClk; 
wire rstSyncToUsbClk;
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

//clock domain crossing sync registers
//STB = Sync To Busclk
reg [4:0] endP0ControlRegSTB;
reg [4:0] endP1ControlRegSTB;
reg [4:0] endP2ControlRegSTB;
reg [4:0] endP3ControlRegSTB;
reg NAKSentInSTB;
reg SOFRxedInSTB;
reg resetEventInSTB;
reg resumeIntInSTB;
reg transDoneInSTB;
reg clrEP0ReadySTB;
reg clrEP1ReadySTB;
reg clrEP2ReadySTB;
reg clrEP3ReadySTB;
reg SCGlobalEnSTB;
reg [1:0] TxLineStateSTB;
reg LineDirectControlEnSTB;
reg fullSpeedPolSTB; 
reg fullSpeedRateSTB;
reg [7:0] EP0StatusRegSTB;
reg [7:0] EP1StatusRegSTB;
reg [7:0] EP2StatusRegSTB;
reg [7:0] EP3StatusRegSTB;
reg [1:0] endP0TransTypeRegSTB;
reg [1:0] endP0NAKTransTypeRegSTB;
reg [1:0] endP1TransTypeRegSTB; 
reg [1:0] endP1NAKTransTypeRegSTB;
reg [1:0] endP2TransTypeRegSTB; 
reg [1:0] endP2NAKTransTypeRegSTB;
reg [1:0] endP3TransTypeRegSTB; 
reg [1:0] endP3NAKTransTypeRegSTB;
reg [10:0] frameNumSTB;

  
//sync write demux
always @(posedge busClk)
begin   
  if (rstSyncToBusClk == 1'b1) begin
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
always @(posedge busClk)
begin
  if (rstSyncToBusClk == 1'b1) begin
    NAKSentInt <= 1'b0;
    SOFRxedInt <= 1'b0;
    resetEventInt <= 1'b0;
    resumeInt <= 1'b0;
    transDoneInt <= 1'b0;
  end
  else begin
    if (NAKSentInSTB == 1'b1)
      NAKSentInt <= 1'b1;
    else if (clrNAKReq == 1'b1)
      NAKSentInt <= 1'b0; 
    
    if (SOFRxedInSTB == 1'b1)
      SOFRxedInt <= 1'b1;
    else if (clrSOFReq == 1'b1)
      SOFRxedInt <= 1'b0;
    
    if (resetEventInSTB == 1'b1)
      resetEventInt <= 1'b1;
    else if (clrResetReq == 1'b1)
      resetEventInt <= 1'b0;
    
    if (resumeIntInSTB == 1'b1)
      resumeInt <= 1'b1;
    else if (clrResInReq == 1'b1)
      resumeInt <= 1'b0;  

    if (transDoneInSTB == 1'b1)
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
//Since 'busClk' can be a higher freq than 'usbClk',
//'EP0SetReady' etc must be delayed with respect to other control signals, thus
//ensuring that control signals have been clocked through to 'usbClk' clock
//domain before the ready is asserted.
//Not sure this is required because there is at least two 'usbClk' ticks between
//detection of 'EP0Ready' and sampling of related control signals.always @(posedge busClk)
always @(posedge busClk)
begin
  if (rstSyncToBusClk == 1'b1) begin
    EP0Ready <= 1'b0;
    EP1Ready <= 1'b0;
    EP2Ready <= 1'b0;
    EP3Ready <= 1'b0;
  end
  else begin
    if (EP0SetReady == 1'b1)
      EP0Ready <= 1'b1;
    else if (clrEP0ReadySTB == 1'b1)
      EP0Ready <= 1'b0;
    
    if (EP1SetReady == 1'b1)
      EP1Ready <= 1'b1;
    else if (clrEP1ReadySTB == 1'b1)
      EP1Ready <= 1'b0;
    
    if (EP2SetReady == 1'b1)
      EP2Ready <= 1'b1;
    else if (clrEP2ReadySTB == 1'b1)
      EP2Ready <= 1'b0;
    
    if (EP3SetReady == 1'b1)
      EP3Ready <= 1'b1;
    else if (clrEP3ReadySTB == 1'b1)
      EP3Ready <= 1'b0;
  end
end  
  
//break out control signals
always @(SCControlReg) begin
  SCGlobalEnSTB <= SCControlReg[`SC_GLOBAL_ENABLE_BIT];
  TxLineStateSTB <= SCControlReg[`SC_TX_LINE_STATE_MSBIT:`SC_TX_LINE_STATE_LSBIT];
  LineDirectControlEnSTB <= SCControlReg[`SC_DIRECT_CONTROL_BIT];
  fullSpeedPolSTB <= SCControlReg[`SC_FULL_SPEED_LINE_POLARITY_BIT]; 
  fullSpeedRateSTB <= SCControlReg[`SC_FULL_SPEED_LINE_RATE_BIT];
end

//combine endpoint control signals 
always @(EP0IsoEn or EP0SendStall or EP0Ready or EP0DataSequence or EP0Enable or
  EP1IsoEn or EP1SendStall or EP1Ready or EP1DataSequence or EP1Enable or
  EP2IsoEn or EP2SendStall or EP2Ready or EP2DataSequence or EP2Enable or
  EP3IsoEn or EP3SendStall or EP3Ready or EP3DataSequence or EP3Enable) 
begin
  endP0ControlRegSTB <= {EP0IsoEn, EP0SendStall, EP0DataSequence, EP0Ready, EP0Enable};
  endP1ControlRegSTB <= {EP1IsoEn, EP1SendStall, EP1DataSequence, EP1Ready, EP1Enable};
  endP2ControlRegSTB <= {EP2IsoEn, EP2SendStall, EP2DataSequence, EP2Ready, EP2Enable};
  endP3ControlRegSTB <= {EP3IsoEn, EP3SendStall, EP3DataSequence, EP3Ready, EP3Enable};
end
      
      
// async read mux
// FIX ME
// Not sure why 'EP0SendStall' etc are in sensitivity list. May be related to
// some translation bug
always @(address or
  EP0SendStall or EP0Ready or EP0DataSequence or EP0Enable or
  EP1SendStall or EP1Ready or EP1DataSequence or EP1Enable or
  EP2SendStall or EP2Ready or EP2DataSequence or EP2Enable or
  EP3SendStall or EP3Ready or EP3DataSequence or EP3Enable or
  EP0StatusRegSTB or EP1StatusRegSTB or EP2StatusRegSTB or EP3StatusRegSTB or
  endP0ControlRegSTB or endP1ControlRegSTB or endP2ControlRegSTB or endP3ControlRegSTB or
  endP0NAKTransTypeRegSTB or endP1NAKTransTypeRegSTB or endP2NAKTransTypeRegSTB or endP3NAKTransTypeRegSTB or 
  endP0TransTypeRegSTB or endP1TransTypeRegSTB or endP2TransTypeRegSTB or endP3TransTypeRegSTB or
  SCControlReg or connectStateIn or
  NAKSentInt or SOFRxedInt or resetEventInt or resumeInt or transDoneInt or
  interruptMaskReg or SCAddrReg or frameNumSTB)
begin
  case (address)
      `EP0_CTRL_REG : dataOut <= endP0ControlRegSTB;
      `EP0_STS_REG : dataOut <= EP0StatusRegSTB;
      `EP0_TRAN_TYPE_STS_REG : dataOut <= endP0TransTypeRegSTB;
      `EP0_NAK_TRAN_TYPE_STS_REG : dataOut <= endP0NAKTransTypeRegSTB;
      `EP1_CTRL_REG : dataOut <= endP1ControlRegSTB;
      `EP1_STS_REG :  dataOut <= EP1StatusRegSTB;
      `EP1_TRAN_TYPE_STS_REG : dataOut <= endP1TransTypeRegSTB;
      `EP1_NAK_TRAN_TYPE_STS_REG : dataOut <= endP1NAKTransTypeRegSTB;
      `EP2_CTRL_REG : dataOut <= endP2ControlRegSTB;
      `EP2_STS_REG :  dataOut <= EP2StatusRegSTB;
      `EP2_TRAN_TYPE_STS_REG : dataOut <= endP2TransTypeRegSTB;
      `EP2_NAK_TRAN_TYPE_STS_REG : dataOut <= endP2NAKTransTypeRegSTB;
      `EP3_CTRL_REG : dataOut <= endP3ControlRegSTB;
      `EP3_STS_REG :  dataOut <= EP3StatusRegSTB;
      `EP3_TRAN_TYPE_STS_REG : dataOut <= endP3TransTypeRegSTB;
      `EP3_NAK_TRAN_TYPE_STS_REG : dataOut <= endP3NAKTransTypeRegSTB;
      `SC_CONTROL_REG : dataOut <= SCControlReg;
      `SC_LINE_STATUS_REG : dataOut <= {6'b000000, connectStateIn}; 
      `SC_INTERRUPT_STATUS_REG :  dataOut <= {3'b000, NAKSentInt, SOFRxedInt, resetEventInt, resumeInt, transDoneInt};
      `SC_INTERRUPT_MASK_REG  : dataOut <= {3'b000, interruptMaskReg};
      `SC_ADDRESS : dataOut <= {1'b0, SCAddrReg};
      `SC_FRAME_NUM_MSP : dataOut <= {5'b00000, frameNumSTB[10:8]};
      `SC_FRAME_NUM_LSP : dataOut <= frameNumSTB[7:0];
      default: dataOut <= 8'h00;
  endcase
end

//re-sync from busClk to usbClk. 
always @(posedge usbClk) begin
  endP0ControlReg <= endP0ControlRegSTB;
  endP1ControlReg <= endP1ControlRegSTB;
  endP2ControlReg <= endP2ControlRegSTB;
  endP3ControlReg <= endP3ControlRegSTB;
  SCGlobalEn <= SCGlobalEnSTB;
  TxLineState <= TxLineStateSTB;
  LineDirectControlEn <= LineDirectControlEnSTB;
  fullSpeedPol <= fullSpeedPolSTB; 
  fullSpeedRate <= fullSpeedRateSTB;
end

//re-sync from usbClk to busClk. Since 'NAKSentIn', 'SOFRxedIn' etc are only asserted 
//for one 'usbClk' tick, busClk freq must be greater than or equal to usbClk freq
always @(posedge busClk) begin
  NAKSentInSTB <= NAKSentIn;
  SOFRxedInSTB <= SOFRxedIn;
  resetEventInSTB <= resetEventIn;
  resumeIntInSTB <= resumeIntIn;
  transDoneInSTB <= transDoneIn;
  clrEP0ReadySTB <= clrEP0Ready;
  clrEP1ReadySTB <= clrEP1Ready;
  clrEP2ReadySTB <= clrEP2Ready;
  clrEP3ReadySTB <= clrEP3Ready;
  EP0StatusRegSTB <= EP0StatusReg;
  EP1StatusRegSTB <= EP1StatusReg;
  EP2StatusRegSTB <= EP2StatusReg;
  EP3StatusRegSTB <= EP3StatusReg;
  endP0TransTypeRegSTB <= endP0TransTypeReg;
  endP1TransTypeRegSTB <= endP1TransTypeReg;
  endP2TransTypeRegSTB <= endP2TransTypeReg;
  endP3TransTypeRegSTB <= endP3TransTypeReg;
  endP0NAKTransTypeRegSTB <= endP0NAKTransTypeReg;
  endP1NAKTransTypeRegSTB <= endP1NAKTransTypeReg;
  endP2NAKTransTypeRegSTB <= endP2NAKTransTypeReg;
  endP3NAKTransTypeRegSTB <= endP3NAKTransTypeReg;
  frameNumSTB <= frameNum;
end

endmodule
