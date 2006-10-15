/***************************************************************************
                          usbHostSlaveMemMap.h  -  description
                             -------------------
    begin                : Sun Dec 12 2004
    copyright            : (C) 2004 by Steve Fielding
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
#ifndef __usbHostSlaveMemMap_h
#define __usbHostSlaveMemMap_h

#include "usbHostConstants.h"
#include "usbSlaveConstants.h"
#include "usbFifoConstants.h"
#include "usbHostSlaveCommonConstants.h"

     // top level memory regions
     enum memoryRegions {
       HCREG_BASE = 0x0,
       HOST_RX_FIFO_BASE = 0x20,
       HOST_TX_FIFO_BASE = 0x30,
       SCREG_BASE = 0x40,
       EP0_RX_FIFO_BASE = 0x60,
       EP0_TX_FIFO_BASE = 0x70,
       EP1_RX_FIFO_BASE = 0x80,
       EP1_TX_FIFO_BASE = 0x90,
       EP2_RX_FIFO_BASE = 0xa0,
       EP2_TX_FIFO_BASE = 0xb0,
       EP3_RX_FIFO_BASE = 0xc0,
       EP3_TX_FIFO_BASE = 0xd0,
       HOST_SLAVE_CONTROL_BASE = 0xe0 };


     enum hostSlaveCommonMemMap {
       RA_HOST_SLAVE_MODE = HOST_SLAVE_CONTROL_BASE + HOST_SLAVE_MODE_CTRL,
       RA_HOST_SLAVE_VERSION = HOST_SLAVE_CONTROL_BASE + HOST_SLAVE_VERSION_NUM
     };
 
#endif
