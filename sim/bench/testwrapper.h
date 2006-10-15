#ifndef __TESTWRAPPER_H__
#define __TESTWRAPPER_H__

#include <systemc.h>
#include "usbHostSlaveTB.h"
#include "transactor.h"

SC_MODULE(testwrapper)
{
	sc_in<sc_logic > busClk;
	sc_in<sc_logic > usbClk;
	sc_out<sc_lv<2> > usbLineDefaultState;

	sc_out<sc_logic > host_rst_o;
    sc_out<sc_lv<8> > host_address_o;
	sc_out<sc_lv<8> > host_data_o;
	sc_in<sc_lv<8> > host_data_i;
	sc_out<sc_logic > host_we_o;
	sc_out<sc_logic > host_strobe_o;
	sc_in<sc_logic > host_ack_i;
	sc_in<sc_logic > host_hostSOFSentIntOut;
	sc_in<sc_logic > host_hostConnEventIntOut;
	sc_in<sc_logic > host_hostResumeIntOut;
	sc_in<sc_logic > host_hostTransDoneIntOut;
	sc_in<sc_logic > host_slaveNAKSentIntOut;
	sc_in<sc_logic > host_slaveSOFRxedIntOut;
	sc_in<sc_logic > host_slaveResetEventIntOut;
	sc_in<sc_logic > host_slaveResumeIntOut;
	sc_in<sc_logic > host_slaveTransDoneIntOut;

	sc_out<sc_logic > slave_rst_o;
    sc_out<sc_lv<8> > slave_address_o;
	sc_out<sc_lv<8> > slave_data_o;
	sc_in<sc_lv<8> > slave_data_i;
	sc_out<sc_logic > slave_we_o;
	sc_out<sc_logic > slave_strobe_o;
	sc_in<sc_logic > slave_ack_i;
	sc_in<sc_logic > slave_hostSOFSentIntOut;
	sc_in<sc_logic > slave_hostConnEventIntOut;
	sc_in<sc_logic > slave_hostResumeIntOut;
	sc_in<sc_logic > slave_hostTransDoneIntOut;
	sc_in<sc_logic > slave_slaveNAKSentIntOut;
	sc_in<sc_logic > slave_slaveSOFRxedIntOut;
	sc_in<sc_logic > slave_slaveResetEventIntOut;
	sc_in<sc_logic > slave_slaveResumeIntOut;
	sc_in<sc_logic > slave_slaveTransDoneIntOut;

	usbHostSlaveTB *testBench;
	transactor *usbHostTrans;
	transactor *usbSlaveTrans;

	SC_CTOR(testwrapper) :
		busClk("busClk"),
		usbLineDefaultState("usbLineDefaultState"),
		usbClk("usbClk"),
		
		host_rst_o("host_rst_o"),
		host_address_o("host_address_o"),
		host_data_o("host_data_o"),
		host_data_i("host_data_i"),
		host_we_o("host_we_o"),
		host_strobe_o("host_strobe_o"),
		host_ack_i("host_ack_i"),
		host_hostSOFSentIntOut("host_hostSOFSentIntOut"),
		host_hostConnEventIntOut("host_hostConnEventIntOut"),
		host_hostResumeIntOut("host_hostResumeIntOut"),
		host_hostTransDoneIntOut("host_hostTransDoneIntOut"),
		host_slaveNAKSentIntOut("host_slaveNAKSentIntOut"),
		host_slaveSOFRxedIntOut("host_slaveSOFRxedIntOut"),
		host_slaveResetEventIntOut("host_slaveResetEventIntOut"),
		host_slaveResumeIntOut("host_slaveResumeIntOut"),
		host_slaveTransDoneIntOut("host_slaveTransDoneIntOut"),

		slave_rst_o("slave_rst_o"),
		slave_address_o("slave_address_o"),
		slave_data_o("slave_data_o"),
		slave_data_i("slave_data_i"),
		slave_we_o("slave_we_o"),
		slave_strobe_o("slave_strobe_o"),
		slave_ack_i("slave_ack_i"),
		slave_hostSOFSentIntOut("slave_hostSOFSentIntOut"),
		slave_hostConnEventIntOut("slave_hostConnEventIntOut"),
		slave_hostResumeIntOut("slave_hostResumeIntOut"),
		slave_hostTransDoneIntOut("slave_hostTransDoneIntOut"),
		slave_slaveNAKSentIntOut("slave_slaveNAKSentIntOut"),
		slave_slaveSOFRxedIntOut("slave_slaveSOFRxedIntOut"),
		slave_slaveResetEventIntOut("slave_slaveResetEventIntOut"),
		slave_slaveResumeIntOut("slave_slaveResumeIntOut"),
		slave_slaveTransDoneIntOut("slave_slaveTransDoneIntOut")

  {
		testBench = new usbHostSlaveTB("testBench");
		usbHostTrans = new transactor("usbHostTrans");
		usbSlaveTrans = new transactor("usbSlaveTrans");

		usbHostTrans->busClk(busClk);
		usbHostTrans->reset(host_rst_o);
		usbHostTrans->address_o(host_address_o);
		usbHostTrans->data_o(host_data_o);
		usbHostTrans->data_i(host_data_i);
		usbHostTrans->we_o(host_we_o);
		usbHostTrans->strobe_o(host_strobe_o);
		usbHostTrans->ack_i(host_ack_i);
		usbHostTrans->usbClk(usbClk);
		usbHostTrans->hostSOFSentIntOut(host_hostSOFSentIntOut);
		usbHostTrans->hostConnEventIntOut(host_hostConnEventIntOut);
		usbHostTrans->hostResumeIntOut(host_hostResumeIntOut);
		usbHostTrans->hostTransDoneIntOut(host_hostTransDoneIntOut);
		usbHostTrans->slaveNAKSentIntOut(host_slaveNAKSentIntOut);
		usbHostTrans->slaveSOFRxedIntOut(host_slaveSOFRxedIntOut);
		usbHostTrans->slaveResetEventIntOut(host_slaveResetEventIntOut);
		usbHostTrans->slaveResumeIntOut(host_slaveResumeIntOut);
		usbHostTrans->slaveTransDoneIntOut(host_slaveTransDoneIntOut);

		usbSlaveTrans->busClk(busClk);
		usbSlaveTrans->reset(slave_rst_o);
		usbSlaveTrans->address_o(slave_address_o);
		usbSlaveTrans->data_o(slave_data_o);
		usbSlaveTrans->data_i(slave_data_i);
		usbSlaveTrans->we_o(slave_we_o);
		usbSlaveTrans->strobe_o(slave_strobe_o);
		usbSlaveTrans->ack_i(slave_ack_i);
		usbSlaveTrans->usbClk(usbClk);
		usbSlaveTrans->hostSOFSentIntOut(slave_hostSOFSentIntOut);
		usbSlaveTrans->hostConnEventIntOut(slave_hostConnEventIntOut);
		usbSlaveTrans->hostResumeIntOut(slave_hostResumeIntOut);
		usbSlaveTrans->hostTransDoneIntOut(slave_hostTransDoneIntOut);
		usbSlaveTrans->slaveNAKSentIntOut(slave_slaveNAKSentIntOut);
		usbSlaveTrans->slaveSOFRxedIntOut(slave_slaveSOFRxedIntOut);
		usbSlaveTrans->slaveResetEventIntOut(slave_slaveResetEventIntOut);
		usbSlaveTrans->slaveResumeIntOut(slave_slaveResumeIntOut);
		usbSlaveTrans->slaveTransDoneIntOut(slave_slaveTransDoneIntOut);

		testBench->hostTransPort.bind(*usbHostTrans);
		testBench->slaveTransPort.bind(*usbSlaveTrans);
		testBench->usbLineDefaultState(usbLineDefaultState);

	}

	~testwrapper()
	{
		delete testBench;
		delete usbHostTrans;
		delete usbSlaveTrans;
	}
};

SC_MODULE_EXPORT(testwrapper);

#endif //__TESTWRAPPER_H__


