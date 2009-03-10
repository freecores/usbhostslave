//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbConstants_h.v                                             ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////  USB global constants as defined by USB spec 1.1
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
// $Id: usbConstants_h.v,v 1.1.1.1 2004-10-11 04:00:57 sfielding Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

//PIDTypes
`define OUT 4'h1
`define IN 4'h9
`define SOF 4'h5
`define SETUP 4'hd
`define DATA0 4'h3
`define DATA1 4'hb
`define ACK 4'h2
`define NAK 4'ha
`define STALL 4'he
`define PREAMBLE 4'hc 
	   

//PIDGroups
`define SPECIAL 2'b00
`define TOKEN 2'b01
`define HANDSHAKE 2'b10
`define DATA 2'b11

// start of packet SyncByte
`define SYNC_BYTE 8'h80

       

