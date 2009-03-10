//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : 
// Company     : 
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\sendpacketarbiter.v
// Generated   : 09/10/04 20:20:24
// From        : c:\projects\USBHostSlave\RTL\hostController\sendpacketarbiter.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbConstants_h.v"

module sendPacketArbiter (HCTxGnt, HCTxReq, HC_PID, HC_SP_WEn, SOFTxGnt, SOFTxReq, SOF_SP_WEn, clk, rst, sendPacketPID, sendPacketWEnable);
input   HCTxReq;
input   [3:0] HC_PID;
input   HC_SP_WEn;
input   SOFTxReq;
input   SOF_SP_WEn;
input   clk;
input   rst;
output  HCTxGnt;
output  SOFTxGnt;
output  [3:0] sendPacketPID;
output  sendPacketWEnable;

reg     HCTxGnt, next_HCTxGnt;
wire    HCTxReq;
wire    [3:0] HC_PID;
wire    HC_SP_WEn;
reg     SOFTxGnt, next_SOFTxGnt;
wire    SOFTxReq;
wire    SOF_SP_WEn;
wire    clk;
wire    rst;
reg     [3:0] sendPacketPID, next_sendPacketPID;
reg     sendPacketWEnable, next_sendPacketWEnable;

// diagram signals declarations
reg muxSOFNotHC, next_muxSOFNotHC;

// BINARY ENCODED state machine: sendPktArb
// State codes definitions:
`define HC_ACT 2'b00
`define SOF_ACT 2'b01
`define SARB_WAIT_REQ 2'b10
`define START_SARB 2'b11

reg [1:0] CurrState_sendPktArb;
reg [1:0] NextState_sendPktArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// hostController/SOFTransmit mux
always @(muxSOFNotHC or SOF_SP_WEn or HC_SP_WEn or HC_PID)
begin
    if (muxSOFNotHC  == 1'b1)
    begin
        sendPacketWEnable <= SOF_SP_WEn;
        sendPacketPID <= `SOF;
    end
    else
    begin
        sendPacketWEnable <= HC_SP_WEn;
        sendPacketPID <= HC_PID;
    end
end


//--------------------------------------------------------------------
// Machine: sendPktArb
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (HCTxReq or SOFTxReq or HCTxGnt or SOFTxGnt or muxSOFNotHC or CurrState_sendPktArb)
begin : sendPktArb_NextState
	NextState_sendPktArb <= CurrState_sendPktArb;
	// Set default values for outputs and signals
	next_HCTxGnt <= HCTxGnt;
	next_SOFTxGnt <= SOFTxGnt;
	next_muxSOFNotHC <= muxSOFNotHC;
	case (CurrState_sendPktArb) // synopsys parallel_case full_case
		`HC_ACT:
			if (HCTxReq == 1'b0)	
			begin
				NextState_sendPktArb <= `SARB_WAIT_REQ;
				next_HCTxGnt <= 1'b0;
			end
		`SOF_ACT:
			if (SOFTxReq == 1'b0)	
			begin
				NextState_sendPktArb <= `SARB_WAIT_REQ;
				next_SOFTxGnt <= 1'b0;
			end
		`SARB_WAIT_REQ:
			if (SOFTxReq == 1'b1)	
			begin
				NextState_sendPktArb <= `SOF_ACT;
				next_SOFTxGnt <= 1'b1;
				next_muxSOFNotHC <= 1'b1;
			end
			else if (HCTxReq == 1'b1)	
			begin
				NextState_sendPktArb <= `HC_ACT;
				next_HCTxGnt <= 1'b1;
				next_muxSOFNotHC <= 1'b0;
			end
		`START_SARB:
			NextState_sendPktArb <= `SARB_WAIT_REQ;
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sendPktArb_CurrentState
	if (rst)	
		CurrState_sendPktArb <= `START_SARB;
	else
		CurrState_sendPktArb <= NextState_sendPktArb;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sendPktArb_RegOutput
	if (rst)	
	begin
		muxSOFNotHC <= 1'b0;
		SOFTxGnt <= 1'b0;
		HCTxGnt <= 1'b0;
	end
	else 
	begin
		muxSOFNotHC <= next_muxSOFNotHC;
		SOFTxGnt <= next_SOFTxGnt;
		HCTxGnt <= next_HCTxGnt;
	end
end

endmodule