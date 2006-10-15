#include "transactor.h"
#include <systemc.h>
#include "usbHostConstants.h"
#include "usbSlaveConstants.h"


/* -------------------------- busWrite --------------------------------- */
void transactor::busWrite(int data, int address)
{
sc_logic ackReg;

  wait(busClk.posedge_event());
  data_o = (sc_lv<8>) data;
  address_o = (sc_lv<8>) address;
  strobe_o = (sc_logic) 1;
  we_o = sc_logic_1;
  wait(busClk.posedge_event());    //all write accesses are acknowledged immediately
  ackReg = ack_i;                 //register ack_i

  if (ackReg != sc_logic_1) {
    cout << "WishBone bus write was not acknowledged\n";
    sc_stop();
  }

  strobe_o = sc_logic_0;
  we_o = sc_logic_0;

}

/* -------------------------- busRead --------------------------------- */
void transactor::busRead(int &data, int address)
{
sc_uint<8> localData;
sc_logic ackReg;

  wait(busClk.posedge_event());
  strobe_o = sc_logic_1;
  we_o = sc_logic_0;
  address_o = (sc_lv<8>) address;
  wait(busClk.posedge_event());    //most accesses are acknowledged immediately
  ackReg = ack_i;                 //register ack_i
  if (ackReg != sc_logic_1) {
    wait(busClk.posedge_event());   //but, an extra clock cycle required for fifo accesses
    ackReg = ack_i;
    if (ackReg != sc_logic_1) {
      cout << "WishBone bus read was not acknowledged\n";
      sc_stop();
    }
  }
  localData = (sc_uint<8>) data_i.read();
  strobe_o = (sc_logic_0);
  data = (int) localData;
} 


/* -------------------- waitUSBClockTicks --------------------------------- */
void transactor::waitUSBClockTicks(int waitTicks)
{
  int i;

  for (i=0; i< waitTicks;i++)
    wait(usbClk.posedge_event());
}

/* -------------------------- initialize --------------------------------- */
void transactor::initialize()
{
	reset.write(sc_logic_1);
	for (int j=0; j<4 ; j++)
	{
		wait(busClk.posedge_event());
	}
	reset.write(sc_logic_0);
}
