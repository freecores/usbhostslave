/***************************************************************************
                          usbSlaveConstants.h  -  description
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
#ifndef __usbSlaveConstants_h
#define __usbSlaveConstants_h


     enum endPointConstants {
       NUM_OF_ENDPOINTS = 4,
       NUM_OF_REGISTERS_PER_ENDPOINT = 4,
       BASE_INDEX_FOR_ENDPOINT_REGS = 0,
       ENDPOINT_CONTROL_REG = 0,
       ENDPOINT_STATUS_REG = 1,
       ENDPOINT_TRANSTYPE_STATUS_REG = 2,
       NAK_TRANSTYPE_STATUS_REG = 3 };
     enum SCRegIndices {
       LAST_ENDP_REG = BASE_INDEX_FOR_ENDPOINT_REGS + (NUM_OF_REGISTERS_PER_ENDPOINT * NUM_OF_ENDPOINTS) - 1,
       SC_CONTROL_REG,
       SC_LINE_STATUS_REG,
       SC_INTERRUPT_STATUS_REG,
       SC_INTERRUPT_MASK_REG,
       SC_ADDRESS,
       SC_FRAME_NUM_MSP,
       SC_FRAME_NUM_LSP,
       SCREG_BUFFER_LEN };
     enum SCRXStatusRegIndices {
       SC_CRC_ERROR_BIT = 0,
       SC_BIT_STUFF_ERROR_BIT,
       SC_RX_OVERFLOW_BIT,
       SC_RX_TIME_OUT_BIT,
       SC_NAK_SENT_BIT,
       SC_STALL_SENT_BIT,
       SC_ACK_RXED_BIT,
       SC_DATA_SEQUENCE_BIT };
     enum SCEndPointControlRegIndices {
       ENDPOINT_ENABLE_BIT = 0,
       ENDPOINT_READY_BIT,
       ENDPOINT_OUTDATA_SEQUENCE_BIT,
       ENDPOINT_SEND_STALL_BIT,
       ENDPOINT_ISO_ENABLE_BIT };
     enum SCMasterControlegIndices {
       SC_GLOBAL_ENABLE_BIT = 0,
       SC_TX_LINE_STATE_LSBIT,
       SC_TX_LINE_STATE_MSBIT,
       SC_DIRECT_CONTROL_BIT,
       SC_FULL_SPEED_LINE_POLARITY_BIT,
       SC_FULL_SPEED_LINE_RATE_BIT };
     enum SCinterruptRegIndices {
       SC_TRANS_DONE_BIT = 0,
       SC_RESUME_INT_BIT,
       SC_RESET_EVENT_BIT,    //Line has entered reset state, or left reset state
       SC_SOF_RECEIVED_BIT,
       SC_NAK_SENT_INT_BIT };
     enum SC_TXTransactionTypes {
       SC_SETUP_TRANS = 0,
       SC_IN_TRANS,
       SC_OUTDATA_TRANS };
     enum SC_timeOuts {
       SC_RX_PACKET_TOUT = 18 };
     enum SCFakeOutConstants {
       SC_TB_RX_TOUT = 0,
       SC_TB_DC_AND_IDLE_TRIG,
       SC_TB_RESET };

#endif
