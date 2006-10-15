The simulation scripts are designed to work with ActiveHDL 7.1
Use ActiveHDL to open;
sim/usbhostslave.aws

From the console window;
do all.do

This will generate verilog files from the .asf files,
compile the verliog source,
compile the SystemC testbench,
initialise the simulation,
open a waveform viewer, and add all the signals from the testEnv.v,
and run the simulation

Whilst the simulation is running, you will see SystemC status messages
in the console window.

