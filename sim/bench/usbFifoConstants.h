/***************************************************************************
                          usbFifoConstants.h  -  description
                             -------------------
    begin                : Mon Dec 20 2004
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
#ifndef __usbFifoConstants_h
#define __usbFifoConstants_h



  // fifo adddresses
  enum FifoAddresses  {
    FIFO_DATA_REG = 0,
    FIFO_STATUS_REG,
    FIFO_DATA_COUNT_MSB,
    FIFO_DATA_COUNT_LSB,
    FIFO_CONTROL_REG   };

  enum fifoSizes {
    SMALLEST_FIFO_SIZE = 64,
    LARGEST_FIFO_SIZE = 64,
    HOST_TX_FIFO_SIZE = 64,
    HOST_RX_FIFO_SIZE = 64,
    SLAVE_TX0_FIFO_SIZE = 64,
    SLAVE_RX0_FIFO_SIZE = 64,
    SLAVE_TX1_FIFO_SIZE = 64,
    SLAVE_RX1_FIFO_SIZE = 64,
    SLAVE_TX2_FIFO_SIZE = 64,
    SLAVE_RX2_FIFO_SIZE = 64,
    SLAVE_TX3_FIFO_SIZE = 64,
    SLAVE_RX3_FIFO_SIZE = 64
    };

#endif
