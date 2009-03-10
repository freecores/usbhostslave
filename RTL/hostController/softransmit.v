//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : 
// Company     : 
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\softransmit.v
// Generated   : 09/14/04 21:51:27
// From        : c:\projects\USBHostSlave\RTL\hostController\softransmit.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbHostControl_h.v"


module SOFTransmit (SOFEnable, SOFSent, SOFSyncEn, SOFTimerClr, SOFTimer, clk, rst, sendPacketArbiterGnt, sendPacketArbiterReq, sendPacketRdy, sendPacketWEn);
input   SOFEnable;		// After host software asserts SOFEnable, must wait TBD time before asserting SOFSyncEn
input   SOFSyncEn;
input   [15:0] SOFTimer;
input   clk;
input   rst;
input   sendPacketArbiterGnt;
input   sendPacketRdy;
output  SOFSent;		// single cycle pulse
output  SOFTimerClr;		// Single cycle pulse
output  sendPacketArbiterReq;
output  sendPacketWEn;

wire    SOFEnable;
reg     SOFSent, next_SOFSent;
wire    SOFSyncEn;
reg     SOFTimerClr, next_SOFTimerClr;
wire    [15:0] SOFTimer;
wire    clk;
wire    rst;
wire    sendPacketArbiterGnt;
reg     sendPacketArbiterReq, next_sendPacketArbiterReq;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;

// BINARY ENCODED state machine: SOFTx
// State codes definitions:
`define START_STX 3'b000
`define WAIT_SOF_NEAR 3'b001
`define WAIT_SP_GNT 3'b010
`define WAIT_SOF_NOW 3'b011
`define SOF_FIN 3'b100

reg [2:0] CurrState_SOFTx;
reg [2:0] NextState_SOFTx;


//--------------------------------------------------------------------
// Machine: SOFTx
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (SOFTimer or SOFSyncEn or SOFEnable or sendPacketArbiterGnt or sendPacketRdy or sendPacketArbiterReq or sendPacketWEn or SOFTimerClr or SOFSent or CurrState_SOFTx)
begin : SOFTx_NextState
	NextState_SOFTx <= CurrState_SOFTx;
	// Set default values for outputs and signals
	next_sendPacketArbiterReq <= sendPacketArbiterReq;
	next_sendPacketWEn <= sendPacketWEn;
	next_SOFTimerClr <= SOFTimerClr;
	next_SOFSent <= SOFSent;
	case (CurrState_SOFTx) // synopsys parallel_case full_case
		`START_STX:
			NextState_SOFTx <= `WAIT_SOF_NEAR;
		`WAIT_SOF_NEAR:
			if (SOFTimer >= `SOF_TX_TIME - `SOF_TX_MARGIN ||
				(SOFSyncEn == 1'b1 &&
				SOFEnable == 1'b1))	
			begin
				NextState_SOFTx <= `WAIT_SP_GNT;
				next_sendPacketArbiterReq <= 1'b1;
			end
		`WAIT_SP_GNT:
			if (sendPacketArbiterGnt == 1'b1 && sendPacketRdy == 1'b1)	
				NextState_SOFTx <= `WAIT_SOF_NOW;
		`WAIT_SOF_NOW:
			if (SOFTimer >= `SOF_TX_TIME)	
			begin
				NextState_SOFTx <= `SOF_FIN;
				next_sendPacketWEn <= 1'b1;
				next_SOFTimerClr <= 1'b1;
				next_SOFSent <= 1'b1;
			end
			else if (SOFEnable == 1'b0)	
			begin
				NextState_SOFTx <= `SOF_FIN;
				next_SOFTimerClr <= 1'b1;
			end
		`SOF_FIN:
		begin
			next_sendPacketWEn <= 1'b0;
			next_SOFTimerClr <= 1'b0;
			next_SOFSent <= 1'b0;
			NextState_SOFTx <= `WAIT_SOF_NEAR;
			next_sendPacketArbiterReq <= 1'b0;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : SOFTx_CurrentState
	if (rst)	
		CurrState_SOFTx <= `START_STX;
	else
		CurrState_SOFTx <= NextState_SOFTx;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : SOFTx_RegOutput
	if (rst)	
	begin
		SOFSent <= 1'b0;
		SOFTimerClr <= 1'b0;
		sendPacketArbiterReq <= 1'b0;
		sendPacketWEn <= 1'b0;
	end
	else 
	begin
		SOFSent <= next_SOFSent;
		SOFTimerClr <= next_SOFTimerClr;
		sendPacketArbiterReq <= next_sendPacketArbiterReq;
		sendPacketWEn <= next_sendPacketWEn;
	end
end

endmodule