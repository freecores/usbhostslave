//////////////////////////////////////////////////////////////////////
////                                                              ////
//// testEnv.v                                                    ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
////   Top level simulation module. Instantiates the DUT and
////   'testWrapper' which contains the SystemC testbench
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module testEnv ();

reg busClk;
wire [1:0] usbLineDefaultState;
reg usbClk;            

wire [7:0] host_address;  
wire [7:0] host_dataToDUT;       
wire [7:0] host_dataFromDUT;    
wire host_we;              
wire host_strobe;            
wire host_ack;            
wire host_hostSOFSentIntOut;
wire host_hostConnEventIntOut;
wire host_hostResumeIntOut;
wire host_hostTransDoneIntOut;
wire host_slaveSOFRxedIntOut;
wire host_slaveResetEventIntOut;
wire host_slaveResumeIntOut;
wire host_slaveTransDoneIntOut;
wire host_slaveNAKSentIntOut;
reg [1:0] host_USBWireDataIn;
wire [1:0] host_USBWireDataOut;
wire host_USBWireDataOutTick;
wire host_USBWireDataInTick;
wire host_USBWireCtrlOut;
wire host_USBFullSpeed;
wire host_rst;

wire [7:0] slave_address;  
wire [7:0] slave_dataToDUT;       
wire [7:0] slave_dataFromDUT;    
wire slave_we;              
wire slave_strobe;            
wire slave_ack;            
wire slave_hostSOFSentIntOut;
wire slave_hostConnEventIntOut;
wire slave_hostResumeIntOut;
wire slave_hostTransDoneIntOut;
wire slave_slaveSOFRxedIntOut;
wire slave_slaveResetEventIntOut;
wire slave_slaveResumeIntOut;
wire slave_slaveTransDoneIntOut;
wire slave_slaveNAKSentIntOut;
reg [1:0] slave_USBWireDataIn;
wire [1:0] slave_USBWireDataOut;
wire slave_USBWireDataOutTick;
wire slave_USBWireDataInTick;
wire slave_USBWireCtrlOut;
wire slave_USBFullSpeed;
wire slave_rst;
  
testwrapper u_testwrapper (
  .busClk(busClk),
  .usbLineDefaultState(usbLineDefaultState),
  .usbClk(usbClk),
  
  .host_rst_o(host_rst),
  .host_address_o(host_address),   
  .host_data_o(host_dataToDUT),       
  .host_data_i(host_dataFromDUT),     
  .host_we_o(host_we),              
  .host_strobe_o(host_strobe),   
  .host_ack_i(host_ack),          
  .host_hostSOFSentIntOut(host_hostSOFSentIntOut),
  .host_hostConnEventIntOut(host_hostConnEventIntOut),
  .host_hostResumeIntOut(host_hostResumeIntOut),
  .host_hostTransDoneIntOut(host_hostTransDoneIntOut),
  .host_slaveSOFRxedIntOut(host_slaveSOFRxedIntOut),
  .host_slaveResetEventIntOut(host_slaveResetEventIntOut),
  .host_slaveResumeIntOut(host_slaveResumeIntOut),
  .host_slaveTransDoneIntOut(host_slaveTransDoneIntOut),
  .host_slaveNAKSentIntOut(host_slaveNAKSentIntOut),

  .slave_rst_o(slave_rst),
  .slave_address_o(slave_address),   
  .slave_data_o(slave_dataToDUT),       
  .slave_data_i(slave_dataFromDUT),     
  .slave_we_o(slave_we),              
  .slave_strobe_o(slave_strobe),   
  .slave_ack_i(slave_ack),          
  .slave_hostSOFSentIntOut(slave_hostSOFSentIntOut),
  .slave_hostConnEventIntOut(slave_hostConnEventIntOut),
  .slave_hostResumeIntOut(slave_hostResumeIntOut),
  .slave_hostTransDoneIntOut(slave_hostTransDoneIntOut),
  .slave_slaveSOFRxedIntOut(slave_slaveSOFRxedIntOut),
  .slave_slaveResetEventIntOut(slave_slaveResetEventIntOut),
  .slave_slaveResumeIntOut(slave_slaveResumeIntOut),
  .slave_slaveTransDoneIntOut(slave_slaveTransDoneIntOut),
  .slave_slaveNAKSentIntOut(slave_slaveNAKSentIntOut)
  
  );

usbHostSlave u_host_usbHostSlave (
  .clk_i(busClk),               //Wishbone bus clock. Maximum 5*usbClk=240MHz
  .rst_i(host_rst),               //Wishbone bus sync reset. Synchronous to 'clk_i'. Resets all logic
  .usbClk(usbClk),              //usb clock. 48Mhz +/-0.25%
  .address_i(host_address),     //Wishbone bus address in
  .data_i(host_dataToDUT),        //Wishbone bus data in
  .data_o(host_dataFromDUT),       //Wishbone bus data out
  .we_i(host_we),                //Wishbone bus write enable in
  .strobe_i(host_strobe),            //Wishbone bus strobe in
  .ack_o(host_ack),              //Wishbone bus acknowledge out
  .hostSOFSentIntOut(host_hostSOFSentIntOut),
  .hostConnEventIntOut(host_hostConnEventIntOut),
  .hostResumeIntOut(host_hostResumeIntOut),
  .hostTransDoneIntOut(host_hostTransDoneIntOut),
  .slaveSOFRxedIntOut(host_slaveSOFRxedIntOut),
  .slaveResetEventIntOut(host_slaveResetEventIntOut),
  .slaveResumeIntOut(host_slaveResumeIntOut),
  .slaveTransDoneIntOut(host_slaveTransDoneIntOut),
  .slaveNAKSentIntOut(host_slaveNAKSentIntOut),
  .USBWireDataIn(host_USBWireDataIn),
  .USBWireDataOut(host_USBWireDataOut),
  .USBWireDataOutTick(host_USBWireDataOutTick),
  .USBWireDataInTick(host_USBWireDataInTick),
  .USBWireCtrlOut(host_USBWireCtrlOut),
  .USBFullSpeed(host_USBFullSpeed)
);

usbHostSlave u_slave_usbHostSlave (
  .clk_i(busClk),               //Wishbone bus clock. Maximum 5*usbClk=240MHz
  .rst_i(slave_rst),               //Wishbone bus sync reset. Synchronous to 'clk_i'. Resets all logic
  .usbClk(usbClk),              //usb clock. 48Mhz +/-0.25%
  .address_i(slave_address),     //Wishbone bus address in
  .data_i(slave_dataToDUT),        //Wishbone bus data in
  .data_o(slave_dataFromDUT),       //Wishbone bus data out
  .we_i(slave_we),                //Wishbone bus write enable in
  .strobe_i(slave_strobe),            //Wishbone bus strobe in
  .ack_o(slave_ack),              //Wishbone bus acknowledge out
  .hostSOFSentIntOut(slave_hostSOFSentIntOut),
  .hostConnEventIntOut(slave_hostConnEventIntOut),
  .hostResumeIntOut(slave_hostResumeIntOut),
  .hostTransDoneIntOut(slave_hostTransDoneIntOut),
  .slaveSOFRxedIntOut(slave_slaveSOFRxedIntOut),
  .slaveResetEventIntOut(slave_slaveResetEventIntOut),
  .slaveResumeIntOut(slave_slaveResumeIntOut),
  .slaveTransDoneIntOut(slave_slaveTransDoneIntOut),
  .slaveNAKSentIntOut(slave_slaveNAKSentIntOut),
  .USBWireDataIn(slave_USBWireDataIn),
  .USBWireDataOut(slave_USBWireDataOut),
  .USBWireDataOutTick(slave_USBWireDataOutTick),
  .USBWireDataInTick(slave_USBWireDataInTick),
  .USBWireCtrlOut(slave_USBWireCtrlOut),
  .USBFullSpeed(slave_USBFullSpeed)
);

always @(host_USBWireCtrlOut or slave_USBWireCtrlOut or 
host_USBWireDataOut or slave_USBWireDataOut or 
usbLineDefaultState) begin
  case ({host_USBWireCtrlOut,slave_USBWireCtrlOut})
  2'b00: begin //no line driver
    host_USBWireDataIn <= usbLineDefaultState;
    slave_USBWireDataIn <= usbLineDefaultState;
  end
  2'b01: begin //slave driving line
    host_USBWireDataIn <= slave_USBWireDataOut;
    slave_USBWireDataIn <= slave_USBWireDataOut;
  end
  2'b10: begin //host driving line
    host_USBWireDataIn <= host_USBWireDataOut;
    slave_USBWireDataIn <= host_USBWireDataOut;
  end
  2'b11: begin //host and slave driving line.
    host_USBWireDataIn <= 1'bx;
    slave_USBWireDataIn <= 1'bx;
  end 
  endcase
end
  
// ******************************  Clock section  ****************************** 
`define BUS_CLK_HALF_PERIOD 5
`define USB_CLK_HALF_PERIOD 11 // 10.41666
always begin
  #`BUS_CLK_HALF_PERIOD busClk <= 1'b0;
  #`BUS_CLK_HALF_PERIOD busClk <= 1'b1;
end

always begin
  #`USB_CLK_HALF_PERIOD usbClk <= 1'b0;
  #`USB_CLK_HALF_PERIOD usbClk <= 1'b1;
end

endmodule

