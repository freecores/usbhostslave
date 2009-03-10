//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\directcontrol.v
// Generated   : 06/05/04 05:32:20
// From        : c:\projects\USBHostSlave\RTL\hostController\directcontrol.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"

module directControl (HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, clk, directControlEn, directControlLineState, rst);
input   HCTxPortGnt;
input   HCTxPortRdy;
input   clk;
input   directControlEn;
input   [1:0] directControlLineState;
input   rst;
output  [7:0] HCTxPortCntl;
output  [7:0] HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;

reg     [7:0] HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0] HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    clk;
wire    directControlEn;
wire    [1:0] directControlLineState;
wire    rst;

// BINARY ENCODED state machine: drctCntl
// State codes definitions:
`define START_DC 3'b000
`define CHK_DRCT_CNTL 3'b001
`define DRCT_CNTL_WAIT_GNT 3'b010
`define DRCT_CNTL_CHK_LOOP 3'b011
`define DRCT_CNTL_WAIT_RDY 3'b100
`define IDLE_FIN 3'b101
`define IDLE_WAIT_GNT 3'b110
`define IDLE_WAIT_RDY 3'b111

reg [2:0] CurrState_drctCntl;
reg [2:0] NextState_drctCntl;

// Diagram actions (continuous assignments allowed only: assign ...)
// diagram ACTION


//--------------------------------------------------------------------
// Machine: drctCntl
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (directControlLineState or directControlEn or HCTxPortGnt or HCTxPortRdy or HCTxPortReq or HCTxPortWEn or HCTxPortData or HCTxPortCntl or CurrState_drctCntl)
begin : drctCntl_NextState
	NextState_drctCntl <= CurrState_drctCntl;
	// Set default values for outputs and signals
	next_HCTxPortReq <= HCTxPortReq;
	next_HCTxPortWEn <= HCTxPortWEn;
	next_HCTxPortData <= HCTxPortData;
	next_HCTxPortCntl <= HCTxPortCntl;
	case (CurrState_drctCntl) // synopsys parallel_case full_case
		`START_DC:
			NextState_drctCntl <= `CHK_DRCT_CNTL;
		`CHK_DRCT_CNTL:
			if (directControlEn == 1'b1)	
			begin
				NextState_drctCntl <= `DRCT_CNTL_WAIT_GNT;
				next_HCTxPortReq <= 1'b1;
			end
			else
			begin
				NextState_drctCntl <= `IDLE_WAIT_GNT;
				next_HCTxPortReq <= 1'b1;
			end
		`DRCT_CNTL_WAIT_GNT:
			if (HCTxPortGnt == 1'b1)	
				NextState_drctCntl <= `DRCT_CNTL_WAIT_RDY;
		`DRCT_CNTL_CHK_LOOP:
		begin
			next_HCTxPortWEn <= 1'b0;
			if (directControlEn == 1'b0)	
			begin
				NextState_drctCntl <= `CHK_DRCT_CNTL;
				next_HCTxPortReq <= 1'b0;
			end
			else
				NextState_drctCntl <= `DRCT_CNTL_WAIT_RDY;
		end
		`DRCT_CNTL_WAIT_RDY:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_drctCntl <= `DRCT_CNTL_CHK_LOOP;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= {6'b000000, directControlLineState};
				next_HCTxPortCntl <= `TX_DIRECT_CONTROL;
			end
		`IDLE_FIN:
		begin
			next_HCTxPortWEn <= 1'b0;
			next_HCTxPortReq <= 1'b0;
			NextState_drctCntl <= `CHK_DRCT_CNTL;
		end
		`IDLE_WAIT_GNT:
			if (HCTxPortGnt == 1'b1)	
				NextState_drctCntl <= `IDLE_WAIT_RDY;
		`IDLE_WAIT_RDY:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_drctCntl <= `IDLE_FIN;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= 8'h00;
				next_HCTxPortCntl <= `TX_IDLE;
			end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : drctCntl_CurrentState
	if (rst)	
		CurrState_drctCntl <= `START_DC;
	else
		CurrState_drctCntl <= NextState_drctCntl;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : drctCntl_RegOutput
	if (rst)	
	begin
		HCTxPortCntl <= 8'h00;
		HCTxPortData <= 8'h00;
		HCTxPortWEn <= 1'b0;
		HCTxPortReq <= 1'b0;
	end
	else 
	begin
		HCTxPortCntl <= next_HCTxPortCntl;
		HCTxPortData <= next_HCTxPortData;
		HCTxPortWEn <= next_HCTxPortWEn;
		HCTxPortReq <= next_HCTxPortReq;
	end
end

endmodule