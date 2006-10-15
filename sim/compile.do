buildc "usbhostslave.dlm"
addfile usbhostslave.dll
addsc usbhostslave.dll
vlog +incdir+../RTL/include ../RTL/buffers/dpMem_dc.v
vlog +incdir+../RTL/include ../RTL/buffers/fifoRTL.v
vlog +incdir+../RTL/include ../RTL/buffers/RxFifo.v
vlog +incdir+../RTL/include ../RTL/buffers/RxFifoBI.v
vlog +incdir+../RTL/include ../RTL/buffers/TxFifo.v
vlog +incdir+../RTL/include ../RTL/buffers/TxFifoBI.v

vlog +incdir+../RTL/include ../RTL/busInterface/wishBoneBI.v

vlog +incdir+../RTL/include ../RTL/hostController/directcontrol.v
vlog +incdir+../RTL/include ../RTL/hostController/getpacket.v
vlog +incdir+../RTL/include ../RTL/hostController/hctxportarbiter.v
vlog +incdir+../RTL/include ../RTL/hostController/hostcontroller.v
vlog +incdir+../RTL/include ../RTL/hostController/rxStatusMonitor.v
vlog +incdir+../RTL/include ../RTL/hostController/sendpacket.v
vlog +incdir+../RTL/include ../RTL/hostController/sendpacketarbiter.v
vlog +incdir+../RTL/include ../RTL/hostController/sendpacketcheckpreamble.v
vlog +incdir+../RTL/include ../RTL/hostController/sofcontroller.v
vlog +incdir+../RTL/include ../RTL/hostController/softransmit.v
vlog +incdir+../RTL/include ../RTL/hostController/speedCtrlMux.v
vlog +incdir+../RTL/include ../RTL/hostController/usbHostControl.v
vlog +incdir+../RTL/include ../RTL/hostController/USBHostControlBI.v

vlog +incdir+../RTL/include ../RTL/hostSlaveMux/hostSlaveMux.v
vlog +incdir+../RTL/include ../RTL/hostSlaveMux/hostSlaveMuxBI.v

vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/lineControlUpdate.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/processRxBit.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/processRxByte.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/processTxByte.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/readUSBWireData.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/siereceiver.v
vlog +incdir+../RTL/include  +define+SIM_COMPILE ../RTL/serialInterfaceEngine/SIETransmitter.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/updateCRC5.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/updateCRC16.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/usbSerialInterfaceEngine.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/usbTxWireArbiter.v
vlog +incdir+../RTL/include ../RTL/serialInterfaceEngine/writeUSBWireData.v

vlog +incdir+../RTL/include ../RTL/slaveController/endpMux.v
vlog +incdir+../RTL/include ../RTL/slaveController/fifoMux.v
vlog +incdir+../RTL/include ../RTL/slaveController/sctxportarbiter.v
vlog +incdir+../RTL/include ../RTL/slaveController/slavecontroller.v
vlog +incdir+../RTL/include ../RTL/slaveController/slaveDirectcontrol.v
vlog +incdir+../RTL/include ../RTL/slaveController/slaveGetpacket.v
vlog +incdir+../RTL/include ../RTL/slaveController/slaveRxStatusMonitor.v
vlog +incdir+../RTL/include ../RTL/slaveController/slaveSendpacket.v
vlog +incdir+../RTL/include ../RTL/slaveController/usbSlaveControl.v
vlog +incdir+../RTL/include ../RTL/slaveController/USBSlaveControlBI.v

vlog +incdir+../RTL/include ../RTL/wrapper/usbHostSlave.v
vlog bench/testEnv.v
