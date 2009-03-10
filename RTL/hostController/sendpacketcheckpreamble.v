//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : 
// Company     : 
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\sendpacketcheckpreamble.v
// Generated   : 09/10/04 20:20:24
// From        : c:\projects\USBHostSlave\RTL\hostController\sendpacketcheckpreamble.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbConstants_h.v"

module sendPacketCheckPreamble (clk, fullSpeedBitRate, fullSpeedPolarity, grabLineControl, preAmbleEnable, rst, sendPacketCPPID, sendPacketCPReady, sendPacketCPWEn, sendPacketPID, sendPacketRdy, sendPacketWEn);
input   clk;
input   preAmbleEnable;
input   rst;
input   [3:0] sendPacketCPPID;
input   sendPacketCPWEn;
input   sendPacketRdy;
output  fullSpeedBitRate;
output  fullSpeedPolarity;
output  grabLineControl;		// mux select
output  sendPacketCPReady;
output  [3:0] sendPacketPID;
output  sendPacketWEn;

wire    clk;
reg     fullSpeedBitRate, next_fullSpeedBitRate;
reg     fullSpeedPolarity, next_fullSpeedPolarity;
reg     grabLineControl, next_grabLineControl;
wire    preAmbleEnable;
wire    rst;
wire    [3:0] sendPacketCPPID;
reg     sendPacketCPReady, next_sendPacketCPReady;
wire    sendPacketCPWEn;
reg     [3:0] sendPacketPID, next_sendPacketPID;
wire    sendPacketRdy;
reg     sendPacketWEn, next_sendPacketWEn;

// BINARY ENCODED state machine: sendPktCP
// State codes definitions:
`define SPC_WAIT_EN 4'b0000
`define START_SPC 4'b0001
`define CHK_PREAM 4'b0010
`define PREAM_PKT_SND_PREAM 4'b0011
`define PREAM_PKT_WAIT_RDY1 4'b0100
`define PREAM_PKT_WAIT_RDY2 4'b0101
`define PREAM_PKT_SND_PID 4'b0110
`define PREAM_PKT_WAIT_RDY3 4'b0111
`define REG_PKT_SEND_PID 4'b1000
`define REG_PKT_WAIT_RDY1 4'b1001
`define REG_PKT_WAIT_RDY 4'b1010
`define READY 4'b1011

reg [3:0] CurrState_sendPktCP;
reg [3:0] NextState_sendPktCP;


//--------------------------------------------------------------------
// Machine: sendPktCP
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (sendPacketCPPID or sendPacketCPWEn or preAmbleEnable or sendPacketRdy or sendPacketCPReady or sendPacketWEn or sendPacketPID or fullSpeedBitRate or fullSpeedPolarity or grabLineControl or CurrState_sendPktCP)
begin : sendPktCP_NextState
	NextState_sendPktCP <= CurrState_sendPktCP;
	// Set default values for outputs and signals
	next_sendPacketCPReady <= sendPacketCPReady;
	next_sendPacketWEn <= sendPacketWEn;
	next_sendPacketPID <= sendPacketPID;
	next_fullSpeedBitRate <= fullSpeedBitRate;
	next_fullSpeedPolarity <= fullSpeedPolarity;
	next_grabLineControl <= grabLineControl;
	case (CurrState_sendPktCP) // synopsys parallel_case full_case
		`SPC_WAIT_EN:
			if (sendPacketCPWEn == 1'b1)	
			begin
				NextState_sendPktCP <= `CHK_PREAM;
				next_sendPacketCPReady <= 1'b0;
			end
		`START_SPC:
			NextState_sendPktCP <= `SPC_WAIT_EN;
		`CHK_PREAM:
			if (preAmbleEnable == 1'b1)	
				NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY1;
			else
				NextState_sendPktCP <= `REG_PKT_WAIT_RDY1;
		`READY:
		begin
			next_sendPacketCPReady <= 1'b1;
			NextState_sendPktCP <= `SPC_WAIT_EN;
		end
		`PREAM_PKT_SND_PREAM:
		begin
			next_sendPacketWEn <= 1'b1;
			next_sendPacketPID <= `PREAMBLE;
			NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY2;
			next_sendPacketWEn <= 1'b0;
		end
		`PREAM_PKT_WAIT_RDY1:
			if (sendPacketRdy == 1'b1)	
			begin
				NextState_sendPktCP <= `PREAM_PKT_SND_PREAM;
				next_fullSpeedBitRate <= 1'b1;
				next_fullSpeedPolarity <= 1'b1;
				next_grabLineControl <= 1'b1;
			end
		`PREAM_PKT_WAIT_RDY2:
			if (sendPacketRdy == 1'b1)	
			begin
				NextState_sendPktCP <= `PREAM_PKT_SND_PID;
				next_fullSpeedBitRate <= 1'b1;
			end
		`PREAM_PKT_SND_PID:
		begin
			next_sendPacketWEn <= 1'b1;
			next_sendPacketPID <= sendPacketCPPID;
			NextState_sendPktCP <= `PREAM_PKT_WAIT_RDY3;
			next_sendPacketWEn <= 1'b0;
		end
		`PREAM_PKT_WAIT_RDY3:
			if (sendPacketRdy == 1'b1)	
			begin
				NextState_sendPktCP <= `READY;
				next_grabLineControl <= 1'b0;
			end
		`REG_PKT_SEND_PID:
		begin
			next_sendPacketWEn <= 1'b1;
			next_sendPacketPID <= sendPacketCPPID;
			NextState_sendPktCP <= `REG_PKT_WAIT_RDY;
		end
		`REG_PKT_WAIT_RDY1:
			if (sendPacketRdy == 1'b1)	
				NextState_sendPktCP <= `REG_PKT_SEND_PID;
		`REG_PKT_WAIT_RDY:
		begin
			next_sendPacketWEn <= 1'b0;
			NextState_sendPktCP <= `READY;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sendPktCP_CurrentState
	if (rst)	
		CurrState_sendPktCP <= `START_SPC;
	else
		CurrState_sendPktCP <= NextState_sendPktCP;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sendPktCP_RegOutput
	if (rst)	
	begin
		sendPacketWEn <= 1'b0;
		sendPacketPID <= 4'b0;
		fullSpeedBitRate <= 1'b0;
		fullSpeedPolarity <= 1'b0;
		grabLineControl <= 1'b0;
		sendPacketCPReady <= 1'b1;
	end
	else 
	begin
		sendPacketWEn <= next_sendPacketWEn;
		sendPacketPID <= next_sendPacketPID;
		fullSpeedBitRate <= next_fullSpeedBitRate;
		fullSpeedPolarity <= next_fullSpeedPolarity;
		grabLineControl <= next_grabLineControl;
		sendPacketCPReady <= next_sendPacketCPReady;
	end
end

endmodule