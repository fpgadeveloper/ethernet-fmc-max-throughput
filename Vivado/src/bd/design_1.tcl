################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

set design_name design_1

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
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Configure the PS: Generate 200MHz clock, Enable HP0, Enable interrupts
startgroup
set_property -dict [list CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup

# Connect the FCLK_CLK0 to the PS GP0
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

# Add the concat for the interrupts
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
endgroup
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]
endgroup

# Add the port for IIC
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_fmc
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/IIC_0] [get_bd_intf_ports iic_fmc]
endgroup

# Add the AXI Ethernet IPs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_2
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_3
endgroup

# Configure ports 1 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Configure all AXI Ethernet for RGMII
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_3]

# Make AXI Ethernet ports external: MDIO, RGMII and RESET
# MDIO
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_ports mdio_io_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/mdio] [get_bd_intf_ports mdio_io_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/mdio] [get_bd_intf_ports mdio_io_port_3]
endgroup
# RGMII
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_ports rgmii_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_ports rgmii_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/rgmii] [get_bd_intf_ports rgmii_port_3]
endgroup
# RESET
startgroup
create_bd_port -dir O -type rst reset_port_0
connect_bd_net [get_bd_pins /axi_ethernet_0/phy_rst_n] [get_bd_ports reset_port_0]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_1
connect_bd_net [get_bd_pins /axi_ethernet_1/phy_rst_n] [get_bd_ports reset_port_1]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_2
connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_3
connect_bd_net [get_bd_pins /axi_ethernet_3/phy_rst_n] [get_bd_ports reset_port_3]
endgroup


# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_0/In6]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In7]

# Connect AXI Ethernet clocks

connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_2/gtx_clk_out] [get_bd_pins axi_ethernet_3/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_2/gtx_clk90_out] [get_bd_pins axi_ethernet_3/gtx_clk90]

# Connect 200MHz AXI Ethernet ref_clk

connect_bd_net [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]
connect_bd_net [get_bd_pins axi_ethernet_2/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]

# Create differential IO buffer for the Ethernet FMC 125MHz clock

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
endgroup
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_n]
endgroup

# Connect port 2 to a different 125MHz clock

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins axi_ethernet_2/gtx_clk]

# Create Ethernet FMC reference clock output enable and frequency select

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]
endgroup

# Add the Ethernet traffic generators

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_2
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_3
endgroup

# Connect the generators to the MACs

# GEN0 -> MAC0
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/M_AXIS_TXD] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_0/M_AXIS_TXC] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
# GEN1 -> MAC1
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_1/M_AXIS_TXD] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_1/M_AXIS_TXC] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
# GEN2 -> MAC2
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_2/M_AXIS_TXD] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_2/M_AXIS_TXC] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]
# GEN3 -> MAC3
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_3/M_AXIS_TXD] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins eth_traffic_gen_3/M_AXIS_TXC] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]

# GEN1 <- MAC0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_1/S_AXIS_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_1/S_AXIS_RXS]
# GEN0 <- MAC1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_0/S_AXIS_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_0/S_AXIS_RXS]
# GEN3 <- MAC2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_3/S_AXIS_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_3/S_AXIS_RXS]
# GEN2 <- MAC3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_2/S_AXIS_RXD]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_2/S_AXIS_RXS]

# Connect the AXI-lite buses

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_1/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_2/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_3/S_AXI]
endgroup

# Connect the AXI streaming clocks

connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]

connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_0/m_axis_txc_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_0/s_axis_rxs_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_0/m_axis_txd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_0/s_axis_rxd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_1/m_axis_txc_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_1/m_axis_txd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_2/m_axis_txc_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_2/s_axis_rxs_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_2/m_axis_txd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_2/s_axis_rxd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_3/m_axis_txc_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_3/s_axis_rxs_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_3/m_axis_txd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins eth_traffic_gen_3/s_axis_rxd_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]

# Connect the resets

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_0/m_axis_txc_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_0/s_axis_rxs_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_0/m_axis_txd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_0/s_axis_rxd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_1/m_axis_txc_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_1/m_axis_txd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_2/m_axis_txc_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_2/s_axis_rxs_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_2/m_axis_txd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_2/s_axis_rxd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_3/m_axis_txc_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_3/s_axis_rxs_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_3/m_axis_txd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins eth_traffic_gen_3/s_axis_rxd_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]

# Add the ILA for testing

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.0 ila_0
endgroup
startgroup
set_property -dict [list CONFIG.C_PROBE3_WIDTH {40} CONFIG.C_PROBE2_WIDTH {40} CONFIG.C_PROBE1_WIDTH {40} CONFIG.C_PROBE0_WIDTH {40} CONFIG.C_NUM_OF_PROBES {4} CONFIG.C_MONITOR_TYPE {Native} CONFIG.C_ENABLE_ILA_AXI_MON {false}] [get_bd_cells ila_0]
endgroup
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins ila_0/clk] [get_bd_pins processing_system7_0/FCLK_CLK0]

# Add the concats to the ILA ports

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1
endgroup
connect_bd_net [get_bd_pins xlconcat_1/dout] [get_bd_pins ila_0/probe0]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {6}] [get_bd_cells xlconcat_1]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2
endgroup
connect_bd_net [get_bd_pins xlconcat_2/dout] [get_bd_pins ila_0/probe1]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {6}] [get_bd_cells xlconcat_2]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_3
endgroup
connect_bd_net [get_bd_pins xlconcat_3/dout] [get_bd_pins ila_0/probe2]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {6}] [get_bd_cells xlconcat_3]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_4
endgroup
connect_bd_net [get_bd_pins xlconcat_4/dout] [get_bd_pins ila_0/probe3]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {6}] [get_bd_cells xlconcat_4]
endgroup

# Hook up probe 0 to GEN0 M_AXIS_TXC port (Ethernet port 0 transmit control)

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins xlconcat_1/In0] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins xlconcat_1/In1] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tdata] [get_bd_pins axi_ethernet_0/s_axis_txc_tdata]
connect_bd_net [get_bd_pins xlconcat_1/In2] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tvalid] [get_bd_pins axi_ethernet_0/s_axis_txc_tvalid]
connect_bd_net [get_bd_pins xlconcat_1/In3] [get_bd_pins axi_ethernet_0/s_axis_txc_tready] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tready]
connect_bd_net [get_bd_pins xlconcat_1/In4] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tkeep] [get_bd_pins axi_ethernet_0/s_axis_txc_tkeep]
connect_bd_net [get_bd_pins xlconcat_1/In5] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tlast] [get_bd_pins axi_ethernet_0/s_axis_txc_tlast]

# Hook up probe 1 to GEN0 M_AXIS_TXD port (Ethernet port 0 transmit data)

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins xlconcat_2/In0] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins xlconcat_2/In1] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tdata] [get_bd_pins axi_ethernet_0/s_axis_txd_tdata]
connect_bd_net [get_bd_pins xlconcat_2/In2] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tvalid] [get_bd_pins axi_ethernet_0/s_axis_txd_tvalid]
connect_bd_net [get_bd_pins xlconcat_2/In3] [get_bd_pins axi_ethernet_0/s_axis_txd_tready] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tready]
connect_bd_net [get_bd_pins xlconcat_2/In4] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tkeep] [get_bd_pins axi_ethernet_0/s_axis_txd_tkeep]
connect_bd_net [get_bd_pins xlconcat_2/In5] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tlast] [get_bd_pins axi_ethernet_0/s_axis_txd_tlast]

# Hook up probe 2 to MAC0 M_AXIS_RXS port (Ethernet port 0 receive control)

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins xlconcat_3/In0] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins xlconcat_3/In1] [get_bd_pins axi_ethernet_0/m_axis_rxs_tdata] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tdata]
connect_bd_net [get_bd_pins xlconcat_3/In2] [get_bd_pins axi_ethernet_0/m_axis_rxs_tvalid] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tvalid]
connect_bd_net [get_bd_pins xlconcat_3/In3] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tready] [get_bd_pins axi_ethernet_0/m_axis_rxs_tready]
connect_bd_net [get_bd_pins xlconcat_3/In4] [get_bd_pins axi_ethernet_0/m_axis_rxs_tkeep] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_keep]
connect_bd_net [get_bd_pins xlconcat_3/In5] [get_bd_pins axi_ethernet_0/m_axis_rxs_tlast] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tlast]

# Hook up probe 3 to MAC0 M_AXIS_RXD port (Ethernet port 0 receive data)

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins xlconcat_4/In0] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins xlconcat_4/In1] [get_bd_pins axi_ethernet_0/m_axis_rxd_tdata] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tdata]
connect_bd_net [get_bd_pins xlconcat_4/In2] [get_bd_pins axi_ethernet_0/m_axis_rxd_tvalid] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tvalid]
connect_bd_net [get_bd_pins xlconcat_4/In3] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tready] [get_bd_pins axi_ethernet_0/m_axis_rxd_tready]
connect_bd_net [get_bd_pins xlconcat_4/In4] [get_bd_pins axi_ethernet_0/m_axis_rxd_tkeep] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_keep]
connect_bd_net [get_bd_pins xlconcat_4/In5] [get_bd_pins axi_ethernet_0/m_axis_rxd_tlast] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tlast]


# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
