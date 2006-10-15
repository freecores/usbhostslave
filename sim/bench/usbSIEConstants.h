/***************************************************************************
                          usbSIEConstants.h  -  description
                             -------------------
    begin                : Fri Dec 17 2004
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
#ifndef __usbSIEConstants_h
#define __usbSIEConstants_h

     enum USBLineStates {
       // ONE_ZERO corresponds to differential 1. ie D+ = Hi, D- = Lo
       ONE_ZERO = 0x2,
       ZERO_ONE = 0x1,
       SE0 = 0x0,
       SE1 = 0x3 };

     enum limits {
       MAX_CONSEC_SAME_BITS = 6,
       RESUME_WAIT_TIME = 10,
       RESUME_LEN = 40,
       CONNECT_WAIT_TIME = 120,
       DISCONNECT_WAIT_TIME = 120 };

     enum RXConnectStates {
       DISCONNECT = 0,
       LOW_SPEED_CONNECT = 1,
       FULL_SPEED_CONNECT = 2 };

#endif
