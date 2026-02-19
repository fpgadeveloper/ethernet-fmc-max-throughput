############################################################
## Build script for the Ethernet Traffic Generator IP
## Opsero Electronic Design Inc.
############################################################
# Zynq-7000
open_component -reset component_eth_traffic_gen_zynq -flow_target vivado
set_top eth_traffic_gen
add_files eth_traffic_gen.cpp
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog -description "Ethernet Traffic Generator" -vendor "opsero.com" -display_name "Ethernet Traffic Generator"
# UltraScale+
open_component -reset component_eth_traffic_gen_zuplus -flow_target vivado
set_top eth_traffic_gen
add_files eth_traffic_gen.cpp
set_part {xczu9eg-ffvb1156-2-i}
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog -description "Ethernet Traffic Generator" -vendor "opsero.com" -display_name "Ethernet Traffic Generator"
exit
