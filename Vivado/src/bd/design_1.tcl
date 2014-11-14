
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.0 [current_project]


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} ne "" && ${cur_design} eq ${design_name} } {

   # Checks if design is empty or not
   if { $list_cells ne "" } {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 1
   } else {
      puts "INFO: Constructing design in IPI design <$design_name>..."
   }
} elseif { ${cur_design} ne "" && ${cur_design} ne ${design_name} } {

   if { $list_cells eq "" } {
      puts "INFO: You have an empty design <${cur_design}>. Will go ahead and create design..."
   } else {
      set errMsg "ERROR: Design <${cur_design}> is not empty! Please do not source this script on non-empty designs."
      set nRet 1
   }
} else {

   if { [get_files -quiet ${design_name}.bd] eq "" } {
      puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

      create_bd_design $design_name

      puts "INFO: Making design <$design_name> as current_bd_design."
      current_bd_design $design_name

   } else {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 3
   }

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

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


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set mdio_io_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_0 ]
  set mdio_io_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_1 ]
  set mdio_io_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_2 ]
  set mdio_io_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_3 ]
  set rgmii_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0 ]
  set rgmii_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1 ]
  set rgmii_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2 ]
  set rgmii_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3 ]

  # Create ports
  set ref_clk_fsel [ create_bd_port -dir O -from 0 -to 0 ref_clk_fsel ]
  set ref_clk_n [ create_bd_port -dir I -from 0 -to 0 ref_clk_n ]
  set ref_clk_oe [ create_bd_port -dir O -from 0 -to 0 ref_clk_oe ]
  set ref_clk_p [ create_bd_port -dir I -from 0 -to 0 ref_clk_p ]
  set reset_port_0 [ create_bd_port -dir O -type rst reset_port_0 ]
  set reset_port_1 [ create_bd_port -dir O -type rst reset_port_1 ]
  set reset_port_2 [ create_bd_port -dir O -type rst reset_port_2 ]
  set reset_port_3 [ create_bd_port -dir O reset_port_3 ]

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_0 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII}  ] $axi_ethernet_0

  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_1 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}  ] $axi_ethernet_1

  # Create instance: axi_ethernet_2, and set properties
  set axi_ethernet_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_2 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {1}  ] $axi_ethernet_2

  # Create instance: axi_ethernet_3, and set properties
  set axi_ethernet_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_3 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}  ] $axi_ethernet_3

  # Create instance: eth_traffic_gen_0, and set properties
  set eth_traffic_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_0 ]

  # Create instance: eth_traffic_gen_1, and set properties
  set eth_traffic_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_1 ]

  # Create instance: eth_traffic_gen_2, and set properties
  set eth_traffic_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_2 ]

  # Create instance: eth_traffic_gen_3, and set properties
  set eth_traffic_gen_3 [ create_bd_cell -type ip -vlnv xilinx.com:user:eth_traffic_gen:1.0 eth_traffic_gen_3 ]

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:4.0 ila_0 ]
  set_property -dict [ list CONFIG.C_MONITOR_TYPE {Native} CONFIG.C_NUM_MONITOR_SLOTS {1} CONFIG.C_NUM_OF_PROBES {4} CONFIG.C_PROBE0_WIDTH {40} CONFIG.C_PROBE1_WIDTH {40} CONFIG.C_PROBE2_WIDTH {40} CONFIG.C_PROBE3_WIDTH {40}  ] $ila_0

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.4 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_S_AXI_HP0 {0} CONFIG.preset {ZedBoard*}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {8}  ] $processing_system7_0_axi_periph

  # Create instance: ref_clk_fsel, and set properties
  set ref_clk_fsel [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_fsel ]
  set_property -dict [ list CONFIG.CONST_VAL {1}  ] $ref_clk_fsel

  # Create instance: ref_clk_oe, and set properties
  set ref_clk_oe [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_oe ]
  set_property -dict [ list CONFIG.CONST_WIDTH {1}  ] $ref_clk_oe

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:1.0 util_ds_buf_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.NUM_PORTS {8}  ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list CONFIG.IN1_WIDTH {32} CONFIG.IN4_WIDTH {4} CONFIG.NUM_PORTS {6}  ] $xlconcat_1

  # Create instance: xlconcat_2, and set properties
  set xlconcat_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2 ]
  set_property -dict [ list CONFIG.IN1_WIDTH {32} CONFIG.IN4_WIDTH {4} CONFIG.NUM_PORTS {6}  ] $xlconcat_2

  # Create instance: xlconcat_3, and set properties
  set xlconcat_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_3 ]
  set_property -dict [ list CONFIG.IN1_WIDTH {32} CONFIG.IN4_WIDTH {4} CONFIG.NUM_PORTS {6}  ] $xlconcat_3

  # Create instance: xlconcat_4, and set properties
  set xlconcat_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_4 ]
  set_property -dict [ list CONFIG.IN1_WIDTH {32} CONFIG.IN4_WIDTH {4} CONFIG.NUM_PORTS {6}  ] $xlconcat_4

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_1/S_AXIS_RXD]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_1/S_AXIS_RXS]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio_io_port_0] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_0_rgmii [get_bd_intf_ports rgmii_port_0] [get_bd_intf_pins axi_ethernet_0/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxd [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_0/S_AXIS_RXD]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxs [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_0/S_AXIS_RXS]
  connect_bd_intf_net -intf_net axi_ethernet_1_mdio [get_bd_intf_ports mdio_io_port_1] [get_bd_intf_pins axi_ethernet_1/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_1_rgmii [get_bd_intf_ports rgmii_port_1] [get_bd_intf_pins axi_ethernet_1/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_3/S_AXIS_RXD]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxs [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_3/S_AXIS_RXS]
  connect_bd_intf_net -intf_net axi_ethernet_2_mdio [get_bd_intf_ports mdio_io_port_2] [get_bd_intf_pins axi_ethernet_2/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_2_rgmii [get_bd_intf_ports rgmii_port_2] [get_bd_intf_pins axi_ethernet_2/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxd [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins eth_traffic_gen_2/S_AXIS_RXD]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxs [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins eth_traffic_gen_2/S_AXIS_RXS]
  connect_bd_intf_net -intf_net axi_ethernet_3_mdio [get_bd_intf_ports mdio_io_port_3] [get_bd_intf_pins axi_ethernet_3/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_3_rgmii [get_bd_intf_ports rgmii_port_3] [get_bd_intf_pins axi_ethernet_3/rgmii]
  connect_bd_intf_net -intf_net eth_traffic_gen_0_M_AXIS_TXC [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins eth_traffic_gen_0/M_AXIS_TXC]
  connect_bd_intf_net -intf_net eth_traffic_gen_0_M_AXIS_TXD [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins eth_traffic_gen_0/M_AXIS_TXD]
  connect_bd_intf_net -intf_net eth_traffic_gen_1_M_AXIS_TXC [get_bd_intf_pins axi_ethernet_1/s_axis_txc] [get_bd_intf_pins eth_traffic_gen_1/M_AXIS_TXC]
  connect_bd_intf_net -intf_net eth_traffic_gen_1_M_AXIS_TXD [get_bd_intf_pins axi_ethernet_1/s_axis_txd] [get_bd_intf_pins eth_traffic_gen_1/M_AXIS_TXD]
  connect_bd_intf_net -intf_net eth_traffic_gen_2_M_AXIS_TXC [get_bd_intf_pins axi_ethernet_2/s_axis_txc] [get_bd_intf_pins eth_traffic_gen_2/M_AXIS_TXC]
  connect_bd_intf_net -intf_net eth_traffic_gen_2_M_AXIS_TXD [get_bd_intf_pins axi_ethernet_2/s_axis_txd] [get_bd_intf_pins eth_traffic_gen_2/M_AXIS_TXD]
  connect_bd_intf_net -intf_net eth_traffic_gen_3_M_AXIS_TXC [get_bd_intf_pins axi_ethernet_3/s_axis_txc] [get_bd_intf_pins eth_traffic_gen_3/M_AXIS_TXC]
  connect_bd_intf_net -intf_net eth_traffic_gen_3_M_AXIS_TXD [get_bd_intf_pins axi_ethernet_3/s_axis_txd] [get_bd_intf_pins eth_traffic_gen_3/M_AXIS_TXD]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_ethernet_1/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_ethernet_2/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins axi_ethernet_3/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins eth_traffic_gen_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M05_AXI [get_bd_intf_pins eth_traffic_gen_1/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins eth_traffic_gen_2/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins eth_traffic_gen_3/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_1 [get_bd_ports ref_clk_n] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_1 [get_bd_ports ref_clk_p] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net axi_ethernet_0_gtx_clk90_out [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_ethernet_0_m_axis_rxd_tdata1 [get_bd_pins axi_ethernet_0/m_axis_rxd_tdata] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tdata] [get_bd_pins xlconcat_4/In1]
  connect_bd_net -net axi_ethernet_0_m_axis_rxd_tkeep1 [get_bd_pins axi_ethernet_0/m_axis_rxd_tkeep] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_keep] [get_bd_pins xlconcat_4/In4]
  connect_bd_net -net axi_ethernet_0_m_axis_rxd_tlast1 [get_bd_pins axi_ethernet_0/m_axis_rxd_tlast] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tlast] [get_bd_pins xlconcat_4/In5]
  connect_bd_net -net axi_ethernet_0_m_axis_rxd_tvalid1 [get_bd_pins axi_ethernet_0/m_axis_rxd_tvalid] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tvalid] [get_bd_pins xlconcat_4/In2]
  connect_bd_net -net axi_ethernet_0_m_axis_rxs_tdata1 [get_bd_pins axi_ethernet_0/m_axis_rxs_tdata] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tdata] [get_bd_pins xlconcat_3/In1]
  connect_bd_net -net axi_ethernet_0_m_axis_rxs_tkeep1 [get_bd_pins axi_ethernet_0/m_axis_rxs_tkeep] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_keep] [get_bd_pins xlconcat_3/In4]
  connect_bd_net -net axi_ethernet_0_m_axis_rxs_tlast1 [get_bd_pins axi_ethernet_0/m_axis_rxs_tlast] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tlast] [get_bd_pins xlconcat_3/In5]
  connect_bd_net -net axi_ethernet_0_m_axis_rxs_tvalid1 [get_bd_pins axi_ethernet_0/m_axis_rxs_tvalid] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tvalid] [get_bd_pins xlconcat_3/In2]
  connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_ethernet_0_phy_rst_n [get_bd_ports reset_port_0] [get_bd_pins axi_ethernet_0/phy_rst_n]
  connect_bd_net -net axi_ethernet_1_interrupt [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_ethernet_1_mac_irq [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_ethernet_1_phy_rst_n [get_bd_ports reset_port_1] [get_bd_pins axi_ethernet_1/phy_rst_n]
  connect_bd_net -net axi_ethernet_2_gtx_clk90_out [get_bd_pins axi_ethernet_2/gtx_clk90_out] [get_bd_pins axi_ethernet_3/gtx_clk90]
  connect_bd_net -net axi_ethernet_2_interrupt [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net axi_ethernet_2_mac_irq [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_ethernet_2_phy_rst_n [get_bd_ports reset_port_2] [get_bd_pins axi_ethernet_2/phy_rst_n]
  connect_bd_net -net axi_ethernet_3_interrupt [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In7]
  connect_bd_net -net axi_ethernet_3_mac_irq [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net axi_ethernet_3_phy_rst_n [get_bd_ports reset_port_3] [get_bd_pins axi_ethernet_3/phy_rst_n]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txc_tdata [get_bd_pins axi_ethernet_0/s_axis_txc_tdata] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tdata] [get_bd_pins xlconcat_2/In1]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txc_tkeep [get_bd_pins axi_ethernet_0/s_axis_txc_tkeep] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tkeep] [get_bd_pins xlconcat_2/In4]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txc_tlast [get_bd_pins axi_ethernet_0/s_axis_txc_tlast] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tlast] [get_bd_pins xlconcat_2/In5]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txc_tvalid [get_bd_pins axi_ethernet_0/s_axis_txc_tvalid] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tvalid] [get_bd_pins xlconcat_2/In2]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txd_tdata [get_bd_pins axi_ethernet_0/s_axis_txd_tdata] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tdata] [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txd_tkeep [get_bd_pins axi_ethernet_0/s_axis_txd_tkeep] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tkeep] [get_bd_pins xlconcat_1/In4]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txd_tlast [get_bd_pins axi_ethernet_0/s_axis_txd_tlast] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tlast] [get_bd_pins xlconcat_1/In5]
  connect_bd_net -net eth_traffic_gen_0_m_axis_txd_tvalid [get_bd_pins axi_ethernet_0/s_axis_txd_tvalid] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tvalid] [get_bd_pins xlconcat_1/In2]
  connect_bd_net -net gtx_clk_1 [get_bd_pins axi_ethernet_0/gtx_clk] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net gtx_clk_2 [get_bd_pins axi_ethernet_2/gtx_clk_out] [get_bd_pins axi_ethernet_3/gtx_clk]
  connect_bd_net -net gtx_clk_3 [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk]
  connect_bd_net -net gtx_clk_4 [get_bd_pins axi_ethernet_2/gtx_clk] [get_bd_pins processing_system7_0/FCLK_CLK1]
  connect_bd_net -net m_axis_rxd_tready_3 [get_bd_pins axi_ethernet_0/m_axis_rxd_tready] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_tready] [get_bd_pins xlconcat_4/In3]
  connect_bd_net -net m_axis_rxs_tready_2 [get_bd_pins axi_ethernet_0/m_axis_rxs_tready] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_tready] [get_bd_pins xlconcat_3/In3]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins axi_ethernet_1/s_axi_lite_clk] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins axi_ethernet_2/s_axi_lite_clk] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins axi_ethernet_3/s_axi_lite_clk] [get_bd_pins eth_traffic_gen_0/m_axis_txc_aclk] [get_bd_pins eth_traffic_gen_0/m_axis_txd_aclk] [get_bd_pins eth_traffic_gen_0/s_axi_aclk] [get_bd_pins eth_traffic_gen_0/s_axis_rxd_aclk] [get_bd_pins eth_traffic_gen_0/s_axis_rxs_aclk] [get_bd_pins eth_traffic_gen_1/m_axis_txc_aclk] [get_bd_pins eth_traffic_gen_1/m_axis_txd_aclk] [get_bd_pins eth_traffic_gen_1/s_axi_aclk] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_aclk] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_aclk] [get_bd_pins eth_traffic_gen_2/m_axis_txc_aclk] [get_bd_pins eth_traffic_gen_2/m_axis_txd_aclk] [get_bd_pins eth_traffic_gen_2/s_axi_aclk] [get_bd_pins eth_traffic_gen_2/s_axis_rxd_aclk] [get_bd_pins eth_traffic_gen_2/s_axis_rxs_aclk] [get_bd_pins eth_traffic_gen_3/m_axis_txc_aclk] [get_bd_pins eth_traffic_gen_3/m_axis_txd_aclk] [get_bd_pins eth_traffic_gen_3/s_axi_aclk] [get_bd_pins eth_traffic_gen_3/s_axis_rxd_aclk] [get_bd_pins eth_traffic_gen_3/s_axis_rxs_aclk] [get_bd_pins ila_0/clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins axi_ethernet_2/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net ref_clk_fsel_dout [get_bd_ports ref_clk_fsel] [get_bd_pins ref_clk_fsel/dout]
  connect_bd_net -net ref_clk_oe_dout [get_bd_ports ref_clk_oe] [get_bd_pins ref_clk_oe/dout]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins axi_ethernet_1/s_axi_lite_resetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins axi_ethernet_2/s_axi_lite_resetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins axi_ethernet_3/s_axi_lite_resetn] [get_bd_pins eth_traffic_gen_0/m_axis_txc_aresetn] [get_bd_pins eth_traffic_gen_0/m_axis_txd_aresetn] [get_bd_pins eth_traffic_gen_0/s_axi_aresetn] [get_bd_pins eth_traffic_gen_0/s_axis_rxd_aresetn] [get_bd_pins eth_traffic_gen_0/s_axis_rxs_aresetn] [get_bd_pins eth_traffic_gen_1/m_axis_txc_aresetn] [get_bd_pins eth_traffic_gen_1/m_axis_txd_aresetn] [get_bd_pins eth_traffic_gen_1/s_axi_aresetn] [get_bd_pins eth_traffic_gen_1/s_axis_rxd_aresetn] [get_bd_pins eth_traffic_gen_1/s_axis_rxs_aresetn] [get_bd_pins eth_traffic_gen_2/m_axis_txc_aresetn] [get_bd_pins eth_traffic_gen_2/m_axis_txd_aresetn] [get_bd_pins eth_traffic_gen_2/s_axi_aresetn] [get_bd_pins eth_traffic_gen_2/s_axis_rxd_aresetn] [get_bd_pins eth_traffic_gen_2/s_axis_rxs_aresetn] [get_bd_pins eth_traffic_gen_3/m_axis_txc_aresetn] [get_bd_pins eth_traffic_gen_3/m_axis_txd_aresetn] [get_bd_pins eth_traffic_gen_3/s_axi_aresetn] [get_bd_pins eth_traffic_gen_3/s_axis_rxd_aresetn] [get_bd_pins eth_traffic_gen_3/s_axis_rxs_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn] [get_bd_pins xlconcat_1/In0] [get_bd_pins xlconcat_2/In0] [get_bd_pins xlconcat_3/In0] [get_bd_pins xlconcat_4/In0]
  connect_bd_net -net util_reduced_logic_0_Res [get_bd_pins axi_ethernet_0/s_axis_txd_tready] [get_bd_pins eth_traffic_gen_0/m_axis_txd_tready] [get_bd_pins xlconcat_1/In3]
  connect_bd_net -net util_reduced_logic_1_Res [get_bd_pins axi_ethernet_0/s_axis_txc_tready] [get_bd_pins eth_traffic_gen_0/m_axis_txc_tready] [get_bd_pins xlconcat_2/In3]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins ila_0/probe1] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconcat_2_dout [get_bd_pins ila_0/probe0] [get_bd_pins xlconcat_2/dout]
  connect_bd_net -net xlconcat_3_dout [get_bd_pins ila_0/probe2] [get_bd_pins xlconcat_3/dout]
  connect_bd_net -net xlconcat_4_dout [get_bd_pins ila_0/probe3] [get_bd_pins xlconcat_4/dout]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_0/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_0/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_1/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_1/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_2/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_2/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_3/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_3/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_0/eth_buf/S_AXI/REG] SEG_eth_buf_REG
  create_bd_addr_seg -range 0x40000 -offset 0x43C40000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_2/eth_buf/S_AXI/REG] SEG_eth_buf_REG1
  create_bd_addr_seg -range 0x40000 -offset 0x43CC0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_3/eth_buf/S_AXI/REG] SEG_eth_buf_REG3
  create_bd_addr_seg -range 0x40000 -offset 0x43C80000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_1/eth_buf/S_AXI/REG] SEG_eth_buf_REG4
  create_bd_addr_seg -range 0x10000 -offset 0x43D00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs eth_traffic_gen_0/S_AXI/S_AXI_reg] SEG_eth_traffic_gen_0_S_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43D10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs eth_traffic_gen_1/S_AXI/S_AXI_reg] SEG_eth_traffic_gen_1_S_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43D20000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs eth_traffic_gen_2/S_AXI/S_AXI_reg] SEG_eth_traffic_gen_2_S_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43D30000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs eth_traffic_gen_3/S_AXI/S_AXI_reg] SEG_eth_traffic_gen_3_S_AXI_reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


