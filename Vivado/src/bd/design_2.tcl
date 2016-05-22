################################################################
# Block design build script
################################################################
set design_name design_2

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $design_name

current_bd_design $design_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Add the Ethernet Traffic Generator
startgroup
create_bd_cell -type ip -vlnv opsero.com:hls:eth_traffic_gen:1.0 eth_traffic_gen_0
endgroup

# Make AXIS transmit and receive ports external
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_txc
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/m_axis_txc] [get_bd_intf_ports m_axis_txc]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_txd
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/m_axis_txd] [get_bd_intf_ports m_axis_txd]
endgroup
startgroup
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rxs
set_property -dict [list CONFIG.TDATA_NUM_BYTES [get_property CONFIG.TDATA_NUM_BYTES [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs]] CONFIG.HAS_TKEEP [get_property CONFIG.HAS_TKEEP [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs]] CONFIG.HAS_TLAST [get_property CONFIG.HAS_TLAST [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs]] CONFIG.LAYERED_METADATA [get_property CONFIG.LAYERED_METADATA [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs]]] [get_bd_intf_ports s_axis_rxs]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs] [get_bd_intf_ports s_axis_rxs]
endgroup
startgroup
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rxd
set_property -dict [list CONFIG.TDATA_NUM_BYTES [get_property CONFIG.TDATA_NUM_BYTES [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd]] CONFIG.HAS_TKEEP [get_property CONFIG.HAS_TKEEP [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd]] CONFIG.HAS_TLAST [get_property CONFIG.HAS_TLAST [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd]] CONFIG.LAYERED_METADATA [get_property CONFIG.LAYERED_METADATA [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd]]] [get_bd_intf_ports s_axis_rxd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd] [get_bd_intf_ports s_axis_rxd]
endgroup

# Add the AXI Software Register Initializer
startgroup
create_bd_cell -type ip -vlnv opsero.com:hls:axi_init:1.0 axi_init_0
endgroup
startgroup
create_bd_port -dir I init_start
connect_bd_net [get_bd_pins /axi_init_0/ap_start] [get_bd_ports init_start]
endgroup
startgroup
create_bd_port -dir O init_done
connect_bd_net [get_bd_pins /axi_init_0/ap_done] [get_bd_ports init_done]
endgroup
startgroup
create_bd_port -dir I -type clk ap_clk
connect_bd_net [get_bd_pins /axi_init_0/ap_clk] [get_bd_ports ap_clk]
endgroup
connect_bd_net [get_bd_ports ap_clk] [get_bd_pins eth_traffic_gen_0/ap_clk]

# Automate connection of the AXI-lite bus
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_init_0/m_axi_a" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_0/s_axi_p0]

# Make reset external
startgroup
create_bd_port -dir I -type rst reset_n
connect_bd_net [get_bd_pins /rst_ap_clk_100M/ext_reset_in] [get_bd_ports reset_n]
endgroup

# Add Ethernet Traffic Generator to address space
include_bd_addr_seg [get_bd_addr_segs -excluded axi_init_0/Data_m_axi_a/SEG_eth_traffic_gen_0_Reg]
set_property offset 0x440A0000 [get_bd_addr_segs {axi_init_0/Data_m_axi_a/SEG_eth_traffic_gen_0_Reg}]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
