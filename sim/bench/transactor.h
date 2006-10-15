#ifndef __TRANSACTOR_H__
#define __TRANSACTOR_H__

#include <systemc.h>
#include "transactor_if.h"


class transactor : public transactor_port_if,
		public transactor_task_if
{
public:
		transactor(sc_module_name nm) : transactor_port_if(nm) {};

public:
     virtual void busWrite(int, int);
     virtual void busRead(int &, int);
     virtual void initialize();
     virtual void waitUSBClockTicks(int);

     enum trnsactorHostSlaveFlags {
       TRANSACTOR_SLAVE_ID = 0,
       TRANSACTOR_HOST_ID};

};

#endif // __TRANSACTOR_H__
