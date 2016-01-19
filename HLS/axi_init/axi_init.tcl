############################################################
## Build script for the AXI Initializer
## Opsero Electronic Design Inc.
############################################################
open_project -reset proj_axi_init
set_top axi_init
add_files axi_init.cpp
open_solution -reset "solution1"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog -description "AXI Initializer" -vendor "opsero.com" -display_name "AXI Initializer"
exit
