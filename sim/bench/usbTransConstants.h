/***************************************************************************
                          usbTransConstants.h  -  description
                             -------------------
    begin                : Mon Jan 24 2005
    copyright            : (C) 2005 by Steve Fielding
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
//USB transaction constants as defined by USB spec 1.1

#ifndef __usbTransConstants_h
#define __usbTransConstants_h


#define STD_REQUEST 0

     enum descriptorValues {
       DEVICE_DESCRIPTOR = 0x1
       };
             
     enum StdRequests {
       SET_ADDRESS = 0x5,
       GET_DESCRIPTOR = 0x6
       };


       
       
#endif
