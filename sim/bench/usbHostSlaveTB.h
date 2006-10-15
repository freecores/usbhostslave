/***************************************************************************
                          usbHostSlaveTB.h  -  description
                             -------------------
    begin                : Mon Sep 29 2003
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
#ifndef __usbHostSlaveTB__h
#define __usbHostSlaveTB__h

#include "condCompileFlags.h"
#ifdef SYSTEMC_TB
#include "systemc.h"
// #include "bufferReadWrite_if.h"
#include "transactor.h"
#else
#include "bus_if.h"
#endif

#ifdef SYSTEMC_TB
SC_MODULE (usbHostSlaveTB)
#else
class usbHostSlaveTB
#endif
{
public:

#ifdef SYSTEMC_TB
  // -------- ports
  sc_port<transactor_task_if> slaveTransPort;
  sc_port<transactor_task_if> hostTransPort;
  sc_out<sc_lv<2> > usbLineDefaultState;

  SC_CTOR (usbHostSlaveTB)
  {    
    SC_THREAD(main);
  }
#endif

public:
  void main();

  private:
  void connection(int, int, int, int);
  void cancelInterrupt(int, int);
  void writeXCReg(int, int, int);
  void readXCReg(int, int &, int, int, int);
  void readXCRegNoQuit(int, int &, int, int, int, int &);
  void waitUSBClockTicks(int);
  void slaveBusWrite(int, int);
  void slaveBusRead(int &, int);
  void hostBusWrite(int, int);
  void hostBusRead(int &, int);
  void hostTimingWait(int);
  void slaveTimingWait(int);
  void usbLineControl(int lineState);
  void sendTransaction(int, int, int, int, int, int, int, int);
  void rxTransaction(int, int, int, int, int, int, int);
  void quit(int);
  void systemRstCtrl();

#ifndef SYSTEMC_TB
  Bus_if *busPort;
#endif

  enum hostSlaveFlags {
    SLAVE = 0,
    HOST};

  enum dataGenFlags {
    NO_GEN=0,
    SEQ_GEN,
    RAND_GEN};
    
};

#endif

