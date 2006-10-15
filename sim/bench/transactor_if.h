#ifndef __TRANSACTOR_IF_H__
#define __TRANSACTOR_IF_H__

#include <systemc.h>
#include "transactor_args.h"


class transactor_task_if : virtual public sc_interface
{
public:
     virtual void busWrite(int, int) = 0;
     virtual void busRead(int &, int) = 0;
     virtual void initialize() = 0;	
     virtual void waitUSBClockTicks(int) = 0;
};


class transactor_port_if : public sc_module
{
	public:
		sc_in<sc_logic > busClk;
		sc_out<sc_logic > reset;
		sc_out<sc_lv<8> > address_o;
		sc_out<sc_lv<8> > data_o;
		sc_in<sc_lv<8> > data_i;
		sc_out<sc_logic > we_o;
		sc_out<sc_logic > strobe_o;
		sc_in<sc_logic > ack_i;
		sc_in<sc_logic > usbClk;
		sc_in<sc_logic > hostSOFSentIntOut;
		sc_in<sc_logic > hostConnEventIntOut;
		sc_in<sc_logic > hostResumeIntOut;
		sc_in<sc_logic > hostTransDoneIntOut;
		sc_in<sc_logic > slaveNAKSentIntOut;
		sc_in<sc_logic > slaveSOFRxedIntOut;
		sc_in<sc_logic > slaveResetEventIntOut;
		sc_in<sc_logic > slaveResumeIntOut;
		sc_in<sc_logic > slaveTransDoneIntOut;

	transactor_port_if(sc_module_name nm) : sc_module(nm),
			busClk("busClk"),
			reset("reset"),
            address_o("address_o"),
			data_o("data_o"),
			data_i("data_i"),
			we_o("we_o"),
			strobe_o("strobe_o"),
			ack_i("ack_i"),
			usbClk("usbClk"),
			hostSOFSentIntOut("hostSOFSentIntOut"),
			hostConnEventIntOut("hostConnEventIntOut"),
			hostResumeIntOut("hostResumeIntOut"),
			hostTransDoneIntOut("hostTransDoneIntOut"),
			slaveNAKSentIntOut("slaveNAKSentIntOut"),
			slaveSOFRxedIntOut("slaveSOFRxedIntOut"),
			slaveResetEventIntOut("slaveResetEventIntOut"),
			slaveResumeIntOut("slaveResumeIntOut"),
			slaveTransDoneIntOut("slaveTransDoneIntOut")
	{}
};



#endif // __TRANSACTOR_IF_H__
