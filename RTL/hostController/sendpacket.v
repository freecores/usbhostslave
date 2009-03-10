//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : 
// Company     : 
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\sendpacket.v
// Generated   : 09/25/04 06:36:27
// From        : c:\projects\USBHostSlave\RTL\hostController\sendpacket.asf
// By          : FSM2VHDL ver. 4.0.5.2
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"



module sendPacket (HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, PID, TxAddr, TxEndP, clk, fifoData, fifoEmpty, fifoReadEn, frameNum, rst, sendPacketRdy, sendPacketWEn);
input   HCTxPortGnt;
input   HCTxPortRdy;
input   [3:0] PID;
input   [6:0] TxAddr;
input   clk;
input   [7:0] fifoData;
input   fifoEmpty;
input   rst;
input   sendPacketWEn;
output  [7:0] HCTxPortCntl;
output  [7:0] HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;
output  [3:0] TxEndP;
output  fifoReadEn;
output  [10:0] frameNum;
output  sendPacketRdy;

reg     [7:0] HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0] HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    [3:0] PID;
wire    [6:0] TxAddr;
reg     [3:0] TxEndP, next_TxEndP;
wire    clk;
wire    [7:0] fifoData;
wire    fifoEmpty;
reg     fifoReadEn, next_fifoReadEn;
reg     [10:0] frameNum, next_frameNum;
wire    rst;
reg     sendPacketRdy, next_sendPacketRdy;
wire    sendPacketWEn;

// diagram signals declarations
reg  [7:0]PIDNotPID;

// BINARY ENCODED state machine: sndPkt
// State codes definitions:
`define START_SP 5'b00000
`define WAIT_ENABLE 5'b00001
`define SP_WAIT_GNT 5'b00010
`define SEND_PID_WAIT_RDY 5'b00011
`define SEND_PID_FIN 5'b00100
`define FIN_SP 5'b00101
`define OUT_IN_SETUP_WAIT_RDY1 5'b00110
`define OUT_IN_SETUP_WAIT_RDY2 5'b00111
`define OUT_IN_SETUP_FIN 5'b01000
`define SEND_SOF_FIN1 5'b01001
`define SEND_SOF_WAIT_RDY3 5'b01010
`define SEND_SOF_WAIT_RDY4 5'b01011
`define DATA0_DATA1_READ_FIFO 5'b01100
`define DATA0_DATA1_WAIT_READ_FIFO 5'b01101
`define DATA0_DATA1_FIFO_EMPTY 5'b01110
`define DATA0_DATA1_FIN 5'b01111
`define DATA0_DATA1_TERM_BYTE 5'b10000
`define OUT_IN_SETUP_CLR_WEN1 5'b10001
`define SEND_SOF_CLR_WEN1 5'b10010
`define DATA0_DATA1_CLR_WEN 5'b10011
`define DATA0_DATA1_CLR_REN 5'b10100

reg [4:0] CurrState_sndPkt;
reg [4:0] NextState_sndPkt;

// Diagram actions (continuous assignments allowed only: assign ...)
always @(PID)
begin
    PIDNotPID <=  { (PID ^ 4'hf), PID };
end


//--------------------------------------------------------------------
// Machine: sndPkt
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (PIDNotPID or TxEndP or TxAddr or frameNum or fifoData or sendPacketWEn or HCTxPortGnt or HCTxPortRdy or PID or fifoEmpty or sendPacketRdy or HCTxPortReq or HCTxPortWEn or HCTxPortData or HCTxPortCntl or fifoReadEn or CurrState_sndPkt)
begin : sndPkt_NextState
	NextState_sndPkt <= CurrState_sndPkt;
	// Set default values for outputs and signals
	next_sendPacketRdy <= sendPacketRdy;
	next_HCTxPortReq <= HCTxPortReq;
	next_HCTxPortWEn <= HCTxPortWEn;
	next_HCTxPortData <= HCTxPortData;
	next_HCTxPortCntl <= HCTxPortCntl;
	next_frameNum <= frameNum;
	next_fifoReadEn <= fifoReadEn;
	case (CurrState_sndPkt) // synopsys parallel_case full_case
		`START_SP:
			NextState_sndPkt <= `WAIT_ENABLE;
		`WAIT_ENABLE:
			if (sendPacketWEn == 1'b1)	
			begin
				NextState_sndPkt <= `SP_WAIT_GNT;
				next_sendPacketRdy <= 1'b0;
				next_HCTxPortReq <= 1'b1;
			end
		`SP_WAIT_GNT:
			if (HCTxPortGnt == 1'b1)	
				NextState_sndPkt <= `SEND_PID_WAIT_RDY;
		`FIN_SP:
		begin
			NextState_sndPkt <= `WAIT_ENABLE;
			next_sendPacketRdy <= 1'b1;
			next_HCTxPortReq <= 1'b0;
		end
		`SEND_PID_WAIT_RDY:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `SEND_PID_FIN;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= PIDNotPID;
				next_HCTxPortCntl <= `TX_PACKET_START;
			end
		`SEND_PID_FIN:
		begin
			next_HCTxPortWEn <= 1'b0;
			if (PID == `DATA0 || PID == `DATA1)	
				NextState_sndPkt <= `DATA0_DATA1_FIFO_EMPTY;
			else if (PID == `SOF)	
				NextState_sndPkt <= `SEND_SOF_WAIT_RDY3;
			else if (PID == `OUT || 
				PID == `IN || 
				PID == `SETUP)	
				NextState_sndPkt <= `OUT_IN_SETUP_WAIT_RDY1;
			else
				NextState_sndPkt <= `FIN_SP;
		end
		`OUT_IN_SETUP_WAIT_RDY1:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `OUT_IN_SETUP_CLR_WEN1;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= {TxEndP[0], TxAddr[6:0]};
				next_HCTxPortCntl <= `TX_PACKET_STREAM;
			end
		`OUT_IN_SETUP_WAIT_RDY2:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `OUT_IN_SETUP_FIN;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= {5'b00000, TxEndP[3:1]};
				next_HCTxPortCntl <= `TX_PACKET_STREAM;
			end
		`OUT_IN_SETUP_FIN:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sndPkt <= `FIN_SP;
		end
		`OUT_IN_SETUP_CLR_WEN1:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sndPkt <= `OUT_IN_SETUP_WAIT_RDY2;
		end
		`SEND_SOF_FIN1:
		begin
			next_HCTxPortWEn <= 1'b0;
			next_frameNum <= frameNum + 1'b1;
			NextState_sndPkt <= `FIN_SP;
		end
		`SEND_SOF_WAIT_RDY3:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `SEND_SOF_CLR_WEN1;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= frameNum[7:0];
				next_HCTxPortCntl <= `TX_PACKET_STREAM;
			end
		`SEND_SOF_WAIT_RDY4:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `SEND_SOF_FIN1;
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= {5'b00000, frameNum[10:8]};
				next_HCTxPortCntl <= `TX_PACKET_STREAM;
			end
		`SEND_SOF_CLR_WEN1:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sndPkt <= `SEND_SOF_WAIT_RDY4;
		end
		`DATA0_DATA1_READ_FIFO:
		begin
			next_HCTxPortWEn <= 1'b1;
			next_HCTxPortData <= fifoData;
			next_HCTxPortCntl <= `TX_PACKET_STREAM;
			NextState_sndPkt <= `DATA0_DATA1_CLR_WEN;
		end
		`DATA0_DATA1_WAIT_READ_FIFO:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `DATA0_DATA1_CLR_REN;
				next_fifoReadEn <= 1'b1;
			end
		`DATA0_DATA1_FIFO_EMPTY:
			if (fifoEmpty == 1'b0)	
				NextState_sndPkt <= `DATA0_DATA1_WAIT_READ_FIFO;
			else
				NextState_sndPkt <= `DATA0_DATA1_TERM_BYTE;
		`DATA0_DATA1_FIN:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sndPkt <= `FIN_SP;
		end
		`DATA0_DATA1_TERM_BYTE:
			if (HCTxPortRdy == 1'b1)	
			begin
				NextState_sndPkt <= `DATA0_DATA1_FIN;
				//Last byte is not valid data,
				//but the 'TX_PACKET_STOP' flag is required
				//by the SIE state machine to detect end of data packet
				next_HCTxPortWEn <= 1'b1;
				next_HCTxPortData <= 8'h00;
				next_HCTxPortCntl <= `TX_PACKET_STOP;
			end
		`DATA0_DATA1_CLR_WEN:
		begin
			next_HCTxPortWEn <= 1'b0;
			NextState_sndPkt <= `DATA0_DATA1_FIFO_EMPTY;
		end
		`DATA0_DATA1_CLR_REN:
		begin
			next_fifoReadEn <= 1'b0;
			NextState_sndPkt <= `DATA0_DATA1_READ_FIFO;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sndPkt_CurrentState
	if (rst)	
		CurrState_sndPkt <= `START_SP;
	else
		CurrState_sndPkt <= NextState_sndPkt;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sndPkt_RegOutput
	if (rst)	
	begin
		sendPacketRdy <= 1'b1;
		HCTxPortReq <= 1'b0;
		HCTxPortWEn <= 1'b0;
		HCTxPortData <= 8'h00;
		HCTxPortCntl <= 8'h00;
		frameNum <= 11'h000;
		fifoReadEn <= 1'b0;
	end
	else 
	begin
		sendPacketRdy <= next_sendPacketRdy;
		HCTxPortReq <= next_HCTxPortReq;
		HCTxPortWEn <= next_HCTxPortWEn;
		HCTxPortData <= next_HCTxPortData;
		HCTxPortCntl <= next_HCTxPortCntl;
		frameNum <= next_frameNum;
		fifoReadEn <= next_fifoReadEn;
	end
end

endmodule