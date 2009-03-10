//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbSerialInterfaceEngine_h.v                                 ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// 
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: usbSerialInterfaceEngine_h.v,v 1.1.1.1 2004-10-11 04:00:57 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//


 // Sampling at 'OVER_SAMPLE_RATE' * full speed bit rate
`define OVER_SAMPLE_RATE 4

//timeOuts
`define RX_PACKET_TOUT 18

//TXStreamControlTypes
`define TX_DIRECT_CONTROL 8'h00
`define TX_RESUME_START 8'h01
`define TX_PACKET_START 8'h02
`define TX_PACKET_STREAM 8'h03
`define TX_PACKET_STOP 8'h04
`define TX_IDLE 8'h05

//RXStreamControlTypes
`define RX_PACKET_START 0
`define RX_PACKET_STREAM 1
`define RX_PACKET_STOP 2

//USBLineStates
// ONE_ZERO corresponds to differential 1. ie D+ = Hi, D- = Lo
`define ONE_ZERO 2'b10
`define ZERO_ONE 2'b01
`define SE0 2'b00
`define SE1 2'b11

//RXStatusIndices
`define CRC_ERROR_BIT 0
`define BIT_STUFF_ERROR_BIT 1
`define RX_OVERFLOW_BIT 2
`define NAK_RXED_BIT 3
`define STALL_RXED_BIT 4
`define ACK_RXED_BIT 5
`define DATA_SEQUENCE_BIT 6

//usbWireControlStates
`define TRI_STATE 1'b0
`define DRIVE 1'b1

//limits
`define MAX_CONSEC_SAME_BITS 6
`define RESUME_WAIT_TIME 10
`define RESUME_WAIT_TIME_MINUS1 9
`define RESUME_LEN 20
`define CONNECT_WAIT_TIME 8'd20
`define DISCONNECT_WAIT_TIME 8'd20

//RXConnectStates
`define DISCONNECT 2'b00
`define LOW_SPEED_CONNECT 2'b01
`define FULL_SPEED_CONNECT 2'b10

//TX_RX_InternalStreamTypes
`define DATA_START 8'h00
`define DATA_STOP 8'h01
`define DATA_STREAM 8'h02
`define DATA_BIT_STUFF_ERROR 8'h03

//RXStMach states
`define DISCONNECT_ST 4'h0
`define WAIT_FULL_SPEED_CONN_ST 4'h1
`define WAIT_LOW_SPEED_CONN_ST 4'h2
`define CONNECT_LOW_SPEED_ST 4'h3
`define CONNECT_FULL_SPEED_ST 4'h4
`define WAIT_LOW_SP_DISCONNECT_ST 4'h5
`define WAIT_FULL_SP_DISCONNECT_ST 4'h6

//RXBitStateMachStates
`define IDLE_BIT_ST 2'b00
`define DATA_RECEIVE_BIT_ST 2'b01
`define WAIT_RESUME_ST 2'b10
`define RESUME_END_WAIT_ST 2'b11

//RXByteStateMachStates 
`define IDLE_BYTE_ST 3'b000
`define CHECK_SYNC_ST 3'b001
`define CHECK_PID_ST 3'b010
`define HS_BYTE_ST 3'b011
`define TOKEN_BYTE_ST 3'b100
`define DATA_BYTE_ST 3'b101



