############################################################
## Build script for the Ethernet Traffic Generator IP
## Opsero Electronic Design Inc.
############################################################
open_project -reset proj_eth_traffic_gen
set_top eth_traffic_gen
add_files eth_traffic_gen.cpp
open_solution -reset "solution1"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog -description "Ethernet Traffic Generator" -vendor "opsero.com" -display_name "Ethernet Traffic Generator"
exit
