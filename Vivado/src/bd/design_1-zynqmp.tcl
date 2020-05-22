################################################################
# Block diagram build script
################################################################

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

# Add the Processor System and apply board preset
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

# Configure the PS
set_property -dict [list CONFIG.PSU__USE__S_AXI_GP2 {1} CONFIG.PSU__USE__IRQ0 {1} CONFIG.PSU__USE__IRQ1 {0} CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} CONFIG.PSU__TTC0__PERIPHERAL__IO {EMIO}] [get_bd_cells zynq_ultra_ps_e_0]

# Connect the FCLK_CLK0 to the PS GP0 and HP0
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk]

# Add the concat for the interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]

# Add the AXI Ethernet IPs
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {1}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]

# Connect clocks for AXI Ethernet Subsystem
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_0/axis_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_0/s_axi_lite_clk]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_1/axis_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_1/s_axi_lite_clk]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_2/axis_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_2/s_axi_lite_clk]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_3/axis_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_3/s_axi_lite_clk]

# Connect AXI DMA and AXI Ethernet interrupts
connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]

connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]

connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]

connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_0/In6]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In7]

# Use connection automation to connect AXI lite interfaces
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
set_property range 256K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_axi_ethernet_0_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
set_property range 256K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_axi_ethernet_1_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
set_property range 256K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_axi_ethernet_2_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
set_property range 256K [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_axi_ethernet_3_Reg0}]

# Make AXI Ethernet ports external: MDIO, RGMII and RESET
# MDIO
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_ports mdio_io_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/mdio] [get_bd_intf_ports mdio_io_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/mdio] [get_bd_intf_ports mdio_io_port_3]
# RGMII
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_ports rgmii_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_ports rgmii_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/rgmii] [get_bd_intf_ports rgmii_port_3]
# RESET
create_bd_port -dir O -type rst reset_port_0
connect_bd_net [get_bd_pins /axi_ethernet_0/phy_rst_n] [get_bd_ports reset_port_0]
create_bd_port -dir O -type rst reset_port_1
connect_bd_net [get_bd_pins /axi_ethernet_1/phy_rst_n] [get_bd_ports reset_port_1]
create_bd_port -dir O -type rst reset_port_2
connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
create_bd_port -dir O -type rst reset_port_3
connect_bd_net [get_bd_pins /axi_ethernet_3/phy_rst_n] [get_bd_ports reset_port_3]

# Create clock wizard to generate 300MHz ref_clk and 125MHz GTX clock

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {333.333} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKIN1_PERIOD {8.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {3}\
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.CLKOUT1_JITTER {119.348} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_JITTER {99.263} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]

connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_0/gtx_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_3/gtx_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins axi_ethernet_2/ref_clk]

# Connect ports for the Ethernet FMC 125MHz clock
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_p
connect_bd_net [get_bd_pins /clk_wiz_0/clk_in1_p] [get_bd_ports ref_clk_p]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_p]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_n
connect_bd_net [get_bd_pins /clk_wiz_0/clk_in1_n] [get_bd_ports ref_clk_n]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_n]

# Create Ethernet FMC reference clock output enable and frequency select

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_oe
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_fsel
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]

# Add the Ethernet traffic generators

create_bd_cell -type ip -vlnv opsero.com:hls:eth_traffic_gen:1.0 eth_traffic_gen_0
create_bd_cell -type ip -vlnv opsero.com:hls:eth_traffic_gen:1.0 eth_traffic_gen_1
create_bd_cell -type ip -vlnv opsero.com:hls:eth_traffic_gen:1.0 eth_traffic_gen_2
create_bd_cell -type ip -vlnv opsero.com:hls:eth_traffic_gen:1.0 eth_traffic_gen_3

# Connect the generators to the MACs

# GEN0 -> MAC0
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/m_axis_txd] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/m_axis_txc] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
# GEN1 -> MAC1
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_1/m_axis_txd] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_1/m_axis_txc] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
# GEN2 -> MAC2
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_2/m_axis_txd] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_2/m_axis_txc] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]
# GEN3 -> MAC3
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_3/m_axis_txd] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_3/m_axis_txc] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]

# GEN1 <- MAC0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_1/s_axis_rxd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_1/s_axis_rxs]
# GEN0 <- MAC1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_0/s_axis_rxs]
# GEN3 <- MAC2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_3/s_axis_rxd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_3/s_axis_rxs]
# GEN2 <- MAC3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_2/s_axis_rxd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_2/s_axis_rxs]

# Connect the AXI-lite buses

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins eth_traffic_gen_0/s_axi_p0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins eth_traffic_gen_1/s_axi_p0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins eth_traffic_gen_2/s_axi_p0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins eth_traffic_gen_3/s_axi_p0]

# Connect the resets

connect_bd_net [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins rst_ps8_0_*M/peripheral_aresetn]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
