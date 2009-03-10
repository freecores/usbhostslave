//////////////////////////////////////////////////////////////////////
// usbHostSlave_h.v                                              
//////////////////////////////////////////////////////////////////////

`ifdef usbHostSlave_h_vdefined
`else
`define usbHostSlave_h_vdefined

// Version 0.6 - Feb 4th 2005. Fixed bit stuffing and de-stuffing. This version succesfully supports 
//             control reads and writes to USB flash dongle
// Version 0.7 - Feb 24th 2005. Added support for isochronous transfers, fixed resume, connect and disconnect 
//             time outs, added low speed EOP keep alive. The TX bit rate is now controlled by 
//             SIETransmitter, and takes account of the requirement that SOF, and PREAMBLE are always full
//             speed, and TX resume is always low speed.
//             Fixed read clock recovery (readUSBWireData.v) issue which was resulting 
//             in missing receive packets.
//             Fixed broken SOF Sync mode (where transacations are synchronized with the SOF transmission)
//             by adding kludged delay to softranmit. This needs to be fixed properly.
//             This version has undergone limited testing
//             with full speed flash dongle, low speed keyboard, and a PC in full and low speed modes.
// Version 0.8 - June 24th 2005. Added bus access to the host SOFTimer. This version has been tested
//             with uClinux, and is known to work with a full speed USB flash stick.
//             Moving Opencores project status from Beta to done.
//             TODO: Test isochronous mode, and low speed mode using uClinux driver
//                   Create a seperate clock domain for the bus interface
//                   Add frame period adjustment capability
//                   Add compilation flags for slave only and host only versions
//                   Create data bus width options beyond 8-bit
// Version 1.0 - October 14th 2005. Seperated the bus clock from the usb logic clock
//             Removed TX and RX fifo status registers, and removed 
//             TX fifo data count register.
//             Added RESET_CORE bit to HOST_SLAVE_CONTROL_REG. 
//             Fixed slave mode bug which caused receive fifo to be filled with 
//             incoming data when the slave was responding with a NAK, and the 
//             data should have been discarded.
// Version 1.1 - February 23rd 2006. Fixed bug related to 'noActivityTimeOut'
//             Previously the 'noActivityTimeOut' flag was repetitively pulsed whenever
//             there was no detected activity on the USB data lines. This caused an infrequent
//             misreporting of time out errors. 'noActivityTimeOut' is now only enabled when
//             the higher level state machines are actively looking for receive packets. 
//             Modified USB RX data clock recovery, so that data is sampled during the middle
//             of a USB bit period. Fixed a bug which could result in double sampling
//             of USB RX data if clock phase adjustments were required in the middle of a 
//             USB packet.

// Most significant nibble corresponds to major revision.
// Least significant nibble corresponds to minor revision.
`define USBHOSTSLAVE_VERSION_NUM 8'h11   

//Host slave common registers
`define HOST_SLAVE_CONTROL_REG 1'b0
`define HOST_SLAVE_VERSION_REG 1'b1

`endif //usbHostSlave_h_vdefined

