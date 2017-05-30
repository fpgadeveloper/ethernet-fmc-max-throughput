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

# Add the Microblaze
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "128KB" ecc "None" cache "None" debug_module "Debug Only" axi_periph "Enabled" axi_intc "1" clk "New Clocking Wizard (100 MHz)" }  [get_bd_cells microblaze_0]

apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "sys_diff_clock ( System differential clock ) " }  [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( FPGA Reset ) " }  [get_bd_pins clk_wiz_1/reset]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( FPGA Reset ) " }  [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]

# Configure the interrupt concat

set_property -dict [list CONFIG.NUM_PORTS {10}] [get_bd_cells microblaze_0_xlconcat]

# Add the AXI Ethernet IPs
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3

# Configure all ports for full checksum hardware offload
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.TXCSUM {Full} CONFIG.RXCSUM {Full}] [get_bd_cells axi_ethernet_3]

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Configure all AXI Ethernet for RGMII
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_3]

# Configure all AXI Ethernet for no frame filter and no statistics counter (saves LUTs)
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.Frame_Filter {false} CONFIG.Statistics_Counters {false}] [get_bd_cells axi_ethernet_3]

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


# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In1]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins microblaze_0_xlconcat/In2]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In3]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins microblaze_0_xlconcat/In4]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins microblaze_0_xlconcat/In5]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins microblaze_0_xlconcat/In6]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins microblaze_0_xlconcat/In7]

# Connect AXI Ethernet clocks

connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_2/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_3/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_3/gtx_clk90]

# Create clock wiz for the Ethernet FMC 125MHz clock and 200MHz clock

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.4 clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
CONFIG.USE_LOCKED {false} \
CONFIG.USE_RESET {false} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
CONFIG.MMCM_CLKIN1_PERIOD {8.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.CLKOUT1_JITTER {109.241} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_JITTER {119.348} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_bd_cells clk_wiz_0]

# Connect the Ref clk ports to the clock wiz
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_p
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_p]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_n
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_n]
connect_bd_net [get_bd_ports ref_clk_p] [get_bd_pins clk_wiz_0/clk_in1_p]
connect_bd_net [get_bd_ports ref_clk_n] [get_bd_pins clk_wiz_0/clk_in1_n]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_ethernet_0/ref_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins axi_ethernet_0/gtx_clk]

# Create Ethernet FMC reference clock output enable and frequency select

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_oe
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant ref_clk_fsel
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]

# Add UART for the Echo server example application

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550 axi_uart16550_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_uart16550_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "rs232_uart ( UART ) " }  [get_bd_intf_pins axi_uart16550_0/UART]
connect_bd_net [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins microblaze_0_xlconcat/In8]

# Add Timer for the Echo server example application

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_timer_0/S_AXI]

connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In9]

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

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_0/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_1/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_2/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_3/s_axi_p0]
# Connect the AXI streaming clocks

connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_ethernet_0/axis_clk]
connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_ethernet_1/axis_clk]
connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_ethernet_2/axis_clk]
connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins axi_ethernet_3/axis_clk]

# Connect the resets

connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txc_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txc_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txc_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
