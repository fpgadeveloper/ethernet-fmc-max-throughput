############################################################
## Build script for the Ethernet Traffic Generator IP
## Opsero Electronic Design Inc.
##
## Per-target build: get_part.tcl resolves the target's real device into
## <target>/settings.tcl (set XPART ...); this script builds ONE component for
## that exact part into the target's own directory, so each target owns its
## generated IP. Invoked as:
##   vitis-run --mode hls --tcl eth_traffic_gen.tcl   with env IP_TARGET=<target>
## Vivado consumes it via ip_repo_paths = ../HLS/eth_traffic_gen/<target>/.
############################################################
set target $::env(IP_TARGET)
source "$target/settings.tcl"

# Resolve the C++ source before cd-ing into the per-target build dir.
set src [file normalize "eth_traffic_gen.cpp"]

cd $target
open_component -reset component_eth_traffic_gen -flow_target vivado
set_top eth_traffic_gen
add_files $src
set_part $XPART
create_clock -period 10 -name default
csynth_design
export_design -format ip_catalog -description "Ethernet Traffic Generator" -vendor "opsero.com" -display_name "Ethernet Traffic Generator"
exit
