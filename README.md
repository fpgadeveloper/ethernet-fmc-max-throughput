ethernet-fmc-max-throughput
===========================

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") using an FPGA based hardware
packet generator/checker to demonstrate maximum throughput.

### Supported carrier boards

* [ZedBoard](http://zedboard.org "ZedBoard")
  * LPC connector (use zedboard.xdc)
* [MicroZed 7Z010 and 7Z020](http://microzed.org "MicroZed 7Z010") with [MicroZed FMC Carrier](http://zedboard.org/product/microzed-fmc-carrier "MicroZed FMC Carrier")
  * LPC connector (use mzfmc-7z010.xdc, or mzfmc-7z020.xdc)
* [PicoZed 7Z010, 7Z015, 7Z020 and 7Z030](http://zedboard.org/product/picozed "PicoZed") with [PicoZed FMC Carrier](http://zedboard.org/product/picozed-carrier-card "PicoZed FMC Carrier")
  * LPC connector (use pzfmc-7z010.xdc, or pzfmc-7z015.xdc, or pzfmc-7z020.xdc, or pzfmc-7z030.xdc)

### Description

This project is used for testing the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") at
maximum throughput. The design contains 4 AXI Ethernet blocks and 4
hardware traffic generators/checkers. The software application sets up
the MACs in promiscuous mode which allows them to pass through all
packets, regardless of their destination MAC address. It also sets them
up to receive the FCS (checksum) from the user design, rather than
calculating and inserting it itself.

![Ethernet FMC Max Throughput Test design](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_max_throughput.png "Ethernet FMC Max Throughput Test design")

### Requirements

In order to test the Ethernet FMC using this design, you need to use an
Ethernet cable to loopback ports 0 and 2, and ports 1 and 3.
You will also need the following:

* Vivado 2015.4
* Vivado HLS 2015.4
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* Supported FMC carrier board (see list of supported carriers above)
* Two Ethernet cables
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Background

In order to test an Ethernet device at maximum throughput (back-to-back
packets at 1Gbps), one could setup the MACs to loopback to each other
and then send packets to each port from an external source such as a PC
which could compare the returned packets to the sent ones. However, it
is generally difficult to use a PC Ethernet port at full throughput,
because a PC typically has too many overheads which create a delay
between consecutive packets. For this reason, this design uses four
hardware packet generator/checkers that are implemented in the FPGA.
These generator/checkers drive the AXI Ethernet cores (the MACs) with a
continuous stream of packets. By using the FPGA to generate the Ethernet
packets, we are able to exploit almost 100% of the potential bandwidth.

### Catching Errors

Due to the FCS (checksum) which is present in every Ethernet packet, most bit
errors that are injected into the system will result in dropped packets at
the receiving MAC (ie. the receiving MAC will reject packets where the FCS does
not match the frame data). Therefore, in order to detect bit errors in this
design, we use the software application to poll the MACs and count the
rejected frames.

To ensure that the MACs are truly rejecting frames with bad checksums, we inject
one bit error into one packet per second, on all 4 ports. In order to inject a
bit error, our design needs to also supply the FCS to the transmit interface of
the MACs. We cannot inject a bit error, then allow the MACs to append the correct
FCS for the erroneous packet, or it will not be dropped on the receiving end.
The bit error must be injected after the FCS has been calculated.

To detect the errors that do not result in rejected frames, the Ethernet Traffic
Generator IP needs to read the received packets and compare them with the transmitted
frames. Any bit errors need to be counted and accessible to the processor through
a software register.

### Ethernet Traffic Generator IP

The traffic generator IP was designed in Vivado HLS (High-level Synthesis) and is coded
in C++. Vivado HLS allows hardware algorithms to be programmed in the C/C++ language which
offers tremendous advantages over VHDL and Verilog, especially when developing packet processing 
systems. This example design serves as a good platform for developing Ethernet packet
processing algorithms with the Ethernet FMC.

## Simulation

The Ethernet Traffic Generator IP can be simulated in Vivado by using the RTL testbench that
is included with the project. The Vivado project contains two block designs, `design_1` and `design_2`,
used for implementation and simulation respectively. The `design_2` block design contains one
instantiation of the Ethernet Traffic Generator IP (the DUT) and one IP core that is designed to initialize the
software registers of the DUT. The RTL testbench connects the output of the DUT (TX frames) to the input
of the DUT (RX frames). To run the simulation, simply open the Vivado project and select 
Run Simulation->Run Behavioral Simulation.

### Other applications

This design is actually used as a production test for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
because it places maximum stress on the PHYs, which forces the maximum
current consumption, heat dissipation and possibility for cross-talk
between lanes. It can however be a very useful design for people who
need to communicate over Ethernet with another FPGA or an Ethernet
device that can support the high throughput.

### License

Feel free to modify the code for your specific application.

### Fork and share

If you port this project to another hardware platform, please send me the
code or push it onto GitHub and send me the link so I can post it on my
website. The more people that benefit, the better.

### About the author

I'm an FPGA consultant and I provide FPGA design services to innovative
companies around the world. I believe in sharing knowledge and
I regularly contribute to the open source community.

Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")