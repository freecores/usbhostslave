/***************************************************************************
                          usbConstants.h  -  description
                             -------------------
    begin                : Tue Sep 23 2003
    copyright            : (C) 2003 by Steve Fielding
    email                : sfielding@base2designs.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
//USB global constants as defined by USB spec 1.1

#ifndef __usbConstants_h
#define __usbConstants_h



             
     enum PIDTypes {
       OUT = 0x1,
       IN = 0x9,
       SOF = 0x5,
       SETUP = 0xd,
       DATA0 = 0x3,
       DATA1 = 0xb,
       ACK = 0x2,
       NAK = 0xa,
       STALL = 0xe,
       PREAMBLE = 0xc };

     enum PIDGroups {
       SPECIAL = 0x0,
       TOKEN = 0x1,
       HANDSHAKE = 0x2,
       DATA = 0x3 };

     enum SyncByte {
       SYNC_BYTE = 0x80 };

       
       
#endif
