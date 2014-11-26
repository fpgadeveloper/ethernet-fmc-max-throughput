zedboard-qgige-max-throughput
=============================

Example design for the Ethernet FMC on the ZedBoard using a hardware
packet generator/checker to demonstrate maximum throughput.

### Description

This project is used for testing the Ethernet FMC (http://ethernetfmc.com) at
maximum throughput. The design contains 4 AXI Ethernet blocks and 4
hardware packet generator/checkers. The software application sets up
the MACs in promiscuous mode which allows them to pass through all
packets, regardless of their destination MAC address. It also sets them
up to receive the FCS (checksum) from the user design, rather than
calculating and inserting it itself.

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
continuous stream of packets. They also verify the stream of packets
received from the MACs and count the bit error rate. In practice, any
bit errors that affect the system will result in dropped packets at the
receiving MAC, therefore we use the software application to poll the MACs
and count the rejected frames.

This design is actually used as a production test for the Ethernet FMC
because it places maximum stress on the PHYs, which forces the maximum
current consumption, heat dissipation and possibility for cross-talk
between lanes. It can however be a very useful design for people who
need to communicate over Ethernet with another FPGA or an Ethernet
device that can support the high throughput.

### Requirements

In order to test the Ethernet FMC using this design, you need to use an
Ethernet cable to loopback ports 0 and 2, and ports 1 and 3.
You will also need the following:

* Vivado 2014.3.1
* ZedBoard
* Ethernet FMC (http://ethernetfmc.com)
* Two Ethernet cables

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
http://www.fpgadeveloper.com