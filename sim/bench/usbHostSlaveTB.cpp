/***************************************************************************
                          usbHostSlaveTB.cpp  -  description
                             -------------------
    begin                : Mon Sep 25 2006
    copyright            : (C) 2006 by Steve Fielding
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
#include "condCompileFlags.h"

#ifdef SYSTEMC_TB
#include "systemc.h"
#include "transactor.h"
#else
#include <stdio.h>
#include <stdlib.h>
#include <iostream.h>
#ifdef UCLINUX_TB
#else
#include "altera_avalon_pio_regs.h"
#include "hw_address_defines.h"
#include "system.h"
#endif
#include "bus_if.h"
#endif

#include "usbHostSlaveTB.h"
#include "usbHostSlaveMemMap.h"
#include "usbSIEConstants.h"
#include "usbFifoConstants.h"

#define VERBOSE_PRINT
#ifdef VERBOSE_PRINT
#define PRT(stuff...)   cout << stuff
#else
#define PRT(stuff...)   do{}while(0)
#endif

/* ------------------------------- main ---------------------------------- */
void usbHostSlaveTB::main()
{
  int i;
  int tempDataFromHost;
  int tempDataFromHost2;
  int USBEndPoint;
  int USBAddress;
  int dataPacketSize;
  int versionNum;
  int fullSpeedRate;
  int firstFrameNumMSB;
  int firstFrameNumLSB;
  int expectedFrameNum;

  cout << "-------- usbHostSlave TestBench ---------\n";
  systemRstCtrl();
  usbLineControl(SE0);       //set default line state
  waitUSBClockTicks(30);     //allow time for reset to propagate, especially re-sync'd resets
  hostBusRead(versionNum, RA_HOST_SLAVE_VERSION);
  printf("Host Version number = %2d.%1d\n", (versionNum >> 4) & 0xf, versionNum & 0xf);
  slaveBusRead(versionNum, RA_HOST_SLAVE_VERSION);
  printf("Slave Version number = %2d.%1d\n", (versionNum >> 4) & 0xf, versionNum & 0xf);


  cout << "Register write/read test...\n";
  hostBusWrite(1, HOST_SLAVE_CONTROL_BASE);  //set host mode
  slaveBusWrite(0, HOST_SLAVE_CONTROL_BASE);  //set slave mode
  writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off
  waitUSBClockTicks(2);
  readXCReg(HOST, tempDataFromHost, HOST_SLAVE_CONTROL_BASE, 1, 0xff);
  readXCReg(HOST, tempDataFromHost, TX_LINE_CONTROL_REG, 0x18, 0xff);
  readXCReg(SLAVE, tempDataFromHost, SC_CONTROL_REG, 0x30, 0xff);
  
  cout << "Reset register test...\n";
  hostBusWrite(2, HOST_SLAVE_CONTROL_BASE);  //reset first usbhostslave instance
  slaveBusWrite(2, HOST_SLAVE_CONTROL_BASE);  //reset second usbhostslave instance
  waitUSBClockTicks(30);  //allow time for logic to reset
  readXCReg(HOST, tempDataFromHost, HOST_SLAVE_CONTROL_BASE, 0, 0xff);
  readXCReg(HOST, tempDataFromHost, TX_LINE_CONTROL_REG, 0x0, 0xff);
  readXCReg(SLAVE, tempDataFromHost, SC_CONTROL_REG, 0x00, 0xff);
  
  //Configure usbhostslave instances as host and slave 
  hostBusWrite(1, HOST_SLAVE_CONTROL_BASE);  //set host mode
  writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  slaveBusWrite(0, HOST_SLAVE_CONTROL_BASE); //set slave mode
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off

  //disconnect
  cout << "\nDisconnecting...\n";
  connection(SE0, DISCONNECT_WAIT_TIME*32, 0, 0);     //set default line state to single ended zero, ie disconnect

  //connect low speed
  cout << "\nConnecting low speed...\n";
  connection(ZERO_ONE, CONNECT_WAIT_TIME*32, 1, 1);     //set default line state to ZERO_ONE, ie connect low speed

  //disconnect
  cout << "\nDisconnecting...\n";
  connection(SE0, DISCONNECT_WAIT_TIME*32, 1, 1);     //set default line state to single ended zero, ie disconnect

  //connect full speed
  cout << "\nConnecting full speed...\n";
  connection(ONE_ZERO, CONNECT_WAIT_TIME*4, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed

  //host forces a reset
  cout << "\nHost forcing reset...\n";
  writeXCReg(HOST, 0x1c, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state SE0
  waitUSBClockTicks(DISCONNECT_WAIT_TIME*4+100);
  readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, (1 << SC_RESET_EVENT_BIT), 0xff);
  readXCReg(SLAVE, tempDataFromHost2, SC_LINE_STATUS_REG, DISCONNECT, 0xff);
  printf("SISR = 0x%0x, slave line state = 0x%0x \n", tempDataFromHost, tempDataFromHost2);
  cout << "Cancel reset event interrupt\n";

  cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);

  //re-connect at full speed
  writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  cout << "Reconnecting at full speed...\n";
  connection(ONE_ZERO, CONNECT_WAIT_TIME*4, 0, 1);     //set default line state to ONE_ZERO, ie connect full speed

  //slave forces a disconnect
  cout << "\nSlave forcing disconnect...\n";
  writeXCReg(SLAVE, 0x38, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state SE0, global enable off
  waitUSBClockTicks(DISCONNECT_WAIT_TIME*4+100);
  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, (1 << CONNECTION_EVENT_BIT), 0xff);
  readXCReg(HOST, tempDataFromHost2, RX_CONNECT_STATE_REG, DISCONNECT, 0xff);
  printf("HISR =  0x%0x, host line state = 0x%0x\n", tempDataFromHost, tempDataFromHost2);
  cout << "Cancel host interrupt\n";
  cancelInterrupt(HOST, CONNECTION_EVENT_BIT);

  //re-connect at full speed
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off
  cout << "Reconnecting at full speed...\n";
  connection(ONE_ZERO, CONNECT_WAIT_TIME*4+100, 1, 0);     //set default line state to ONE_ZERO, ie connect full speed

  //Enable host SOF transmission (forces a resume)
  //Note that the resume transmission mechanism is different for host and slave
  //Notably when the host transmits resume, it will transmit 'RESUME_LEN' KBits
  //without any time progression (ie within delta cycles), whereas the slave
  //transmits resume as a direct line control at a rate of one byte per fake timing event
  cout << "\nEnabling host SOF transmission\n";
  writeXCReg(HOST, 0x1, TX_SOF_ENABLE_REG); //enable SOF transmission
  waitUSBClockTicks(RESUME_WAIT_TIME*32+100);
  cout << "Checking for resume interrupt...\n";
  readXCReg(SLAVE, tempDataFromHost2, SC_INTERRUPT_STATUS_REG, (1 << SC_RESUME_INT_BIT), 0xff);  //check for resume interrupt
  printf("HISR =  0x%0x, SISR = 0x%0x\n" ,tempDataFromHost, tempDataFromHost2);
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  cout << "Checking for SOF packets...\n";
  for (i=0;i<=1;i++) {
    slaveBusRead(tempDataFromHost, SCREG_BASE + SC_INTERRUPT_STATUS_REG);
    while ( tempDataFromHost == 0) {
      waitUSBClockTicks(SOF_TX_TIME*4);
      slaveBusRead(tempDataFromHost, SCREG_BASE + SC_INTERRUPT_STATUS_REG);
    }
    cancelInterrupt(SLAVE, SC_SOF_RECEIVED_BIT);
    if (i == 0) {
      readXCReg(SLAVE, tempDataFromHost, SC_FRAME_NUM_MSP, ((i % 2048) / 256) , 0x00);
      readXCReg(SLAVE, tempDataFromHost2, SC_FRAME_NUM_LSP, (i % 256), 0x00);
      firstFrameNumMSB = tempDataFromHost;
      firstFrameNumLSB = tempDataFromHost2;
    }
    else {
      expectedFrameNum = i + (firstFrameNumMSB * 256) + firstFrameNumLSB; 
      readXCReg(SLAVE, tempDataFromHost, SC_FRAME_NUM_MSP, ((expectedFrameNum % 2048) / 256) , 0xff);
      readXCReg(SLAVE, tempDataFromHost2, SC_FRAME_NUM_LSP, (expectedFrameNum % 256), 0xff);
    } 
    printf("SOF Frame count %d = 0x%0x\n", i, (tempDataFromHost * 256) + tempDataFromHost2);
    readXCReg(HOST, tempDataFromHost, SOF_TIMER_MSB_REG, 0x0, 0x0);
    printf("Host SOF Timer MSB = 0x%0x\n", tempDataFromHost);
  }
  cout << "Disabling SOF transmission\n";
  writeXCReg(HOST, 0x0, TX_SOF_ENABLE_REG); //disable SOF transmission
  waitUSBClockTicks(RESUME_LEN*4+100); //wait for last SOF to be flushed out
  cout << "For slave, cancel resume interrupt, and SOF received interrupt\n";
  cout << "For host, cancel SOF sent interrupt\n";
  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, (1 << SOF_SENT_BIT) , 0xff);
  cancelInterrupt(HOST, SOF_SENT_BIT);
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  cancelInterrupt(SLAVE, SC_SOF_RECEIVED_BIT);

  //Slave forces resume
  cout << "\nSlave forcing resume...\n";
  writeXCReg(SLAVE, 0x3a, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state ZERO_ONE (full speed resume), global enable off
  waitUSBClockTicks(RESUME_WAIT_TIME*32+100);

  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, (1 << RESUME_INT_BIT), 0xff);
  readXCReg(HOST, tempDataFromHost2, RX_CONNECT_STATE_REG, FULL_SPEED_CONNECT, 0xff);
  printf("HISR = 0x%0x , host line state = 0x%0x \n", tempDataFromHost, tempDataFromHost2);
  cout << "Cancel resume interrupt\n";
  cancelInterrupt(HOST, RESUME_INT_BIT);
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off
  waitUSBClockTicks(10*4); //wait for some idle bits to be sent
  readXCReg(HOST, tempDataFromHost, RX_CONNECT_STATE_REG, FULL_SPEED_CONNECT, 0xff);
  printf("Resume recovery check , host line state = 0x%0x\n", tempDataFromHost);

  cout << "\nTransaction tests...\n";
  //set up some variables and pointers used for send transaction tests
  writeXCReg(SLAVE, 0x31, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable on
  fullSpeedRate = 1;
    
  for (USBAddress = 0; USBAddress <=127; USBAddress = USBAddress + 127) {
  //for (USBAddress = 0; USBAddress <=127; USBAddress = USBAddress + 1) {
    writeXCReg(SLAVE, USBAddress, SC_ADDRESS);       //set slave usb address
    for (dataPacketSize = 0; dataPacketSize <= SMALLEST_FIFO_SIZE; dataPacketSize = dataPacketSize+64) {
    //for (dataPacketSize = 1; dataPacketSize <= SMALLEST_FIFO_SIZE; dataPacketSize = dataPacketSize+1) {
      for (USBEndPoint = 0; USBEndPoint <=3; USBEndPoint++) {
        PRT("\n------------------------------------\n");
        //PRT("USBAddress = %d  USBEndPoint = %d \n", USBAddress, USBEndPoint);
        PRT("USBAddress = " << USBAddress << " USBEndPoint = " << USBEndPoint << endl);
        PRT("------------------------------------\n");

        //SETUP - NAK'd
        PRT("\nNAK'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT), fullSpeedRate);

        //SETUP - ACK'd
        PRT("\nACK'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //SETUP - STALL'd
        PRT("\nSTALL'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, SEQ_GEN, 1, 0xb, fullSpeedRate);

        //SETUP - timed out
        PRT("\nTimed out SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, 0x0, fullSpeedRate);

        //OUTDATA0 - ACK'd
        PRT("\nACK'd OUTDATA0\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA0_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //OUTDATA1 - ACK'd
        PRT("\nACK'd OUTDATA1\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA1_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //OUTDATA1 - NAK'd
        PRT("\nNAK'd OUTDATA1\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA1_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT), fullSpeedRate);

        //INDATA (DATA0) - ACK'd
        PRT("\nACK'd INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x3);

        //INDATA (DATA1) - ACK'd
        PRT("\nACK'd INDATA (DATA1)\n");

        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x7);

        //INDATA (DATA0) - NAK'd
        PRT("\nNAK'd INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT));

        //INDATA (DATA0) - Timed out
        PRT("\nTimed out INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x0);
      }
    }
  }

#define TEST_ISO_MODE
#ifdef TEST_ISO_MODE
  writeXCReg(SLAVE, 0, SC_ADDRESS);       //set slave usb address
  //OUT0 - ISO
  cout << "\nISO OUT0\n";
  sendTransaction(0, 0, OUTDATA0_TRANS, 64, RAND_GEN, 1, 0x13, 1); 

#endif

#define DEBUG_LS
#ifdef DEBUG_LS
  //disconnect
  cout << "\nDisconnecting...\n";
  connection(SE0, DISCONNECT_WAIT_TIME*4, 1, 1);
  //connect low speed
  cout << "\nConnecting low speed...\n";
  connection(ZERO_ONE, CONNECT_WAIT_TIME*32, 1, 1);     //set default line state to ONE_ZERO, ie connect low speed
  writeXCReg(SLAVE, 0x1, SC_CONTROL_REG);  //low speed polarity and bit rate, direct control off, line state don't care, global enable on
  writeXCReg(HOST, 0x0, TX_LINE_CONTROL_REG);  //low speed polarity and bit rate, direct control off, line state don't care

  writeXCReg(SLAVE, 0, SC_ADDRESS);       //set slave usb address
  //SETUP - ACK'd
  cout << "\nLow Speed ACK'd SETUP\n";
  sendTransaction(0, 0, SETUP_TRANS, 64, RAND_GEN, 1, 0x3, 0);
#endif

  cout << "\n-----------------------------------------------\n";
  cout << "USBHostSlave verification completed successfully\n";
  quit(0);
}













/* ------------------------------- connection ---------------------------------- */
void usbHostSlaveTB::connection(int lineState, int waitTime, int hostInterruptExpected, int slaveInterruptExpected)
{
  int tempDataFromHost;
  int tempDataFromHost2;
  int expectedData;
  int expectedConnectState;



  if (lineState == ZERO_ONE) {
    expectedConnectState = LOW_SPEED_CONNECT;
    writeXCReg(HOST, 0x00, TX_LINE_CONTROL_REG);  //low speed polarity and bit rate, direct control off, line state don't care
    writeXCReg(SLAVE, 0x00, SC_CONTROL_REG);  //low speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  else if (lineState == ONE_ZERO) {
    expectedConnectState = FULL_SPEED_CONNECT;
    writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
    writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off


  }
  else if (lineState == SE0) expectedConnectState = DISCONNECT;
    else expectedConnectState = DISCONNECT;
  usbLineControl(lineState);                                  //set default line state
  waitUSBClockTicks(waitTime+100);              //allow 'waitTime' samples to be clocked through
  if (hostInterruptExpected)
    expectedData = (1 << CONNECTION_EVENT_BIT);
  else
    expectedData = 0x0;
  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, expectedData, (1 << CONNECTION_EVENT_BIT) );
  readXCReg(HOST, tempDataFromHost2, RX_CONNECT_STATE_REG, expectedConnectState, 0xff);
  printf("Host interrupt status reg (HISR) = 0x%0x , host line state = 0x%0x \n", tempDataFromHost, tempDataFromHost2);
  if (slaveInterruptExpected)
    expectedData = (1 << SC_RESET_EVENT_BIT);
  else
    expectedData = 0x0;
  readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, expectedData , (1 << SC_RESET_EVENT_BIT) );
  readXCReg(SLAVE, tempDataFromHost2, SC_LINE_STATUS_REG, expectedConnectState, 0xff );
  printf("Slave interrupt status reg (SISR) = 0x%0x , slave line state = 0x%0x \n", tempDataFromHost, tempDataFromHost2);
  cout << "Cancel interrupts\n";
  cancelInterrupt(HOST, CONNECTION_EVENT_BIT);
  cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);
}

/* ------------------------------- cancelInterrupt ---------------------------------- */
void usbHostSlaveTB::cancelInterrupt(int hostSlaveSel, int interruptBit)
{
int tempDataFromHost;

  if (hostSlaveSel == HOST) {
    writeXCReg(HOST, 1 << interruptBit, INTERRUPT_STATUS_REG);
    readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, 0x0, (1 << interruptBit) );
  }
  else {
    writeXCReg(SLAVE, 1 << interruptBit, SC_INTERRUPT_STATUS_REG);
    readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, 0x0, (1 << interruptBit) );
  }

}

/* ------------------------------- readXCRegNoQuit ---------------------------------- */
void usbHostSlaveTB::readXCRegNoQuit(int hostSlaveSel, int &rxedData, int regOffset, int expectedData, int rxDataMask, int &errorDetected)
{
  if (hostSlaveSel == HOST) {
    hostBusRead(rxedData, HCREG_BASE + regOffset);
    if ( (rxedData & rxDataMask) != expectedData) {
      errorDetected = 1;
      printf("HCReg[0x%0x] & mask = (0x%0x & 0x%0x) = 0x%0x , expecting 0x%0x \n", regOffset, rxedData, rxDataMask, (rxedData & rxDataMask), expectedData);
    }
  }
  else {
    slaveBusRead(rxedData, SCREG_BASE + regOffset);
    if ( (rxedData & rxDataMask)  != expectedData) {
      errorDetected = 1;
      printf("SCReg[0x%0x] & mask = (0x%0x & 0x%0x) = 0x%0x , expecting 0x%0x \n", regOffset, rxedData, rxDataMask, (rxedData & rxDataMask), expectedData);
    }
  }
}

/* ------------------------------- readXCReg ---------------------------------- */
void usbHostSlaveTB::readXCReg(int hostSlaveSel, int &rxedData, int regOffset, int expectedData, int rxDataMask)
{
  if (hostSlaveSel == HOST) {
    hostBusRead(rxedData, HCREG_BASE + regOffset);
    if ( (rxedData & rxDataMask) != expectedData) {
      printf("HCReg[0x%0x] & mask = (0x%0x & 0x%0x) = 0x%0x , expecting 0x%0x \n", regOffset, rxedData, rxDataMask, (rxedData & rxDataMask), expectedData);
      quit(1);
    }
  }
  else {
    slaveBusRead(rxedData, SCREG_BASE + regOffset);
    if ( (rxedData & rxDataMask)  != expectedData) {
      printf("SCReg[0x%0x] & mask = (0x%0x & 0x%0x) = 0x%0x , expecting 0x%0x \n", regOffset, rxedData, rxDataMask, (rxedData & rxDataMask), expectedData);
      quit(1);
    }
  }
}

/* ------------------------------- writeXCReg ---------------------------------- */
void usbHostSlaveTB::writeXCReg(int hostSlaveSel, int data, int regOffset)
{
  if (hostSlaveSel == HOST)
    hostBusWrite(data, HCREG_BASE + regOffset);
  else
    slaveBusWrite(data, SCREG_BASE + regOffset);
}


/* ------------------------------- sendTransaction ---------------------------------- */
void usbHostSlaveTB::sendTransaction(int USBAddress, int USBEndPoint, int transType, int dataSize, int dataGenType, int waitTime, int endPControlReg, int fullSpeedRate)
{
  int i;
  int endPointStatusRegAddress;
  int endPointControlRegAddress;
  int endPointTransTypeRegAddress;
  int endPointNAKTransTypeRegAddress;
  int tempDataFromHost;
  int tempDataFromHost2;
  int fifoBaseAddress;
  int expectedTransTypeAtSlave;
  int numOfElementsInRXFifo;
  int data [LARGEST_FIFO_SIZE];
  int dataSeqeunceBit;
  int expectedDataCnt;
  int errorDetected;
  
  errorDetected = 0;
  
  switch (dataGenType)
  {
    case NO_GEN:
      //data payload provided by caller. Do nothing
      break;
    case SEQ_GEN:
      for (i=0;i<dataSize;i++)
        data[i] = i;
      break;
    case RAND_GEN:
      for (i=0;i<dataSize;i++)
        data[i] = rand() & 0xff;
      break;
    default:

      printf("(sendTransaction) dataGenType = 0x%0x  not a valid type\n", dataGenType);
      quit(1);
      break;
  }

  dataSeqeunceBit = 0;
  switch (transType)
  {
    case SETUP_TRANS:
      PRT("SETUP");
      expectedTransTypeAtSlave = SC_SETUP_TRANS;
      break;
    case OUTDATA1_TRANS:
      dataSeqeunceBit = 1 << SC_DATA_SEQUENCE_BIT;
      PRT("OUTDATA1");
      expectedTransTypeAtSlave = SC_OUTDATA_TRANS;
      break;
    case OUTDATA0_TRANS:
      PRT("OUTDATA0");
      expectedTransTypeAtSlave = SC_OUTDATA_TRANS;
      break;
    default:
      printf("sendTransaction - Invalid transactionType 0x%0x aborting\n", transType);
      quit(1);

      break;
  }

  PRT(" transaction, with a " << dataSize << " byte data packet\n");

  switch (USBEndPoint)
  {
    case 0:
      fifoBaseAddress = EP0_RX_FIFO_BASE;
      break;
    case 1:
      fifoBaseAddress = EP1_RX_FIFO_BASE;
      break;
    case 2:
      fifoBaseAddress = EP2_RX_FIFO_BASE;
      break;
    case 3:
      fifoBaseAddress = EP3_RX_FIFO_BASE;
      break;
    default:
      printf("Invalid endpoint %d \n", USBEndPoint);
      quit(1);
      break;
  }

  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointStatusRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_STATUS_REG;
  endPointTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_TRANSTYPE_STATUS_REG;
  endPointNAKTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + NAK_TRANSTYPE_STATUS_REG;
 
  writeXCReg(SLAVE, endPControlReg, endPointControlRegAddress);
  writeXCReg(HOST, USBAddress, TX_ADDR_REG);
  writeXCReg(HOST, USBEndPoint, TX_ENDP_REG);
  writeXCReg(HOST, transType, TX_TRANS_TYPE_REG);
  for (i=0; i<dataSize; i++)
    hostBusWrite(data[i], HOST_TX_FIFO_BASE + FIFO_DATA_REG);
  if ((endPControlReg & (1 << ENDPOINT_ISO_ENABLE_BIT)) == 0)    //if not iso mode
    writeXCReg(HOST, (1 << TRANS_REQ_BIT), TX_CONTROL_REG); //then
  else
    //writeXCReg(HOST, (1 << TRANS_REQ_BIT) & (1 << ISO_ENABLE_BIT), TX_CONTROL_REG);
    writeXCReg(HOST, 0x9, TX_CONTROL_REG);
  if (fullSpeedRate == 1)
    waitUSBClockTicks(500+dataSize*100);    //suspend test bench so that DUT can process the packet
  else
    waitUSBClockTicks(20000+dataSize*4000);  //suspend test bench so that DUT can process the packet
  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, (1 << TRANS_DONE_BIT), 0xff);
  expectedDataCnt = 0;
  if ( (endPControlReg & (1 << ENDPOINT_ENABLE_BIT) ) != 0) {
    if ( (endPControlReg & (1 << ENDPOINT_READY_BIT) ) != 0) {
      expectedDataCnt = dataSize;
      readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, (1 << SC_TRANS_DONE_BIT), 0xff);
      readXCReg(SLAVE, tempDataFromHost, endPointTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
    else {
      readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, (1 << SC_NAK_SENT_INT_BIT), 0xff);
      readXCReg(SLAVE, tempDataFromHost, endPointNAKTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
  }
  slaveBusRead(tempDataFromHost, fifoBaseAddress + FIFO_DATA_COUNT_MSB);
  slaveBusRead(tempDataFromHost2, fifoBaseAddress + FIFO_DATA_COUNT_LSB);
  numOfElementsInRXFifo = (tempDataFromHost * 256) +  tempDataFromHost2;
  PRT("Slave EndPoint " << USBEndPoint << " RX FIFO has  " << numOfElementsInRXFifo << " elements\n");
  if (expectedDataCnt != numOfElementsInRXFifo) {
    cout << "Data packet incorrect size. Expected " << expectedDataCnt << " bytes, received " << numOfElementsInRXFifo << " bytes\n";
    errorDetected = 1;
  }
  for (i=0;i<numOfElementsInRXFifo;i++) {
    slaveBusRead(tempDataFromHost, fifoBaseAddress + FIFO_DATA_REG);
    if (tempDataFromHost != data[i]) {
      printf("Data mismatch.  TX data [0x%0x] = 0x%0x RX data[0x%0x] = 0x%0x. Aborting\n", i, data[i], i, tempDataFromHost);
      errorDetected = 1;
    }
  }
  if (numOfElementsInRXFifo > 0 && errorDetected == 0)
    PRT("RX packet matches TX packet\n");

  cancelInterrupt(SLAVE, SC_TRANS_DONE_BIT);
  cancelInterrupt(SLAVE, SC_NAK_SENT_INT_BIT);
  cancelInterrupt(HOST, TRANS_DONE_BIT);

  switch (endPControlReg & 0xf)
  {
  case 0x0:  //endpoint disabled
  case 0x2:  //endpoint ready, but disabled. Not a valid control state, but disable should pre-dominate
    readXCReg(HOST, tempDataFromHost, RX_STATUS_REG, (1 << RX_TIME_OUT_BIT), 0xff);  //expecting host to receive time out
    //expecting no response from host
    break;
  case 0x1:  //endpoint enabled, but not ready
    readXCReg(SLAVE, tempDataFromHost, endPointStatusRegAddress, (1 << SC_NAK_SENT_BIT), (1 << SC_NAK_SENT_BIT));  //expecting slave to send NAK
    readXCReg(HOST, tempDataFromHost, RX_STATUS_REG, (1 << NAK_RXED_BIT), 0xff);  //expecting NAK at host

    break;
  case 0x3: //endpoint enabled, and ready
    readXCReg(SLAVE, tempDataFromHost, endPointStatusRegAddress, dataSeqeunceBit , 0xff);  //expecting no errors at the slave
    if ((endPControlReg & (1 << ENDPOINT_ISO_ENABLE_BIT)) == 0)    //if not iso mode
      readXCReg(HOST, tempDataFromHost, RX_STATUS_REG, (1 << ACK_RXED_BIT), 0xff);  //expecting host to receive ACK
    //if ENDPOINT_ISO_ENABLE_BIT == 1 then no response form slave, no need to check RX_STATUS_REG
    break;
  case 0xb: //endpoint enabled, ready, send stall.
    readXCReg(SLAVE, tempDataFromHost, endPointStatusRegAddress, (1 << SC_STALL_SENT_BIT) | dataSeqeunceBit, 0xff);  //expecting slave to send stall
    readXCReg(HOST, tempDataFromHost, RX_STATUS_REG, (1 << STALL_RXED_BIT), 0xff);  //expecting host to receive STALL
    break;
  default:
    printf("sendTransaction: Umimplemented endPControlReg 0x%0x\n", USBEndPoint);
    quit(1);
    break;
  }
  if (errorDetected == 1) 
    quit(1);
}

/* ------------------------------- rxTransaction ---------------------------------- */

void usbHostSlaveTB::rxTransaction(int USBAddress, int USBEndPoint, int transType, int dataSize, int dataGenType, int waitTime, int endPControlReg)
{
  int i;
  int endPointStatusRegAddress;
  int endPointTransTypeRegAddress;
  int endPointControlRegAddress;
  int endPointNAKTransTypeRegAddress;
  int tempDataFromHost;
  int tempDataFromHost2;
  int fifoBaseAddress;
  int expectedTransTypeAtSlave;
  int numOfElementsInRXFifo;
  int data [64];
  int dataSequenceBitAtHost;
  int expectedDataCnt;
  int errorDetected;
  
  
  errorDetected = 0;
  switch (dataGenType)
  {
    case NO_GEN:
      //data payload provided by caller. Do nothing
      break;
    case SEQ_GEN:
      for (i=0;i<dataSize;i++)

        data[i] = i;
      break;
    case RAND_GEN:
      for (i=0;i<dataSize;i++)
        data[i] = rand() & 0xff;
      break;
    default:
      printf("(sendTransaction) dataGenType = 0x%0x not a valid type\n", dataGenType);
      quit(1);
      break;
  }
  expectedTransTypeAtSlave = SC_IN_TRANS;
  PRT("INDATA transaction, with a " << dataSize << " byte data packet\n");
  endPointStatusRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_STATUS_REG;
  endPointTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_TRANSTYPE_STATUS_REG;
  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointNAKTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + NAK_TRANSTYPE_STATUS_REG;

  writeXCReg(SLAVE, endPControlReg, endPointControlRegAddress);
  writeXCReg(HOST, USBAddress, TX_ADDR_REG);
  writeXCReg(HOST, USBEndPoint, TX_ENDP_REG);
  writeXCReg(HOST, transType, TX_TRANS_TYPE_REG);
  switch (USBEndPoint)
  {
    case 0:
      fifoBaseAddress = EP0_TX_FIFO_BASE;
      break;
    case 1:
      fifoBaseAddress = EP1_TX_FIFO_BASE;
      break;
    case 2:
      fifoBaseAddress = EP2_TX_FIFO_BASE;
      break;
    case 3:
      fifoBaseAddress = EP3_TX_FIFO_BASE;
      break;
    default:
      printf("Invalid endpoint 0x%0x \n", USBEndPoint);
      quit(1);
      break;
  }

  for (i=0; i<dataSize; i++)
    slaveBusWrite(data[i], fifoBaseAddress + FIFO_DATA_REG);
  writeXCReg(HOST, (1 << TRANS_REQ_BIT), TX_CONTROL_REG);
  waitUSBClockTicks(500+dataSize*100);   //suspend test bench so that DUT can process the packet


  expectedDataCnt = 0;
  if ( (endPControlReg & (1 << ENDPOINT_ENABLE_BIT) ) != 0) {
    if ( (endPControlReg & (1 << ENDPOINT_READY_BIT) ) != 0) {
      expectedDataCnt = dataSize;
      readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, (1 << SC_TRANS_DONE_BIT), 0xff);
      readXCReg(SLAVE, tempDataFromHost, endPointTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
    else {
      readXCReg(SLAVE, tempDataFromHost, SC_INTERRUPT_STATUS_REG, (1 << SC_NAK_SENT_INT_BIT), 0xff);
      readXCReg(SLAVE, tempDataFromHost, endPointNAKTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
  }
  readXCReg(HOST, tempDataFromHost, INTERRUPT_STATUS_REG, (1 << TRANS_DONE_BIT), 0xff);

  hostBusRead(tempDataFromHost, HOST_RX_FIFO_BASE + FIFO_DATA_COUNT_MSB);
  hostBusRead(tempDataFromHost2, HOST_RX_FIFO_BASE + FIFO_DATA_COUNT_LSB);
  numOfElementsInRXFifo = (tempDataFromHost * 256) +  tempDataFromHost2;
  PRT("Host RX FIFO has " << numOfElementsInRXFifo << " elements\n");
  if (expectedDataCnt != numOfElementsInRXFifo) {
    printf("Data packet incorrect size. Expected %d bytes, received %d bytes\n", expectedDataCnt, numOfElementsInRXFifo);
    errorDetected = 1;
  }
  for (i=0;i<numOfElementsInRXFifo;i++) {
    hostBusRead(tempDataFromHost, HOST_RX_FIFO_BASE + FIFO_DATA_REG);
    if (tempDataFromHost != data[i]) {
      printf("Data mismatch.  TX data [0x%0x] = 0x%0x RX data[0x%0x] = 0x%0x. Aborting\n", i, data[i], i, tempDataFromHost);
      errorDetected = 1;
    }
    //printf("RX data[" << i << "] = " << hex << tempDataFromHost << "\n");
  }

  if (numOfElementsInRXFifo > 0 && errorDetected == 0)
    PRT("RX packet matches TX packet\n");
  cancelInterrupt(SLAVE, SC_TRANS_DONE_BIT);

  cancelInterrupt(SLAVE, SC_NAK_SENT_INT_BIT);
  cancelInterrupt(HOST, TRANS_DONE_BIT);
  readXCReg(HOST, tempDataFromHost, TX_CONTROL_REG, 0, (1 << TRANS_REQ_BIT)); //check that the bit was set
  printf("TX_CONTROL_REG = 0x%0x\n", tempDataFromHost);


  if (endPControlReg & (1 << ENDPOINT_OUTDATA_SEQUENCE_BIT) )
    dataSequenceBitAtHost = 1 << DATA_SEQUENCE_BIT;
  else
    dataSequenceBitAtHost = 0;
  switch (endPControlReg & 0xb)
  {
  case 0x0:  //endpoint disabled
  case 0x2:  //endpoint ready, but disabled. Not a valid control state, but disable should pre-dominate
    readXCRegNoQuit(HOST, tempDataFromHost, RX_STATUS_REG, (1 << RX_TIME_OUT_BIT), 0xff, errorDetected);  //expecting host to receive time out
    slaveBusWrite(0x1, fifoBaseAddress + FIFO_CONTROL_REG);     //force the slave tx fifo empty
    break;
  case 0x1:  //endpoint enabled, but not ready
    readXCRegNoQuit(SLAVE, tempDataFromHost, endPointStatusRegAddress, (1 << SC_NAK_SENT_BIT), (1 << SC_NAK_SENT_BIT), errorDetected);  //expecting slave to send NAK
    readXCRegNoQuit(HOST, tempDataFromHost, RX_STATUS_REG, (1 << NAK_RXED_BIT), 0xff, errorDetected);  //expecting NAK at host
    slaveBusWrite(0x1, fifoBaseAddress + FIFO_CONTROL_REG);     //force the slave tx fifo empty
    break;
  case 0x3: //endpoint enabled, and ready
    readXCRegNoQuit(SLAVE, tempDataFromHost, endPointStatusRegAddress, (1 << SC_ACK_RXED_BIT) , 0xff, errorDetected);  //expecting slave to receive ACK
    readXCRegNoQuit(HOST, tempDataFromHost, RX_STATUS_REG, dataSequenceBitAtHost, 0xff, errorDetected);  //expecting no errors at the host
    break;
  case 0xb: //endpoint enabled, ready, send stall.
    printf("rxTransaction: Unexpected endPControlReg = 0x%0x \n", endPControlReg);
    errorDetected = 1;
    break;
  default:
    printf("rxTransaction: Unimplemented endPControlReg 0x%0x \n", USBEndPoint);
    errorDetected = 1;
    break;
  }
  if (errorDetected == 1)
    quit(1);
}

/* ------------------------------- quit ---------------------------------- */
void usbHostSlaveTB::quit(int errorLevel)
{
  if (errorLevel != 0)
    cout << "Verification ERROR. Simulation stopped\n";
#ifdef SYSTEMC_TB
  sc_stop();
#else
  exit(errorLevel);
#endif
}


/* -------------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------------- */
/* ------- SystemC port accesses, and SystemC wait calls are below this line ------ */
/* -------------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------------- */


/* ------------------------------- slaveBusWrite ---------------------------------- */
void usbHostSlaveTB::slaveBusWrite(int data, int regAddress)
{
#ifdef SYSTEMC_TB
  slaveTransPort->busWrite(data, regAddress);
#else  
  busPort->writeSlave(data, regAddress);
#endif
}



/* ------------------------------- hostBusWrite ---------------------------------- */
void usbHostSlaveTB::hostBusWrite(int data, int regAddress)
{
#ifdef SYSTEMC_TB
  hostTransPort->busWrite(data, regAddress);
#else
  busPort->writeHost(data, regAddress);
#endif
}

/* ------------------------------- slaveBusRead ---------------------------------- */
void usbHostSlaveTB::slaveBusRead(int &data, int regAddress)
{
#ifdef SYSTEMC_TB
  slaveTransPort->busRead(data, regAddress);
#else
  busPort->readSlave(data, regAddress);
#endif
}

/* ------------------------------- hostBusRead ---------------------------------- */
void usbHostSlaveTB::hostBusRead(int &data, int regAddress)
{
#ifdef SYSTEMC_TB
  hostTransPort->busRead(data, regAddress);
#else
  busPort->readHost(data, regAddress);
#endif
}

/* ------------------------------- waitUSBClockTicks ---------------------------------- */
void usbHostSlaveTB::waitUSBClockTicks(int waitTicks)
{
  int i;
 
#ifdef SYSTEMC_TB
  //can use the 'hostTransPort' or 'slaveTransPort' does not matter
  hostTransPort->waitUSBClockTicks(waitTicks);
#else
  i=0;
  while (i<waitTicks) {
    i++;
  }
  
#endif
  
}



/* ------------------------------- usbLineControl ---------------------------------- */
void usbHostSlaveTB::usbLineControl(int lineState)
{
#ifdef SYSTEMC_TB
  usbLineDefaultState.write((sc_lv<2>) lineState);

#else
#ifdef UCLINUX_TB
#else
  IOWR_ALTERA_AVALON_PIO_DATA(USB_PU_CTL_BASE, 0x3); 
  IOWR_ALTERA_AVALON_PIO_DIRECTION(USB_PU_CTL_BASE_ADDR, lineState);
#endif 
#endif
}

/* ------------------------------- systemRstCtrl ---------------------------------- */
void usbHostSlaveTB::systemRstCtrl()
{
#ifdef SYSTEMC_TB
  hostTransPort->initialize();
  slaveTransPort->initialize();
#else
#ifdef UCLINUX_TB
#else
#endif 
#endif
}



