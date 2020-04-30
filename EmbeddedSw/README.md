Modified BSP files
==================

### AXI Ethernet driver modifications (applies only to versions 5.6, 5.7, 5.8 and 5.9)

This repo contains a modified version of the AXI Ethernet driver to fix the following issues:

1. There is a bug in the TCL script for the AXI Ethernet driver since version 5.6 (released with Xilinx SDK 2017.3).
For designs using the AXI FIFO (instead of AXI DMA), the below script fails at line 234 because variable
`target_periph_name` is not defined.
2. AXI Ethernet driver (since version 5.6, released with Xilinx SDK 2017.3) expects AXI Ethernet Subsystem IP to
be connected to either AXI DMA or AXI FIFO. If this is not the case, this build script fails.

Location of the original TCL script for Vitis 2019.2:
`\Xilinx\Vitis\2019.2\data\embeddedsw\XilinxProcessorIPLib\drivers\axiethernet_v5_9\data\axiethernet.tcl`
