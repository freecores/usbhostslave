USBHostSlave has been successfully compiled using Quartus 4.1 with Servive Pack 2
USBHostSlave has been tested in a SystemC simulation, and on a Altera Nios development kit Cyclone edition.

For those who wish to use a pre-configured Quartus project, I have included two files;
usbhostslaveQuartusProj.qar   - Quartus project archive
usbHostSlaveNiosIDEProj.zip   - NIOS IDE project zip file. You can use NIOS IDE File>>import to open the file


If you wish to replicate the hardware setup, then you will need to replace
the standard 50MHz oscillator with a 48MHz oscillator (Digikey XC280-ND),
and you will need a add a Santa Cruz daughter card with two USB transceivers.

If there is enough interest, I will consider producing a Santa Cruz daughter card
with the hardware required to support this core. 
Please email me at sfielding@base2designs.com if you are interested in this option.


Release notes:
Version 6 - Feb 4th 2005. Fixed bit stuffing and de-stuffing. This version succesfully supports 
            control reads and writes to USB flash dongle 

 


