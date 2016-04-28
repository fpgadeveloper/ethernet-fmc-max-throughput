Vivado HLS Cores
================

The files contained in this folder contain IP cores developed in Vivado HLS.

How to build the HLS IP cores
-----------------------------

If using a Windows machine, run the `build-hls-cores.bat` batch file to build
all the HLS IP cores. If using a Linux machine, you will have to run the TCL build
script for each individual IP core.

Each IP core has its own build script (.tcl) and sources in C/C++ (.c, .cpp).
The build script for each core will generate the HDL sources for the core,
as well as a Vivado HLS project for developing/testing/simulating the core.
The generated project will be named `proj_<ip_core_name>` and will be contained in
the same location as the build script.

How to add the cores to the Vivado IP Catalog
---------------------------------------------

Once built, the simple way to add all the cores to the Vivado IP Catalog is to add the `HLS`
folder to the Vivado IP Repository Manager. With your project already opened in Vivado:

1. Select the Tools->Project Settings menu option.
2. Select the "IP" icon.
3. Select the "Repository Manager" tab.
4. Click the "+" sign to add a repository.
5. Browse to the `HLS` folder (the folder containing this readme file) and click Select.

If instead you have a specific folder where you would like to copy the IP, you can
copy the packaged IP to that location. You will find the packaged IP for each core
in this location:

`\HLS\<ip_core_name>\proj_<ip_core_name>\solution1\impl\ip\opsero_com_hls_<ip_core_name>_1_0.zip`

Simulation of the cores
-----------------------

Vivado HLS IP cores can be verified by C/RTL co-simulation within Vivado HLS, or by simulation
with an RTL testbench in Vivado.

* For C/RTL co-simulation, the C testbench and test data will be included in the Vivado
HLS project that is generated by the build script. Note that some cores cannot be verified by
C/RTL co-simulation due to use of libraries which do not support C/RTL co-simulation (for example
the stream library).
* For RTL simulation, the VHDL testbench and test data will be included in the Vivado project
that is generated by the build script in the "Vivado" folder.


Jeff Johnson
http://www.fpgadeveloper.com