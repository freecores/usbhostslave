//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\siereceiver.v
// Generated   : 09/06/04 06:18:21
// From        : c:\projects\USBHostSlave\RTL\serialInterfaceEngine\siereceiver.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"


module SIEReceiver (RxBitsOut, RxWireDataIn, RxWireDataWEn, SIERxRdyOut, clk, connectState, processRxBitRdyIn, processRxBitsWEn, rst);
input   [1:0] RxWireDataIn;
input   RxWireDataWEn;
input   clk;
input   processRxBitRdyIn;
input   rst;
output  [1:0] RxBitsOut;
output  SIERxRdyOut;
output  [1:0] connectState;
output  processRxBitsWEn;

reg     [1:0] RxBitsOut, next_RxBitsOut;
wire    [1:0] RxWireDataIn;
wire    RxWireDataWEn;
reg     SIERxRdyOut, next_SIERxRdyOut;
wire    clk;
reg     [1:0] connectState, next_connectState;
wire    processRxBitRdyIn;
reg     processRxBitsWEn, next_processRxBitsWEn;
wire    rst;

// diagram signals declarations
reg  [3:0]RXStMachCurrState, next_RXStMachCurrState;
reg  [7:0]RXWaitCount, next_RXWaitCount;
reg  [1:0]RxBits, next_RxBits;

// BINARY ENCODED state machine: rcvr
// State codes definitions:
`define WAIT_FS_CONN_CHK_RX_BITS 4'b0000
`define WAIT_LS_CONN_CHK_RX_BITS 4'b0001
`define LS_CONN_CHK_RX_BITS 4'b0010
`define DISCNCT_CHK_RXBITS 4'b0011
`define WAIT_BIT 4'b0100
`define START_SRX 4'b0101
`define LS_CONN_PROC_RX_BITS 4'b0110
`define FS_CONN_CHK_RX_BITS1 4'b0111
`define WAIT_LS_DIS_CHK_RX_BITS 4'b1000
`define WAIT_LS_DIS_PROC_RX_BITS 4'b1001
`define WAIT_FS_DIS_PROC_RX_BITS2 4'b1010
`define WAIT_FS_DIS_CHK_RX_BITS2 4'b1011
`define FS_CONN_PROC_RX_BITS1 4'b1100

reg [3:0] CurrState_rcvr;
reg [3:0] NextState_rcvr;


//--------------------------------------------------------------------
// Machine: rcvr
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (RxWireDataIn or RxBits or RXWaitCount or RxWireDataWEn or RXStMachCurrState or processRxBitRdyIn or SIERxRdyOut or connectState or RxBitsOut or processRxBitsWEn or CurrState_rcvr)
begin : rcvr_NextState
	NextState_rcvr <= CurrState_rcvr;
	// Set default values for outputs and signals
	next_RxBits <= RxBits;
	next_SIERxRdyOut <= SIERxRdyOut;
	next_RXStMachCurrState <= RXStMachCurrState;
	next_RXWaitCount <= RXWaitCount;
	next_connectState <= connectState;
	next_RxBitsOut <= RxBitsOut;
	next_processRxBitsWEn <= processRxBitsWEn;
	case (CurrState_rcvr) // synopsys parallel_case full_case
		`WAIT_BIT:
			if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_LOW_SP_DISCONNECT_ST))	
			begin
				NextState_rcvr <= `WAIT_LS_DIS_CHK_RX_BITS;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `CONNECT_FULL_SPEED_ST))	
			begin
				NextState_rcvr <= `FS_CONN_CHK_RX_BITS1;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `CONNECT_LOW_SPEED_ST))	
			begin
				NextState_rcvr <= `LS_CONN_CHK_RX_BITS;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_LOW_SPEED_CONN_ST))	
			begin
				NextState_rcvr <= `WAIT_LS_CONN_CHK_RX_BITS;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_FULL_SPEED_CONN_ST))	
			begin
				NextState_rcvr <= `WAIT_FS_CONN_CHK_RX_BITS;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `DISCONNECT_ST))	
			begin
				NextState_rcvr <= `DISCNCT_CHK_RXBITS;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
			else if ((RxWireDataWEn == 1'b1) && (RXStMachCurrState == `WAIT_FULL_SP_DISCONNECT_ST))	
			begin
				NextState_rcvr <= `WAIT_FS_DIS_CHK_RX_BITS2;
				next_RxBits <= RxWireDataIn;
				next_SIERxRdyOut <= 1'b0;
			end
		`START_SRX:
		begin
			next_RXStMachCurrState <= `DISCONNECT_ST;
			next_RXWaitCount <= 8'h00;
			next_connectState <= `DISCONNECT;
			next_RxBits <= 2'b00;
			next_RxBitsOut <= 2'b00;
			next_processRxBitsWEn <= 1'b0;
			next_SIERxRdyOut <= 1'b1;
			NextState_rcvr <= `WAIT_BIT;
		end
		`DISCNCT_CHK_RXBITS:
			if (RxBits == `ZERO_ONE)	
			begin
				NextState_rcvr <= `WAIT_BIT;
				next_RXStMachCurrState <= `WAIT_LOW_SPEED_CONN_ST;
				next_RXWaitCount <= 8'h00;
				next_SIERxRdyOut <= 1'b1;
			end
			else if (RxBits == `ONE_ZERO)	
			begin
				NextState_rcvr <= `WAIT_BIT;
				next_RXStMachCurrState <= `WAIT_FULL_SPEED_CONN_ST;
				next_RXWaitCount <= 8'h00;
				next_SIERxRdyOut <= 1'b1;
			end
			else
			begin
				NextState_rcvr <= `WAIT_BIT;
				next_SIERxRdyOut <= 1'b1;
			end
		`WAIT_FS_CONN_CHK_RX_BITS:
		begin
			if (RxBits == `ONE_ZERO)
			begin
			  next_RXWaitCount <= RXWaitCount + 1'b1;
			    if (RXWaitCount == `CONNECT_WAIT_TIME)
			    begin
			    next_connectState <= `FULL_SPEED_CONNECT;
			    next_RXStMachCurrState <= `CONNECT_FULL_SPEED_ST;
			    end
			end
			else
			begin
			  next_RXStMachCurrState = `DISCONNECT_ST;
			end
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`WAIT_LS_CONN_CHK_RX_BITS:
		begin
			if (RxBits == `ZERO_ONE)
			begin
			  next_RXWaitCount <= RXWaitCount + 1'b1;
			    if (RXWaitCount == `CONNECT_WAIT_TIME)
			    begin
			    next_connectState <= `LOW_SPEED_CONNECT;
			    next_RXStMachCurrState <= `CONNECT_LOW_SPEED_ST;
			    end
			end
			else
			begin
			  next_RXStMachCurrState = `DISCONNECT_ST;
			end
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`LS_CONN_CHK_RX_BITS:
			if (processRxBitRdyIn == 1'b1)	
			begin
				NextState_rcvr <= `LS_CONN_PROC_RX_BITS;
				if (RxBits == `SE0)
				begin
				  next_RXStMachCurrState <= `WAIT_LOW_SP_DISCONNECT_ST;
				  next_RXWaitCount <= 0;
				end
				next_processRxBitsWEn <= 1'b1;
				next_RxBitsOut <= RxBits;
			end
		`LS_CONN_PROC_RX_BITS:
		begin
			next_processRxBitsWEn <= 1'b0;
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`FS_CONN_CHK_RX_BITS1:
			if (processRxBitRdyIn == 1'b1)	
			begin
				NextState_rcvr <= `FS_CONN_PROC_RX_BITS1;
				if (RxBits == `SE0)
				begin
				  next_RXStMachCurrState <= `WAIT_FULL_SP_DISCONNECT_ST;
				  next_RXWaitCount <= 0;
				end
				next_processRxBitsWEn <= 1'b1;
				next_RxBitsOut <= RxBits;
				next_SIERxRdyOut <= 1'b1;
				//early indication of ready
			end
		`FS_CONN_PROC_RX_BITS1:
		begin
			next_processRxBitsWEn <= 1'b0;
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`WAIT_LS_DIS_CHK_RX_BITS:
			if (processRxBitRdyIn == 1'b1)	
			begin
				NextState_rcvr <= `WAIT_LS_DIS_PROC_RX_BITS;
				if (RxBits == `SE0)
				begin
				  next_RXWaitCount <= RXWaitCount + 1'b1;
				    if (RXWaitCount == `DISCONNECT_WAIT_TIME)
				    begin
				    next_RXStMachCurrState <= `DISCONNECT_ST;
				    next_connectState = `DISCONNECT;
				    end
				end
				else
				begin
				  next_RXStMachCurrState = `CONNECT_LOW_SPEED_ST;
				end
				next_processRxBitsWEn <= 1'b1;
			end
		`WAIT_LS_DIS_PROC_RX_BITS:
		begin
			next_processRxBitsWEn <= 1'b0;
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`WAIT_FS_DIS_PROC_RX_BITS2:
		begin
			next_processRxBitsWEn <= 1'b0;
			NextState_rcvr <= `WAIT_BIT;
			next_SIERxRdyOut <= 1'b1;
		end
		`WAIT_FS_DIS_CHK_RX_BITS2:
			if (processRxBitRdyIn == 1'b1)	
			begin
				NextState_rcvr <= `WAIT_FS_DIS_PROC_RX_BITS2;
				if (RxBits == `SE0)
				begin
				  next_RXWaitCount <= RXWaitCount + 1'b1;
				    if (RXWaitCount == `DISCONNECT_WAIT_TIME)
				    begin
				    next_RXStMachCurrState <= `DISCONNECT_ST;
				    next_connectState = `DISCONNECT;
				    end
				end
				else
				begin
				  next_RXStMachCurrState = `CONNECT_FULL_SPEED_ST;
				end
				next_processRxBitsWEn <= 1'b1;
			end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : rcvr_CurrentState
	if (rst)	
		CurrState_rcvr <= `START_SRX;
	else
		CurrState_rcvr <= NextState_rcvr;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : rcvr_RegOutput
	if (rst)	
	begin
		RXStMachCurrState <= `DISCONNECT_ST;
		RXWaitCount <= 8'h00;
		RxBits <= 2'b00;
		connectState <= `DISCONNECT;
		RxBitsOut <= 2'b00;
		processRxBitsWEn <= 1'b0;
		SIERxRdyOut <= 1'b1;
	end
	else 
	begin
		RXStMachCurrState <= next_RXStMachCurrState;
		RXWaitCount <= next_RXWaitCount;
		RxBits <= next_RxBits;
		connectState <= next_connectState;
		RxBitsOut <= next_RxBitsOut;
		processRxBitsWEn <= next_processRxBitsWEn;
		SIERxRdyOut <= next_SIERxRdyOut;
	end
end

endmodule