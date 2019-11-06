################################################################
# Block design build script
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
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Configure the PS: Generate 200MHz clock, Enable M_AXI_GP0, Enable interrupts
# We have to disable SD1 for the PicoZed because it's enabled by default and
# conflicts with I2C0.
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 14 .. 15} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_EN_CLK2_PORT {1} \
CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]

# Connect the FCLK_CLK0 to the PS GP0
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

# Add the concat for the interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]

# Add the port for FMC IIC
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_fmc
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/IIC_1] [get_bd_intf_ports iic_fmc]

# Add the AXI Ethernet IPs
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3

# Configure ports 1 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
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

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_p]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_p]
create_bd_port -dir I -from 0 -to 0 -type clk ref_clk_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_n]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports ref_clk_n]

# Connect port 2 to a different 125MHz clock

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins axi_ethernet_2/gtx_clk]

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

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
set_property range 256K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_ethernet_0_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
set_property range 256K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_ethernet_1_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
set_property range 256K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_ethernet_2_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
set_property range 256K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_ethernet_3_Reg0}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_0/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_1/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_2/s_axi_p0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins eth_traffic_gen_3/s_axi_p0]

# Connect the AXI streaming clocks

connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]

# Connect the resets

connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_ps7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

# Add AXI GPIO to drive the LEDs (LD0 to LD7) for the ZedBoard design
if { $design_name == "zedboard_max_tp" } {
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0 (100 MHz)} Clk_slave {Auto} Clk_xbar {/processing_system7_0/FCLK_CLK0 (100 MHz)} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_gpio_0/S_AXI} intc_ip {/ps7_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {leds_8bits ( LED ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_gpio_0/GPIO]
}

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
