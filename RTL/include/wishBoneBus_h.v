//////////////////////////////////////////////////////////////////////
////                                                              ////
//// wishBoneBus_h.v                                              ////
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
// $Id: wishBoneBus_h.v,v 1.1.1.1 2004-10-11 04:00:57 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

 
//memoryMap
`define HCREG_BASE 8'h00
`define HCREG_BASE_PLUS_0X10 8'h10
`define HOST_RX_FIFO_BASE 8'h20
`define HOST_TX_FIFO_BASE 8'h30
`define SCREG_BASE 8'h40
`define SCREG_BASE_PLUS_0X10 8'h50
`define EP0_RX_FIFO_BASE 8'h60
`define EP0_TX_FIFO_BASE 8'h70
`define EP1_RX_FIFO_BASE 8'h80
`define EP1_TX_FIFO_BASE 8'h90
`define EP2_RX_FIFO_BASE 8'ha0
`define EP2_TX_FIFO_BASE 8'hb0
`define EP3_RX_FIFO_BASE 8'hc0
`define EP3_TX_FIFO_BASE 8'hd0
`define HOST_SLAVE_CONTROL_BASE 8'he0
`define ADDRESS_DECODE_MASK 8'hf0

//FifoAddresses
`define FIFO_DATA_REG 3'b000
`define FIFO_STATUS_REG 3'b001
`define FIFO_DATA_COUNT_MSB 3'b010
`define FIFO_DATA_COUNT_LSB 3'b011
`define FIFO_CONTROL_REG 3'b100



