//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\slaveGetpacket.v
// Generated   : 09/22/04 06:01:23
// From        : c:\projects\USBHostSlave\RTL\slaveController\slaveGetpacket.asf
// By          : FSM2VHDL ver. 4.0.5.2
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`include "usbSerialInterfaceEngine_h.v"
`include "usbConstants_h.v"

module slaveGetPacket (ACKRxed, CRCError, RXDataIn, RXDataValid, RXFifoData, RXFifoFull, RXFifoWEn, RXOverflow, RXPacketRdy, RXStreamStatusIn, RXTimeOut, RxPID, SIERxTimeOut, bitStuffError, clk, dataSequence, getPacketEn, rst);
input   [7:0] RXDataIn;
input   RXDataValid;
input   RXFifoFull;
input   [7:0] RXStreamStatusIn;
input   SIERxTimeOut;		// Single cycle pulse
input   clk;
input   getPacketEn;
input   rst;
output  ACKRxed;
output  CRCError;
output  [7:0] RXFifoData;
output  RXFifoWEn;
output  RXOverflow;
output  RXPacketRdy;
output  RXTimeOut;
output  [3:0] RxPID;
output  bitStuffError;
output  dataSequence;

reg     ACKRxed, next_ACKRxed;
reg     CRCError, next_CRCError;
wire    [7:0] RXDataIn;
wire    RXDataValid;
reg     [7:0] RXFifoData, next_RXFifoData;
wire    RXFifoFull;
reg     RXFifoWEn, next_RXFifoWEn;
reg     RXOverflow, next_RXOverflow;
reg     RXPacketRdy, next_RXPacketRdy;
wire    [7:0] RXStreamStatusIn;
reg     RXTimeOut, next_RXTimeOut;
reg     [3:0] RxPID, next_RxPID;
wire    SIERxTimeOut;
reg     bitStuffError, next_bitStuffError;
wire    clk;
reg     dataSequence, next_dataSequence;
wire    getPacketEn;
wire    rst;

// diagram signals declarations
reg  [7:0]RXByteOld, next_RXByteOld;
reg  [7:0]RXByteOldest, next_RXByteOldest;
reg  [7:0]RXByte, next_RXByte;
reg  [7:0]RXStreamStatus, next_RXStreamStatus;

// BINARY ENCODED state machine: slvGetPkt
// State codes definitions:
`define PROC_PKT_CHK_PID 5'b00000
`define PROC_PKT_HS 5'b00001
`define PROC_PKT_DATA_W_D1 5'b00010
`define PROC_PKT_DATA_CHK_D1 5'b00011
`define PROC_PKT_DATA_W_D2 5'b00100
`define PROC_PKT_DATA_FIN 5'b00101
`define PROC_PKT_DATA_CHK_D2 5'b00110
`define PROC_PKT_DATA_W_D3 5'b00111
`define PROC_PKT_DATA_CHK_D3 5'b01000
`define PROC_PKT_DATA_LOOP_CHK_FIFO 5'b01001
`define PROC_PKT_DATA_LOOP_FIFO_FULL 5'b01010
`define PROC_PKT_DATA_LOOP_W_D 5'b01011
`define START_GP 5'b01100
`define WAIT_PKT 5'b01101
`define CHK_PKT_START 5'b01110
`define WAIT_EN 5'b01111
`define PKT_RDY 5'b10000
`define PROC_PKT_DATA_LOOP_DELAY 5'b10001

reg [4:0] CurrState_slvGetPkt;
reg [4:0] NextState_slvGetPkt;


//--------------------------------------------------------------------
// Machine: slvGetPkt
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (RXDataIn or RXStreamStatusIn or RXByte or RXByteOldest or RXByteOld or RXDataValid or RXStreamStatus or getPacketEn or RXFifoFull or CRCError or bitStuffError or RXOverflow or RXTimeOut or ACKRxed or dataSequence or RxPID or RXPacketRdy or RXFifoWEn or RXFifoData or CurrState_slvGetPkt)
begin : slvGetPkt_NextState
	NextState_slvGetPkt <= CurrState_slvGetPkt;
	// Set default values for outputs and signals
	next_CRCError <= CRCError;
	next_bitStuffError <= bitStuffError;
	next_RXOverflow <= RXOverflow;
	next_RXTimeOut <= RXTimeOut;
	next_ACKRxed <= ACKRxed;
	next_dataSequence <= dataSequence;
	next_RXByte <= RXByte;
	next_RXStreamStatus <= RXStreamStatus;
	next_RxPID <= RxPID;
	next_RXPacketRdy <= RXPacketRdy;
	next_RXByteOldest <= RXByteOldest;
	next_RXByteOld <= RXByteOld;
	next_RXFifoWEn <= RXFifoWEn;
	next_RXFifoData <= RXFifoData;
	case (CurrState_slvGetPkt) // synopsys parallel_case full_case
		`START_GP:
			NextState_slvGetPkt <= `WAIT_EN;
		`WAIT_PKT:
		begin
			next_CRCError <= 1'b0;
			next_bitStuffError <= 1'b0;
			next_RXOverflow <= 1'b0;
			next_RXTimeOut <= 1'b0;
			next_ACKRxed <= 1'b0;
			next_dataSequence <= 1'b0;
			if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `CHK_PKT_START;
				next_RXByte <= RXDataIn;
				next_RXStreamStatus <= RXStreamStatusIn;
			end
		end
		`CHK_PKT_START:
			if (RXStreamStatus == `RX_PACKET_START)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_CHK_PID;
				next_RxPID <= RXByte[3:0];
			end
			else
			begin
				NextState_slvGetPkt <= `PKT_RDY;
				next_RXTimeOut <= 1'b1;
			end
		`WAIT_EN:
		begin
			next_RXPacketRdy <= 1'b0;
			if (getPacketEn == 1'b1)	
				NextState_slvGetPkt <= `WAIT_PKT;
		end
		`PKT_RDY:
		begin
			next_RXPacketRdy <= 1'b1;
			NextState_slvGetPkt <= `WAIT_EN;
		end
		`PROC_PKT_CHK_PID:
			if (RXByte[1:0] == `HANDSHAKE)	
				NextState_slvGetPkt <= `PROC_PKT_HS;
			else if (RXByte[1:0] == `DATA)	
				NextState_slvGetPkt <= `PROC_PKT_DATA_W_D1;
			else
				NextState_slvGetPkt <= `PKT_RDY;
		`PROC_PKT_HS:
			if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `PKT_RDY;
				next_RXOverflow <= RXDataIn[`RX_OVERFLOW_BIT];
				next_ACKRxed <= RXDataIn[`ACK_RXED_BIT];
			end
		`PROC_PKT_DATA_W_D1:
			if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D1;
				next_RXByte <= RXDataIn;
				next_RXStreamStatus <= RXStreamStatusIn;
			end
		`PROC_PKT_DATA_CHK_D1:
			if (RXStreamStatus == `RX_PACKET_STREAM)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_W_D2;
				next_RXByteOldest <= RXByte;
			end
			else
				NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
		`PROC_PKT_DATA_W_D2:
			if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D2;
				next_RXByte <= RXDataIn;
				next_RXStreamStatus <= RXStreamStatusIn;
			end
		`PROC_PKT_DATA_FIN:
		begin
			next_CRCError <= RXByte[`CRC_ERROR_BIT];
			next_bitStuffError <= RXByte[`BIT_STUFF_ERROR_BIT];
			next_dataSequence <= RXByte[`DATA_SEQUENCE_BIT];
			NextState_slvGetPkt <= `PKT_RDY;
		end
		`PROC_PKT_DATA_CHK_D2:
			if (RXStreamStatus == `RX_PACKET_STREAM)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_W_D3;
				next_RXByteOld <= RXByte;
			end
			else
				NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
		`PROC_PKT_DATA_W_D3:
			if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_CHK_D3;
				next_RXByte <= RXDataIn;
				next_RXStreamStatus <= RXStreamStatusIn;
			end
		`PROC_PKT_DATA_CHK_D3:
			if (RXStreamStatus == `RX_PACKET_STREAM)	
				NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_CHK_FIFO;
			else
				NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
		`PROC_PKT_DATA_LOOP_CHK_FIFO:
			if (RXFifoFull == 1'b1)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_FIFO_FULL;
				next_RXOverflow <= 1'b1;
			end
			else
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_W_D;
				next_RXFifoWEn <= 1'b1;
				next_RXFifoData <= RXByteOldest;
				next_RXByteOldest <= RXByteOld;
				next_RXByteOld <= RXByte;
			end
		`PROC_PKT_DATA_LOOP_FIFO_FULL:
			NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_W_D;
		`PROC_PKT_DATA_LOOP_W_D:
		begin
			next_RXFifoWEn <= 1'b0;
			if ((RXDataValid == 1'b1) && (RXStreamStatusIn == `RX_PACKET_STREAM))	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_DELAY;
				next_RXByte <= RXDataIn;
			end
			else if (RXDataValid == 1'b1)	
			begin
				NextState_slvGetPkt <= `PROC_PKT_DATA_FIN;
				next_RXByte <= RXDataIn;
			end
		end
		`PROC_PKT_DATA_LOOP_DELAY:
			NextState_slvGetPkt <= `PROC_PKT_DATA_LOOP_CHK_FIFO;
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : slvGetPkt_CurrentState
	if (rst)	
		CurrState_slvGetPkt <= `START_GP;
	else
		CurrState_slvGetPkt <= NextState_slvGetPkt;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : slvGetPkt_RegOutput
	if (rst)	
	begin
		RXByteOld <= 8'h00;
		RXByteOldest <= 8'h00;
		RXByte <= 8'h00;
		RXStreamStatus <= 8'h00;
		RXPacketRdy <= 1'b0;
		RXFifoWEn <= 1'b0;
		RXFifoData <= 8'h00;
		CRCError <= 1'b0;
		bitStuffError <= 1'b0;
		RXOverflow <= 1'b0;
		RXTimeOut <= 1'b0;
		ACKRxed <= 1'b0;
		dataSequence <= 1'b0;
		RxPID <= 4'h0;
	end
	else 
	begin
		RXByteOld <= next_RXByteOld;
		RXByteOldest <= next_RXByteOldest;
		RXByte <= next_RXByte;
		RXStreamStatus <= next_RXStreamStatus;
		RXPacketRdy <= next_RXPacketRdy;
		RXFifoWEn <= next_RXFifoWEn;
		RXFifoData <= next_RXFifoData;
		CRCError <= next_CRCError;
		bitStuffError <= next_bitStuffError;
		RXOverflow <= next_RXOverflow;
		RXTimeOut <= next_RXTimeOut;
		ACKRxed <= next_ACKRxed;
		dataSequence <= next_dataSequence;
		RxPID <= next_RxPID;
	end
end

endmodule