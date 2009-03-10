USBHostSlave has been successfully compiled using Quartus 4.2
For some reason I have not been able to use SOPC Builder 4.2 to build the usb SOPC component
However, SOPC Builder 4.1 generates a usable SOPC component. This may be an error on my part, I need to
investigate further.
USBHostSlave has been tested in a SystemC simulation, and on a Altera Nios development kit Cyclone edition.


Release notes:
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
// Version 1.0 - October 14th 2005. Seperated the bus clock from the usb logic clock
//               Modified RX and TX fifo status registers, and removed TX fifo data count
//               register. Added RESET_CORE bit to HOST_SLAVE_CONTROL_REG.
//               Fixed slave mode bug which caused receive fifo to
//               be filled with incoming data when the slave was
//               responding with a NAK, and the data should have been discarded.
//             TODO: Test isochronous mode, and low speed mode using uClinux driver
//                   Add frame period adjustment capability
//                   Add compilation flags for slave only and host only versions
//                   Create data bus width options beyond 8-bit              

 


