//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\sofcontroller.v
// Generated   : 09/08/04 06:24:36
// From        : c:\projects\USBHostSlave\RTL\hostController\sofcontroller.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"

module SOFController (HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, SOFEnable, SOFTimerClr, SOFTimer, clk, rst);
input   HCTxPortGnt;
input   HCTxPortRdy;
input   SOFEnable;
input   SOFTimerClr;
input   clk;
input   rst;
output  [7:0] HCTxPortCntl;
output  [7:0] HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;
output  [15:0] SOFTimer;

reg     [7:0] HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0] HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    SOFEnable;
wire    SOFTimerClr;
reg     [15:0] SOFTimer, next_SOFTimer;
wire    clk;
wire    rst;

// BINARY ENCODED state machine: sofCntl
// State codes definitions:
`define START_SC 3'b000
`define WAIT_SOF_EN 3'b001
`define WAIT_SEND_RESUME 3'b010
`define INC_TIMER 3'b011
`define SC_WAIT_GNT 3'b100
`define CLR_WEN 3'b101

reg [2:0] CurrState_sofCntl;
reg [2:0] NextState_sofCntl;


//--------------------------------------------------------------------
// Machine: sofCntl
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (SOFTimerClr or SOFTimer or SOFEnable or HCTxPortRdy or HCTxPortGnt or HCTxPortReq or HCTxPortWEn or HCTxPortData or HCTxPortCntl or CurrState_sofCntl)
begin : sofCntl_NextState
	NextState_sofCntl <= CurrState_sofCntl;
	// Set default values for outputs and signals
	next_HCTxPortReq <= HCTxPortReq;
	next_HCTxPortWEn <= HCTxPortWEn;
	next_HCTxPortData <= HCTxPortData;
	next_HCTxPortCntl <= HCTxPortCntl;
	next_SOFTimer <= SOFTimer;
	case (CurrState_sofCntl) // synopsys parallel_case full_case
		`START_SC:
			NextState_sofCntl <= `WAIT_SOF_EN;
		`WAIT_SOF_EN:
			if (SOFEnable == 1'b1)	
			begin
				NextState_sofCntl <= `SC_WAIT_GNT;
				next_HCTxPortReq <= 1'b1;
			end
		`WAIT_SEND_RESUME:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sofCntl <= `CLR_WEN;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= 8'h00;
				next_HCTxPortCntl <= `TX_RESUME_START;
			end
		`INC_TIMER:
		begin
			next_HCTxPortReq <= 1'b0;
			if (SOFTimerClr == 1'b1)
			  next_SOFTimer <= 16'h0000;
			else
			  next_SOFTimer <= SOFTimer + 1'b1;
			if (SOFEnable == 1'b0)	
			begin
				NextState_sofCntl <= `WAIT_SOF_EN;
				next_SOFTimer <= 16'h0000;
			end
		end
		`SC_WAIT_GNT:
			if (HCTxPortGnt == 1'b1)	
				NextState_sofCntl <= `WAIT_SEND_RESUME;
		`CLR_WEN:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sofCntl <= `INC_TIMER;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sofCntl_CurrentState
	if (rst)	
		CurrState_sofCntl <= `START_SC;
	else
		CurrState_sofCntl <= NextState_sofCntl;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sofCntl_RegOutput
	if (rst)	
	begin
		SOFTimer <= 16'h0000;
		HCTxPortCntl <= 8'h00;
		HCTxPortData <= 8'h00;
		HCTxPortWEn <= 1'b0;
		HCTxPortReq <= 1'b0;
	end
	else 
	begin
		SOFTimer <= next_SOFTimer;
		HCTxPortCntl <= next_HCTxPortCntl;
		HCTxPortData <= next_HCTxPortData;
		HCTxPortWEn <= next_HCTxPortWEn;
		HCTxPortReq <= next_HCTxPortReq;
	end
end

endmodule