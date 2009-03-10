//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : 
// Company     : 
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\usbTxWireArbiter.v
// Generated   : 06/05/04 05:53:14
// From        : c:\projects\USBHostSlave\RTL\serialInterfaceEngine\usbTxWireArbiter.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbConstants_h.v"

module USBWireTxArbiter (SIETxCtrl, SIETxData, SIETxGnt, SIETxReq, SIETxWEn, TxBits, TxCtl, USBWireRdyIn, USBWireRdyOut, USBWireWEn, clk, prcTxByteCtrl, prcTxByteData, prcTxByteGnt, prcTxByteReq, prcTxByteWEn, rst);
input   SIETxCtrl;
input   [1:0] SIETxData;
input   SIETxReq;
input   SIETxWEn;
input   USBWireRdyIn;
input   clk;
input   prcTxByteCtrl;
input   [1:0] prcTxByteData;
input   prcTxByteReq;
input   prcTxByteWEn;
input   rst;
output  SIETxGnt;
output  [1:0] TxBits;
output  TxCtl;
output  USBWireRdyOut;
output  USBWireWEn;
output  prcTxByteGnt;

wire    SIETxCtrl;
wire    [1:0] SIETxData;
reg     SIETxGnt, next_SIETxGnt;
wire    SIETxReq;
wire    SIETxWEn;
reg     [1:0] TxBits, next_TxBits;
reg     TxCtl, next_TxCtl;
wire    USBWireRdyIn;
reg     USBWireRdyOut, next_USBWireRdyOut;
reg     USBWireWEn, next_USBWireWEn;
wire    clk;
wire    prcTxByteCtrl;
wire    [1:0] prcTxByteData;
reg     prcTxByteGnt, next_prcTxByteGnt;
wire    prcTxByteReq;
wire    prcTxByteWEn;
wire    rst;

// diagram signals declarations
reg muxSIENotPTXB, next_muxSIENotPTXB;

// BINARY ENCODED state machine: txWireArb
// State codes definitions:
`define START_TARB 2'b00
`define TARB_WAIT_REQ 2'b01
`define PTXB_ACT 2'b10
`define SIE_TX_ACT 2'b11

reg [1:0] CurrState_txWireArb;
reg [1:0] NextState_txWireArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// processTxByte/SIETransmitter mux
always @(USBWireRdyIn)
begin
    USBWireRdyOut <= USBWireRdyIn;
end
always @(muxSIENotPTXB or SIETxWEn or SIETxData or
SIETxCtrl or prcTxByteWEn or prcTxByteData or prcTxByteCtrl)
begin
    if (muxSIENotPTXB  == 1'b1)
    begin
        USBWireWEn <= SIETxWEn;
        TxBits <= SIETxData;
        TxCtl <= SIETxCtrl;
    end
    else
    begin
        USBWireWEn <= prcTxByteWEn;
        TxBits <= prcTxByteData;
        TxCtl <= prcTxByteCtrl;
    end
end


//--------------------------------------------------------------------
// Machine: txWireArb
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (prcTxByteReq or SIETxReq or prcTxByteGnt or muxSIENotPTXB or SIETxGnt or CurrState_txWireArb)
begin : txWireArb_NextState
	NextState_txWireArb <= CurrState_txWireArb;
	// Set default values for outputs and signals
	next_prcTxByteGnt <= prcTxByteGnt;
	next_muxSIENotPTXB <= muxSIENotPTXB;
	next_SIETxGnt <= SIETxGnt;
	case (CurrState_txWireArb) // synopsys parallel_case full_case
		`START_TARB:
			NextState_txWireArb <= `TARB_WAIT_REQ;
		`TARB_WAIT_REQ:
			if (prcTxByteReq == 1'b1)	
			begin
				NextState_txWireArb <= `PTXB_ACT;
				next_prcTxByteGnt <= 1'b1;
				next_muxSIENotPTXB <= 1'b0;
			end
			else if (SIETxReq == 1'b1)	
			begin
				NextState_txWireArb <= `SIE_TX_ACT;
				next_SIETxGnt <= 1'b1;
				next_muxSIENotPTXB <= 1'b1;
			end
		`PTXB_ACT:
			if (prcTxByteReq == 1'b0)	
			begin
				NextState_txWireArb <= `TARB_WAIT_REQ;
				next_prcTxByteGnt <= 1'b0;
			end
		`SIE_TX_ACT:
			if (SIETxReq == 1'b0)	
			begin
				NextState_txWireArb <= `TARB_WAIT_REQ;
				next_SIETxGnt <= 1'b0;
			end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : txWireArb_CurrentState
	if (rst)	
		CurrState_txWireArb <= `START_TARB;
	else
		CurrState_txWireArb <= NextState_txWireArb;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : txWireArb_RegOutput
	if (rst)	
	begin
		muxSIENotPTXB <= 1'b0;
		prcTxByteGnt <= 1'b0;
		SIETxGnt <= 1'b0;
	end
	else 
	begin
		muxSIENotPTXB <= next_muxSIENotPTXB;
		prcTxByteGnt <= next_prcTxByteGnt;
		SIETxGnt <= next_SIETxGnt;
	end
end

endmodule