# Max Throughput Example Design for Ethernet FMC

Example design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") using an FPGA based hardware
packet generator/checker to demonstrate maximum throughput.

## Requirements

This project is designed for version 2022.1 of the Xilinx tools (Vivado/SDK/PetaLinux). If you are using an older version of the 
Xilinx tools, then refer to the [release tags](https://github.com/fpgadeveloper/ethernet-fmc-max-throughput/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test the Ethernet FMC using this design, you need to use an
Ethernet cable to loopback ports 0 and 2, and ports 1 and 3.
You will also need the following:

* Vivado 2022.1
* Vitis 2022.1
* Vivado HLS 2022.1
* [Ethernet FMC](https://ethernetfmc.com "Ethernet FMC")
* Supported FMC carrier board (see list of supported carriers below)
* Two Ethernet cables
* [Xilinx Soft TEMAC license](https://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

## Supported carrier boards

* Zynq-7000 [ZedBoard](http://zedboard.org "ZedBoard")
  * LPC connector

## Description

This project is used for testing the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") at
maximum throughput. The design contains 4 AXI Ethernet blocks and 4
hardware traffic generators. The transmitted frames contain fixed destination and source MAC addresses,
the Ethertype, a payload of random data and the FCS checksum.

![Ethernet FMC Max Throughput Test design](docs/source/images/max-tp-block-diagram.png "Ethernet FMC Max Throughput Test design")

## Build instructions for Windows users

### Build Vivado project in Windows

1. Download the repo as a zip file and extract the files to a directory
   on your hard drive --OR-- clone the repo to your hard drive
2. Open Windows Explorer, browse to the repo files on your hard drive.
3. In the `Vivado` directory, double click on the `build-vivado.bat` batch file.
   You will be prompted to select a target design to build. You will find the project in
   the folder `Vivado/<target>`.
4. Run Vivado and open the project that was just created.
5. Click Generate bitstream.
6. When the bitstream is successfully generated, select **File->Export->Export Hardware**.
   In the window that opens, tick **Include bitstream** and use the default name and location
   for the XSA file.

### Build Vitis workspace in Windows

Before running these steps, you must first build and export the Vivado project as described above.

1. Return to Windows Explorer and browse to the Vitis directory in the repo.
2. Double click the `build-vitis.bat` batch file. You will be prompted to select a target design.
   A Vitis workspace with hardware platform and software application will be created for the
   selected target design. You will find the Vitis workspace in the folder `Vitis/<target>_workspace`.

## Build instructions for Linux users

### Build Vivado project in Linux

1. Open a command terminal and launch the setup script for Vivado:
   ```
   source <path-to-vivado-install>/2022.1/settings64.sh
   ```
2. Clone the Git repository and `cd` into the `Vivado` folder of the repo:
   ```
   git clone https://github.com/fpgadeveloper/ethernet-fmc-max-throughput.git
   cd ethernet-fmc-max-throughput/Vivado
   ```
3. Run make to create the Vivado project for the target board. You must replace `<target>` with a valid
   target (alternatively, skip to step 5):
   ```
   make project TARGET=<target>
   ```
   Valid targets are: 
   `zedboard`.
   That will create the Vivado project and block design without generating a bitstream or exporting to XSA.
4. Open the generated project in the Vivado GUI and click **Generate Bitstream**. Once the build is
   complete, select **File->Export->Export Hardware** and be sure to tick **Include bitstream** and use
   the default name and location for the XSA file.
5. Alternatively, you can create the Vivado project, generate the bitstream and export to XSA (steps 3 and 4),
   all from a single command:
   ```
   make xsa TARGET=<target>
   ```
   
### Build Vitis workspace in Linux

The following steps are required if you wish to build and run the [standalone application](stand_alone). You 
are not required to have built the Vivado design before following these steps, as the Makefile triggers the 
Vivado build for the corresponding design if it has not already been done.

1. Launch the setup script for Vivado (only if you skipped the Vivado build steps above):
   ```
   source <path-to-vivado-install>/2022.1/settings64.sh
   ```
2. Launch the setup scripts for Vitis:
   ```
   source <path-to-vitis-install>/2022.1/settings64.sh
   ```
3. To build the Vitis workspace, `cd` to the Vitis directory in the repo,
   then run make to create the Vitis workspace and compile the standalone application:
   ```
   cd ethernet-fmc-max-throughput/Vitis
   make workspace TARGET=<target>
   ```
   You will find the Vitis workspace in the folder `Vitis/<target>_workspace`.

## Background

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

## MAC Setup

The software application sets up the MACs in promiscuous mode which
allows them to pass through all packets, regardless of their destination
MAC address. It also sets them up to receive the FCS (checksum) from the
user design, rather than calculating and inserting it itself.

## Detecting Bit Errors

### Counting Dropped Frames

Due to the FCS (checksum) which is present in every Ethernet packet, most bit
errors that are injected into the system will result in dropped packets at
the receiving MAC (ie. the receiving MAC will reject packets where the FCS does
not match the frame data). Therefore, our primary method for detection of bit
errors involves polling the MACs for rejected frames. The number of rejected
frames is tracked by the software application.

To ensure that the MACs are truly rejecting frames with bit errors, we inject
one bit error into one packet per second, on all 4 ports. Our design supplies
the FCS to the transmit interface of the MACs, rather than having the MACs 
calculate and append the FCS. This allows us to inject a bit error that should
render the FCS incorrect for the frame.

## Ethernet Traffic Generator IP

The traffic generator IP was designed in Vivado HLS (High-level Synthesis) and is coded
in C++. Vivado HLS allows hardware algorithms to be programmed in the C/C++ language which
offers tremendous advantages over VHDL and Verilog, especially when developing packet processing 
systems. This example design serves as a good platform for developing Ethernet packet
processing algorithms with the Ethernet FMC.

## Simulation

The Ethernet Traffic Generator IP can be simulated in Vivado by using the RTL testbench that
is included with the project. The Vivado project contains two block designs, `maxtp` and `maxtp_sim`,
used for implementation and simulation respectively. The `maxtp_sim` block design contains one
instantiation of the Ethernet Traffic Generator IP (the DUT) and one AXI VPI IP core that we use to initialize the
software registers of the DUT. To run the simulation, simply open the Vivado project and select 
Run Simulation->Run Behavioral Simulation.

## Other applications

This design is actually used as a production test for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
because it places maximum stress on the PHYs, which forces the maximum
current consumption, heat dissipation and possibility for cross-talk
between lanes. It can however be a very useful design for people who
need to communicate over Ethernet with another FPGA or an Ethernet
device that can support the high throughput.

## Troubleshooting

Check the following if the project fails to build or generate a bitstream:

### 1. Are you using the correct version of Vivado for this version of the repository?
Check the version specified in the Requirements section of this readme file. Note that this project is regularly maintained to the latest
version of Vivado and you may have to refer to an earlier commit of this repo if you are using an older version of Vivado.

### 2. Did you follow the Build instructions in this readme file?
All the projects in the repo are built, synthesised and implemented to a bitstream before being committed, so if you follow the
instructions, there should not be any build issues.

### 3. Did you copy/clone the repo into a short directory structure?
Vivado doesn't cope well with long directory structures, so copy/clone the repo into a short directory structure such as
`C:\projects\`. When working in long directory structures, you can get errors relating to missing files, particularly files 
that are normally generated by Vivado (FIFOs, etc).

## Contribute

We encourage contribution to these projects. If you spot issues or you want to add designs for other platforms, please
make a pull request.

## About us

This project was developed by [Opsero Inc.](http://opsero.com "Opsero Inc."),
a tight-knit team of FPGA experts delivering FPGA products and design services to start-ups and tech companies. 
Follow our blog, [FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.
