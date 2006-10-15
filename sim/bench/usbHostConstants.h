/***************************************************************************
                          usbHostConstants.h  -  description
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
#ifndef __usbHostRegs_h
#define __usbHostRegs_h




     //constants
     enum timeOuts {
       RX_PACKET_TOUT = 18 };

     enum HCRegIndices {
       TX_CONTROL_REG=0,
       TX_TRANS_TYPE_REG,
       TX_LINE_CONTROL_REG,
       TX_SOF_ENABLE_REG,
       TX_ADDR_REG,
       TX_ENDP_REG,
       FRAME_NUM_MSB_REG,
       FRAME_NUM_LSB_REG,
       INTERRUPT_STATUS_REG,
       INTERRUPT_MASK_REG,
       RX_STATUS_REG,
       RX_PID_REG,
       RX_ADDR_REG,
       RX_ENDP_REG,
       RX_CONNECT_STATE_REG,
       SOF_TIMER_MSB_REG,
       HCREG_BUFFER_LEN /* must be last constant in this enum */
     };

     enum TXControlRegIndices {
       TRANS_REQ_BIT = 0,
       SOF_SYNC_BIT,
       PREAMBLE_ENABLE_BIT,
       ISO_ENABLE_BIT };
     enum interruptRegIndices {
       TRANS_DONE_BIT = 0,
       RESUME_INT_BIT,
       CONNECTION_EVENT_BIT,
       SOF_SENT_BIT };
     enum RXStatusRegIndices {
       CRC_ERROR_BIT = 0,
       BIT_STUFF_ERROR_BIT,
       RX_OVERFLOW_BIT,
       RX_TIME_OUT_BIT,
       NAK_RXED_BIT,
       STALL_RXED_BIT,
       ACK_RXED_BIT,
       DATA_SEQUENCE_BIT };
     enum TXTransactionTypes {
       SETUP_TRANS = 0,
       IN_TRANS,
       OUTDATA0_TRANS,
       OUTDATA1_TRANS };
     enum TXLineControlIndices {
       TX_LINE_STATE_LSBIT = 0,
       TX_LINE_STATE_MSBIT,
       DIRECT_CONTROL_BIT,
       FULL_SPEED_LINE_POLARITY_BIT,
       FULL_SPEED_LINE_RATE_BIT };
     enum TXSOFEnableIndices {
       SOF_EN_BIT = 0 };
     enum SOFTimeConstants {
       SOF_TX_TIME = 20,
       SOF_TX_MARGIN = 2 };
     enum HCFakeOutConstants {
       HC_TB_RX_TOUT = 0,
       HC_TB_DC_AND_IDLE_TRIG,
       HC_TB_SOF_TRIG,
       HC_TB_RESET };



#endif
