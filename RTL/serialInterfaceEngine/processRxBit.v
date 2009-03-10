//--------------------------------------------------------------------------------------------------
//
// Title       : No Title
// Design      : usbhostslave
// Author      : Steve
// Company     : Base2Designs
//
//-------------------------------------------------------------------------------------------------
//
// File        : c:\projects\USBHostSlave\Aldec\usbhostslave\usbhostslave\compile\processRxBit.v
// Generated   : 09/12/04 22:54:47
// From        : c:\projects\USBHostSlave\RTL\serialInterfaceEngine\processRxBit.asf
// By          : FSM2VHDL ver. 4.0.3.8
//
//-------------------------------------------------------------------------------------------------
//
// Description : 
//
//-------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
`include "usbSerialInterfaceEngine_h.v"


module processRxBit (JBit, KBit, RxBitsIn, RxCtrlOut, RxDataOut, clk, processRxBitRdy, processRxBitsWEn, processRxByteRdy, processRxByteWEn, resumeDetected, rst);
input   [1:0] JBit;
input   [1:0] KBit;
input   [1:0] RxBitsIn;
input   clk;
input   processRxBitsWEn;
input   processRxByteRdy;
input   rst;
output  [7:0] RxCtrlOut;
output  [7:0] RxDataOut;
output  processRxBitRdy;
output  processRxByteWEn;
output  resumeDetected;

wire    [1:0] JBit;
wire    [1:0] KBit;
wire    [1:0] RxBitsIn;
reg     [7:0] RxCtrlOut, next_RxCtrlOut;
reg     [7:0] RxDataOut, next_RxDataOut;
wire    clk;
reg     processRxBitRdy, next_processRxBitRdy;
wire    processRxBitsWEn;
wire    processRxByteRdy;
reg     processRxByteWEn, next_processRxByteWEn;
reg     resumeDetected, next_resumeDetected;
wire    rst;

// diagram signals declarations
reg  [3:0]RXBitCount, next_RXBitCount;
reg  [1:0]RXBitStMachCurrState, next_RXBitStMachCurrState;
reg  [7:0]RXByte, next_RXByte;
reg  [3:0]RXSameBitCount, next_RXSameBitCount;
reg  [1:0]RxBits, next_RxBits;
reg bitStuffError, next_bitStuffError;
reg  [1:0]oldRXBits, next_oldRXBits;
reg  [3:0]resumeWaitCnt, next_resumeWaitCnt;

// BINARY ENCODED state machine: prRxBit
// State codes definitions:
`define START 4'b0000
`define IDLE_FIRST_BIT 4'b0001
`define WAIT_BITS 4'b0010
`define IDLE_CHK_KBIT 4'b0011
`define DATA_RX_LAST_BIT 4'b0100
`define DATA_RX_CHK_SE0 4'b0101
`define DATA_RX_DATA_DESTUFF 4'b0110
`define DATA_RX_BYTE_SEND2 4'b0111
`define DATA_RX_BYTE_WAIT_RDY 4'b1000
`define RES_RX_CHK 4'b1001
`define DATA_RX_ERROR_CHK_RES 4'b1010
`define RES_END_CHK1 4'b1011
`define IDLE_WAIT_PRB_RDY 4'b1100
`define DATA_RX_WAIT_PRB_RDY 4'b1101
`define DATA_RX_ERROR_WAIT_RDY 4'b1110

reg [3:0] CurrState_prRxBit;
reg [3:0] NextState_prRxBit;


//--------------------------------------------------------------------
// Machine: prRxBit
//--------------------------------------------------------------------
//----------------------------------
// NextState logic (combinatorial)
//----------------------------------
always @ (RxBitsIn or RxBits or oldRXBits or RXSameBitCount or RXBitCount or RXByte or JBit or KBit or resumeWaitCnt or processRxBitsWEn or RXBitStMachCurrState or processRxByteRdy or bitStuffError or processRxByteWEn or RxCtrlOut or RxDataOut or resumeDetected or processRxBitRdy or CurrState_prRxBit)
begin : prRxBit_NextState
	NextState_prRxBit <= CurrState_prRxBit;
	// Set default values for outputs and signals
	next_processRxByteWEn <= processRxByteWEn;
	next_RxCtrlOut <= RxCtrlOut;
	next_RxDataOut <= RxDataOut;
	next_resumeDetected <= resumeDetected;
	next_RXBitStMachCurrState <= RXBitStMachCurrState;
	next_RxBits <= RxBits;
	next_RXSameBitCount <= RXSameBitCount;
	next_RXBitCount <= RXBitCount;
	next_oldRXBits <= oldRXBits;
	next_RXByte <= RXByte;
	next_bitStuffError <= bitStuffError;
	next_resumeWaitCnt <= resumeWaitCnt;
	next_processRxBitRdy <= processRxBitRdy;
	case (CurrState_prRxBit) // synopsys parallel_case full_case
		`START:
		begin
			next_processRxByteWEn <= 1'b0;
			next_RxCtrlOut <= 8'h00;
			next_RxDataOut <= 8'h00;
			next_resumeDetected <= 1'b0;
			next_RXBitStMachCurrState <= `IDLE_BIT_ST;
			next_RxBits <= 2'b00;
			next_RXSameBitCount <= 4'h0;
			next_RXBitCount <= 4'h0;
			next_oldRXBits <= 2'b00;
			next_RXByte <= 8'h00;
			next_bitStuffError <= 1'b0;
			next_resumeWaitCnt <= 4'h0;
			next_processRxBitRdy <= 1'b1;
			NextState_prRxBit <= `WAIT_BITS;
		end
		`WAIT_BITS:
			if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `DATA_RECEIVE_BIT_ST))	
			begin
				NextState_prRxBit <= `DATA_RX_CHK_SE0;
				next_RxBits <= RxBitsIn;
				next_processRxBitRdy <= 1'b0;
			end
			else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `WAIT_RESUME_ST))	
			begin
				NextState_prRxBit <= `RES_RX_CHK;
				next_RxBits <= RxBitsIn;
				next_processRxBitRdy <= 1'b0;
			end
			else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `RESUME_END_WAIT_ST))	
			begin
				NextState_prRxBit <= `RES_END_CHK1;
				next_RxBits <= RxBitsIn;
				next_processRxBitRdy <= 1'b0;
			end
			else if ((processRxBitsWEn == 1'b1) && (RXBitStMachCurrState == `IDLE_BIT_ST))	
			begin
				NextState_prRxBit <= `IDLE_CHK_KBIT;
				next_RxBits <= RxBitsIn;
				next_processRxBitRdy <= 1'b0;
			end
		`IDLE_FIRST_BIT:
		begin
			next_processRxByteWEn <= 1'b0;
			next_RXBitStMachCurrState <= `DATA_RECEIVE_BIT_ST;
			next_RXSameBitCount <= 4'h1;
			next_RXBitCount <= 4'h1;
			next_oldRXBits <= RxBits;
			//zero is always the first RZ data bit of a new packet
			next_RXByte <= 8'h00;
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
		`IDLE_CHK_KBIT:
			if (RxBits == KBit)	
				NextState_prRxBit <= `IDLE_WAIT_PRB_RDY;
			else
			begin
				NextState_prRxBit <= `WAIT_BITS;
				next_processRxBitRdy <= 1'b1;
			end
		`IDLE_WAIT_PRB_RDY:
			if (processRxByteRdy == 1'b1)	
			begin
				NextState_prRxBit <= `IDLE_FIRST_BIT;
				next_RxDataOut <= 8'h00;
				//redundant data
				next_RxCtrlOut <= `DATA_START;
				//start of packet
				next_processRxByteWEn <= 1'b1;
			end
		`DATA_RX_LAST_BIT:
		begin
			next_processRxByteWEn <= 1'b0;
			next_RXBitStMachCurrState <= `IDLE_BIT_ST;
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
		`DATA_RX_CHK_SE0:
		begin
			next_bitStuffError <= 1'b0;
			if (RxBits == `SE0)	
				NextState_prRxBit <= `DATA_RX_WAIT_PRB_RDY;
			else
			begin
				NextState_prRxBit <= `DATA_RX_DATA_DESTUFF;
				if (RxBits == oldRXBits)                 //if the current 'RxBits' are the same as the old 'RxBits', then
				begin
				  next_RXSameBitCount <= RXSameBitCount + 1'b1;
				    //inc 'RXSameBitCount'
				    if (RXSameBitCount == `MAX_CONSEC_SAME_BITS) //if 'RXSameBitCount' == 7 there has been a bit stuff error
				    next_bitStuffError <= 1'b1;
				        //flag 'bitStuffError'
				    else                                          //else no bit stuffing error
				    begin
				    next_RXBitCount <= RXBitCount + 1'b1;
				        if (RXBitCount != 4'h7) begin
				      next_processRxBitRdy <= 1'b1;
				            //early indication of ready
						end
				    next_RXByte <= { 1'b1, RXByte[7:1]};
				        //RZ bit = 1 (ie no change in 'RxBits')
				    end
				end
				else                                            //else current 'RxBits' are different from old 'RxBits'
				begin
				    if (RXSameBitCount != `MAX_CONSEC_SAME_BITS)  //if this is not the RZ 0 bit after 6 consecutive RZ 1s, then
				    begin
				    next_RXBitCount <= RXBitCount + 1'b1;
				        if (RXBitCount != 4'h7) begin
				      next_processRxBitRdy <= 1'b1;
				            //early indication of ready
						end
				    next_RXByte <= {1'b0, RXByte[7:1]};
				        //RZ bit = 0 (ie current'RxBits' is different than old 'RxBits')
				    end
				  next_RXSameBitCount <= 4'h1;
				    //reset 'RXSameBitCount'
				end
				next_oldRXBits <= RxBits;
			end
		end
		`DATA_RX_WAIT_PRB_RDY:
			if (processRxByteRdy == 1'b1)	
			begin
				NextState_prRxBit <= `DATA_RX_LAST_BIT;
				next_RxDataOut <= 8'h00;
				//redundant data
				next_RxCtrlOut <= `DATA_STOP;
				//end of packet
				next_processRxByteWEn <= 1'b1;
			end
		`DATA_RX_DATA_DESTUFF:
			if (RXBitCount == 4'h8 & bitStuffError == 1'b0)	
				NextState_prRxBit <= `DATA_RX_BYTE_WAIT_RDY;
			else if (bitStuffError == 1'b1)	
				NextState_prRxBit <= `DATA_RX_ERROR_WAIT_RDY;
			else
			begin
				NextState_prRxBit <= `WAIT_BITS;
				next_processRxBitRdy <= 1'b1;
			end
		`DATA_RX_BYTE_SEND2:
		begin
			next_processRxByteWEn <= 1'b0;
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
		`DATA_RX_BYTE_WAIT_RDY:
			if (processRxByteRdy == 1'b1)	
			begin
				NextState_prRxBit <= `DATA_RX_BYTE_SEND2;
				next_RXBitCount <= 4'h0;
				next_RxDataOut <= RXByte;
				next_RxCtrlOut <= `DATA_STREAM;
				next_processRxByteWEn <= 1'b1;
			end
		`DATA_RX_ERROR_CHK_RES:
		begin
			next_processRxByteWEn <= 1'b0;
			if (RxBits == JBit)                           //if current bit is a JBit, then
			  next_RXBitStMachCurrState <= `IDLE_BIT_ST;
			    //next state is idle
			else                                          //else
			begin
			  next_RXBitStMachCurrState <= `WAIT_RESUME_ST;
			    //check for resume
			  next_resumeWaitCnt <= 0;
			end
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
		`DATA_RX_ERROR_WAIT_RDY:
			if (processRxByteRdy == 1'b1)	
			begin
				NextState_prRxBit <= `DATA_RX_ERROR_CHK_RES;
				next_RxDataOut <= 8'h00;
				//redundant data
				next_RxCtrlOut <= `DATA_BIT_STUFF_ERROR;
				next_processRxByteWEn <= 1'b1;
			end
		`RES_RX_CHK:
		begin
			if (RxBits != KBit)  //can only be a resume if line remains in Kbit state
			  next_RXBitStMachCurrState <= `IDLE_BIT_ST;
			else
			begin
			  next_resumeWaitCnt <= resumeWaitCnt + 1'b1;
			    //if we've waited long enough, then
			    if (resumeWaitCnt == `RESUME_WAIT_TIME_MINUS1)
			    begin
			    next_RXBitStMachCurrState <= `RESUME_END_WAIT_ST;
			    next_resumeDetected <= 1'b1;
			        //report resume detected
			    end
			end
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
		`RES_END_CHK1:
		begin
			if (RxBits != KBit)  //line must leave KBit state for the end of resume
			begin
			  next_RXBitStMachCurrState <= `IDLE_BIT_ST;
			  next_resumeDetected <= 1'b0;
			    //clear resume detected flag
			end
			NextState_prRxBit <= `WAIT_BITS;
			next_processRxBitRdy <= 1'b1;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : prRxBit_CurrentState
	if (rst)	
		CurrState_prRxBit <= `START;
	else
		CurrState_prRxBit <= NextState_prRxBit;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : prRxBit_RegOutput
	if (rst)	
	begin
		RXBitStMachCurrState <= `IDLE_BIT_ST;
		RxBits <= 2'b00;
		RXSameBitCount <= 4'h0;
		RXBitCount <= 4'h0;
		oldRXBits <= 2'b00;
		RXByte <= 8'h00;
		bitStuffError <= 1'b0;
		resumeWaitCnt <= 4'h0;
		processRxByteWEn <= 1'b0;
		RxCtrlOut <= 8'h00;
		RxDataOut <= 8'h00;
		resumeDetected <= 1'b0;
		processRxBitRdy <= 1'b1;
	end
	else 
	begin
		RXBitStMachCurrState <= next_RXBitStMachCurrState;
		RxBits <= next_RxBits;
		RXSameBitCount <= next_RXSameBitCount;
		RXBitCount <= next_RXBitCount;
		oldRXBits <= next_oldRXBits;
		RXByte <= next_RXByte;
		bitStuffError <= next_bitStuffError;
		resumeWaitCnt <= next_resumeWaitCnt;
		processRxByteWEn <= next_processRxByteWEn;
		RxCtrlOut <= next_RxCtrlOut;
		RxDataOut <= next_RxDataOut;
		resumeDetected <= next_resumeDetected;
		processRxBitRdy <= next_processRxBitRdy;
	end
end

endmodule