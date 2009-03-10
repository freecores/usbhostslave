//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbHostControl_h.v                                           ////
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
// $Id: usbHostControl_h.v,v 1.1.1.1 2004-10-11 04:00:57 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//


//HCRegIndices
`define TX_CONTROL_REG 4'h0
`define TX_TRANS_TYPE_REG 4'h1
`define TX_LINE_CONTROL_REG 4'h2
`define TX_SOF_ENABLE_REG 4'h3
`define TX_ADDR_REG 4'h4
`define TX_ENDP_REG 4'h5
`define FRAME_NUM_MSB_REG 4'h6
`define FRAME_NUM_LSB_REG 4'h7
`define INTERRUPT_STATUS_REG 4'h8
`define INTERRUPT_MASK_REG 4'h9
`define RX_STATUS_REG 4'ha
`define RX_PID_REG 4'hb
`define RX_ADDR_REG 4'hc
`define RX_ENDP_REG 4'hd
`define RX_CONNECT_STATE_REG 4'he
`define HCREG_BUFFER_LEN 4'hf
`define HCREG_MASK 4'hf

//TXControlRegIndices
`define TRANS_REQ_BIT 0
`define SOF_SYNC_BIT 1
`define PREAMBLE_ENABLE_BIT 2

//interruptRegIndices
`define TRANS_DONE_BIT 0
`define RESUME_INT_BIT 1
`define CONNECTION_EVENT_BIT 2
`define SOF_SENT_BIT 3

//TXTransactionTypes
`define SETUP_TRANS 0
`define IN_TRANS 1
`define OUTDATA0_TRANS 2
`define OUTDATA1_TRANS 3
 
 //TXLineControlIndices
`define TX_LINE_STATE_LSBIT 0
`define TX_LINE_STATE_MSBIT 1
`define DIRECT_CONTROL_BIT 2
`define FULL_SPEED_LINE_POLARITY_BIT 3
`define FULL_SPEED_LINE_RATE_BIT 4

//TXSOFEnableIndices
`define SOF_EN_BIT 0

//SOFTimeConstants 
`define SOF_TX_TIME 80     //Fix this. Need correct SOF TX interval
`define SOF_TX_MARGIN 2
       
//Host RXStatusRegIndices 
`define HC_CRC_ERROR_BIT 0
`define HC_BIT_STUFF_ERROR_BIT 1
`define HC_RX_OVERFLOW_BIT 2
`define HC_RX_TIME_OUT_BIT 3
`define HC_NAK_RXED_BIT 4
`define HC_STALL_RXED_BIT 5
`define HC_ACK_RXED_BIT 6
`define HC_DATA_SEQUENCE_BIT 7

