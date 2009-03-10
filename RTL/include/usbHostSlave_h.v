//////////////////////////////////////////////////////////////////////
// usbHostSlave_h.v                                              
//////////////////////////////////////////////////////////////////////

`ifdef usbHostSlave_h_vdefined
`else
`define usbHostSlave_h_vdefined

// Version 6 - Feb 4th 2005. Fixed bit stuffing and de-stuffing. This version succesfully supports 
//             control reads and writes to USB flash dongle
// Version 7 - Feb 24th 2005. Added support for isochronous transfers, fixed resume, connect and disconnect 
//             time outs, added low speed EOP keep alive. The TX bit rate is now controlled by 
//             SIETransmitter, and takes account of the requirement that SOF, and PREAMBLE are always full
//             speed, and TX resume is always low speed.
//             Fixed read clock recovery (readUSBWireData.v) issue which was resulting 
//             in missing receive packets.
//             Fixed broken SOF Sync mode (where transacations are synchronized with the SOF transmission)
//             by adding kludged delay to softranmit. This needs to be fixed properly.
//             This version has undergone limited testing
//             with full speed flash dongle, low speed keyboard, and a PC in full and low speed modes.
`define USBHOSTSLAVE_VERSION_NUM 8'h07

//Host slave common registers
`define HOST_SLAVE_CONTROL_REG 1'b0
`define HOST_SLAVE_VERSION_REG 1'b1

`endif //usbHostSlave_h_vdefined

