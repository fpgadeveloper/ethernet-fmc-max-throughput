Modified BSP files
==================

### AXI Ethernet driver modifications (applies only to version 5.6)

AXI Ethernet driver version 5.6 (released with Xilinx SDK 2017.3) expects AXI Ethernet Subsystem IP to
be connected to either AXI DMA or AXI FIFO. If this is not the case, this build script fails:

`\Xilinx\SDK\2017.3\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_6\data\axiethernet.tcl`

This repo contains a modified version of that driver to prevent failure of the build script for this design.
