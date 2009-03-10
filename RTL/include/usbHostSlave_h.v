//////////////////////////////////////////////////////////////////////
// usbHostSlave_h.v                                              
//////////////////////////////////////////////////////////////////////

`ifdef usbHostSlave_h_vdefined
`else
`define usbHostSlave_h_vdefined

// Version 6 - Feb 4th 2005. Fixed bit stuffing and de-stuffing. This version succesfully supports 
//             control reads and writes to USB flash dongle 
`define USBHOSTSLAVE_VERSION_NUM 8'h06

//Host slave common registers
`define HOST_SLAVE_CONTROL_REG 1'b0
`define HOST_SLAVE_VERSION_REG 1'b1

`endif //usbHostSlave_h_vdefined

