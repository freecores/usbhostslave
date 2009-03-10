//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\hctxportarbiter.v
// Generated   : 09/10/04 20:20:21
// From        : c:\projects\USBHostSlave\RTL\hostController\hctxportarbiter.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module HCTxPortArbiter (HCTxPortCntl, HCTxPortData, HCTxPortWEnable, SOFCntlCntl, SOFCntlData, SOFCntlGnt, SOFCntlReq, SOFCntlWEn, clk, directCntlCntl, directCntlData, directCntlGnt, directCntlReq, directCntlWEn, rst, sendPacketCntl, sendPacketData, sendPacketGnt, sendPacketReq, sendPacketWEn);
input   [7:0] SOFCntlCntl;
input   [7:0] SOFCntlData;
input   SOFCntlReq;
input   SOFCntlWEn;
input   clk;
input   [7:0] directCntlCntl;
input   [7:0] directCntlData;
input   directCntlReq;
input   directCntlWEn;
input   rst;
input   [7:0] sendPacketCntl;
input   [7:0] sendPacketData;
input   sendPacketReq;
input   sendPacketWEn;
output  [7:0] HCTxPortCntl;
output  [7:0] HCTxPortData;
output  HCTxPortWEnable;
output  SOFCntlGnt;
output  directCntlGnt;
output  sendPacketGnt;

reg     [7:0] HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0] HCTxPortData, next_HCTxPortData;
reg     HCTxPortWEnable, next_HCTxPortWEnable;
wire    [7:0] SOFCntlCntl;
wire    [7:0] SOFCntlData;
reg     SOFCntlGnt, next_SOFCntlGnt;
wire    SOFCntlReq;
wire    SOFCntlWEn;
wire    clk;
wire    [7:0] directCntlCntl;
wire    [7:0] directCntlData;
reg     directCntlGnt, next_directCntlGnt;
wire    directCntlReq;
wire    directCntlWEn;
wire    rst;
wire    [7:0] sendPacketCntl;
wire    [7:0] sendPacketData;
reg     sendPacketGnt, next_sendPacketGnt;
wire    sendPacketReq;
wire    sendPacketWEn;


// Constants
`define DIRECT_CTRL_MUX 2'b10
`define SEND_PACKET_MUX 2'b00
`define SOF_CTRL_MUX 2'b01
// diagram signals declarations
reg  [1:0]muxCntl, next_muxCntl;

// BINARY ENCODED state machine: HCTxArb
// State codes definitions:
`define START_HARB 3'b000
`define WAIT_REQ 3'b001
`define SEND_SOF 3'b010
`define SEND_PACKET 3'b011
`define DIRECT_CONTROL 3'b100

reg [2:0] CurrState_HCTxArb;
reg [2:0] NextState_HCTxArb;

// Diagram actions (continuous assignments allowed only: assign ...)
// SOFController/directContol/sendPacket mux
always @(muxCntl or SOFCntlWEn or SOFCntlData or SOFCntlCntl or
		 		 directCntlWEn or directCntlData or directCntlCntl or
                  directCntlWEn or directCntlData or directCntlCntl or
 		  		 sendPacketWEn or sendPacketData or sendPacketCntl)
begin
case (muxCntl)
    `SOF_CTRL_MUX :
    begin
        HCTxPortWEnable <= SOFCntlWEn;
        HCTxPortData <= SOFCntlData;
        HCTxPortCntl <= SOFCntlCntl;
    end
    `DIRECT_CTRL_MUX :
    begin
        HCTxPortWEnable <= directCntlWEn;
        HCTxPortData <= directCntlData;
        HCTxPortCntl <= directCntlCntl;
    end
    `SEND_PACKET_MUX :
    begin
        HCTxPortWEnable <= sendPacketWEn;
        HCTxPortData <= sendPacketData;
        HCTxPortCntl <= sendPacketCntl;
    end
    default :
    begin
        HCTxPortWEnable <= 1'b0;
        HCTxPortData <= 8'h00;
        HCTxPortCntl <= 8'h00;
    end
endcase
end


//--------------------------------------------------------------------
// Machine: HCTxArb
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (SOFCntlReq or sendPacketReq or directCntlReq or SOFCntlGnt or muxCntl or sendPacketGnt or directCntlGnt or CurrState_HCTxArb)
begin : HCTxArb_NextState
	NextState_HCTxArb <= CurrState_HCTxArb;
	// Set default values for outputs and signals
	next_SOFCntlGnt <= SOFCntlGnt;
	next_muxCntl <= muxCntl;
	next_sendPacketGnt <= sendPacketGnt;
	next_directCntlGnt <= directCntlGnt;
	case (CurrState_HCTxArb) // synopsys parallel_case full_case
		`START_HARB:
			NextState_HCTxArb <= `WAIT_REQ;
		`WAIT_REQ:
			if (SOFCntlReq == 1'b1)	
			begin
				NextState_HCTxArb <= `SEND_SOF;
				next_SOFCntlGnt <= 1'b1;
				next_muxCntl <= `SOF_CTRL_MUX;
			end
			else if (sendPacketReq == 1'b1)	
			begin
				NextState_HCTxArb <= `SEND_PACKET;
				next_sendPacketGnt <= 1'b1;
				next_muxCntl <= `SEND_PACKET_MUX;
			end
			else if (directCntlReq == 1'b1)	
			begin
				NextState_HCTxArb <= `DIRECT_CONTROL;
				next_directCntlGnt <= 1'b1;
				next_muxCntl <= `DIRECT_CTRL_MUX;
			end
		`SEND_SOF:
			if (SOFCntlReq == 1'b0)	
			begin
				NextState_HCTxArb <= `WAIT_REQ;
				next_SOFCntlGnt <= 1'b0;
			end
		`SEND_PACKET:
			if (sendPacketReq == 1'b0)	
			begin
				NextState_HCTxArb <= `WAIT_REQ;
				next_sendPacketGnt <= 1'b0;
			end
		`DIRECT_CONTROL:
			if (directCntlReq == 1'b0)	
			begin
				NextState_HCTxArb <= `WAIT_REQ;
				next_directCntlGnt <= 1'b0;
			end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : HCTxArb_CurrentState
	if (rst)	
		CurrState_HCTxArb <= `START_HARB;
	else
		CurrState_HCTxArb <= NextState_HCTxArb;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : HCTxArb_RegOutput
	if (rst)	
	begin
		muxCntl <= 2'b00;
		SOFCntlGnt <= 1'b0;
		sendPacketGnt <= 1'b0;
		directCntlGnt <= 1'b0;
	end
	else 
	begin
		muxCntl <= next_muxCntl;
		SOFCntlGnt <= next_SOFCntlGnt;
		sendPacketGnt <= next_sendPacketGnt;
		directCntlGnt <= next_directCntlGnt;
	end
end

endmodule