# These constraints are suitable for ZCU104 Rev 1.0
# -------------------------------------------------

# These constraints are for the ZCU104-MAX-TP design which
# uses 4x AXI Ethernet Subsystem IPs

# Notes on ZCU104 LPC connector
# ------------------------------
#
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 67
# * LA00 is routed to a global clock capable pin
#
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 67
# * LA01 is NOT routed to a global clock capable pin
#
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * All are routed to Bank 68
# * LA17 is routed to a global clock capable pin
#
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * All are routed to Bank 68
# * LA18 is NOT routed to a global clock capable pin
#


# Enable internal termination resistor on LVDS 125MHz ref_clk
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_p]
set_property DIFF_TERM TRUE [get_ports ref_clk_clk_n]

# Define I/O standards
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_fsel[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_0_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_0]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ref_clk_oe[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_1_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[3]}]
set_property IOSTANDARD LVDS [get_ports ref_clk_clk_p]
set_property IOSTANDARD LVDS [get_ports ref_clk_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_txc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_0_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_0_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_1_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_txc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_1_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_1]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_2_txc]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_2_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_2_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_2]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_port_3_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_txc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_port_3_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_io_port_3_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports reset_port_3]

set_property PACKAGE_PIN H19 [get_ports {rgmii_port_1_rd[0]}]
set_property PACKAGE_PIN G19 [get_ports mdio_io_port_0_mdio_io]
set_property PACKAGE_PIN K15 [get_ports {rgmii_port_1_rd[2]}]
set_property PACKAGE_PIN C13 [get_ports {ref_clk_fsel[0]}]
set_property PACKAGE_PIN C12 [get_ports mdio_io_port_1_mdio_io]
set_property PACKAGE_PIN D11 [get_ports rgmii_port_3_rxc]
set_property PACKAGE_PIN D10 [get_ports rgmii_port_3_rx_ctl]
set_property PACKAGE_PIN A8 [get_ports {rgmii_port_3_rd[1]}]
set_property PACKAGE_PIN A7 [get_ports {rgmii_port_3_rd[3]}]
set_property PACKAGE_PIN H18 [get_ports rgmii_port_1_rxc]
set_property PACKAGE_PIN H17 [get_ports rgmii_port_1_rx_ctl]
set_property PACKAGE_PIN K17 [get_ports mdio_io_port_0_mdc]
set_property PACKAGE_PIN J17 [get_ports reset_port_0]
set_property PACKAGE_PIN H16 [get_ports {rgmii_port_1_rd[1]}]
set_property PACKAGE_PIN G16 [get_ports {rgmii_port_1_rd[3]}]
set_property PACKAGE_PIN G15 [get_ports {ref_clk_oe[0]}]
set_property PACKAGE_PIN F15 [get_ports mdio_io_port_1_mdc]
set_property PACKAGE_PIN F11 [get_ports rgmii_port_2_rxc]
set_property PACKAGE_PIN B11 [get_ports {rgmii_port_2_rd[2]}]
set_property PACKAGE_PIN A11 [get_ports {rgmii_port_2_rd[3]}]
set_property PACKAGE_PIN B9 [get_ports {rgmii_port_3_rd[0]}]
set_property PACKAGE_PIN B8 [get_ports {rgmii_port_3_rd[2]}]
set_property PACKAGE_PIN F17 [get_ports rgmii_port_0_rxc]
set_property PACKAGE_PIN F16 [get_ports rgmii_port_0_rx_ctl]
set_property PACKAGE_PIN K19 [get_ports {rgmii_port_0_rd[2]}]
set_property PACKAGE_PIN K18 [get_ports {rgmii_port_0_rd[3]}]
set_property PACKAGE_PIN E18 [get_ports {rgmii_port_0_td[1]}]
set_property PACKAGE_PIN E17 [get_ports {rgmii_port_0_td[2]}]
set_property PACKAGE_PIN F18 [get_ports {rgmii_port_1_td[0]}]
set_property PACKAGE_PIN D17 [get_ports {rgmii_port_1_td[2]}]
set_property PACKAGE_PIN C17 [get_ports {rgmii_port_1_td[3]}]
set_property PACKAGE_PIN F12 [get_ports rgmii_port_2_rx_ctl]
set_property PACKAGE_PIN E12 [get_ports {rgmii_port_2_rd[0]}]
set_property PACKAGE_PIN H13 [get_ports {rgmii_port_2_td[1]}]
set_property PACKAGE_PIN H12 [get_ports {rgmii_port_2_td[2]}]
set_property PACKAGE_PIN C7 [get_ports rgmii_port_2_tx_ctl]
set_property PACKAGE_PIN C6 [get_ports mdio_io_port_2_mdio_io]
set_property PACKAGE_PIN J10 [get_ports {rgmii_port_3_td[0]}]
set_property PACKAGE_PIN F7 [get_ports {rgmii_port_3_td[2]}]
set_property PACKAGE_PIN E7 [get_ports {rgmii_port_3_td[3]}]
set_property PACKAGE_PIN E15 [get_ports ref_clk_clk_p]
set_property PACKAGE_PIN E14 [get_ports ref_clk_clk_n]
set_property PACKAGE_PIN L20 [get_ports {rgmii_port_0_rd[0]}]
set_property PACKAGE_PIN K20 [get_ports {rgmii_port_0_rd[1]}]
set_property PACKAGE_PIN L17 [get_ports {rgmii_port_0_td[0]}]
set_property PACKAGE_PIN L16 [get_ports rgmii_port_0_txc]
set_property PACKAGE_PIN J16 [get_ports {rgmii_port_0_td[3]}]
set_property PACKAGE_PIN J15 [get_ports rgmii_port_0_tx_ctl]
set_property PACKAGE_PIN A13 [get_ports {rgmii_port_1_td[1]}]
set_property PACKAGE_PIN A12 [get_ports rgmii_port_1_txc]
set_property PACKAGE_PIN D16 [get_ports rgmii_port_1_tx_ctl]
set_property PACKAGE_PIN C16 [get_ports reset_port_1]
set_property PACKAGE_PIN D12 [get_ports {rgmii_port_2_rd[1]}]
set_property PACKAGE_PIN C11 [get_ports {rgmii_port_2_td[0]}]
set_property PACKAGE_PIN B10 [get_ports rgmii_port_2_txc]
set_property PACKAGE_PIN A10 [get_ports {rgmii_port_2_td[3]}]
set_property PACKAGE_PIN B6 [get_ports mdio_io_port_2_mdc]
set_property PACKAGE_PIN A6 [get_ports reset_port_2]
set_property PACKAGE_PIN M13 [get_ports {rgmii_port_3_td[1]}]
set_property PACKAGE_PIN L13 [get_ports rgmii_port_3_txc]
set_property PACKAGE_PIN E9 [get_ports rgmii_port_3_tx_ctl]
set_property PACKAGE_PIN D9 [get_ports mdio_io_port_3_mdc]
set_property PACKAGE_PIN F8 [get_ports mdio_io_port_3_mdio_io]
set_property PACKAGE_PIN E8 [get_ports reset_port_3]

# Constraints suggested by AR#65947 http://www.xilinx.com/support/answers/65947.html

# BUFG on 200 MHz input clock
#set_property CLOCK_REGION X3Y2 [get_cells *_i/clk_wiz_0/inst/clkout2_buf]
# BUFG on GTX Clock
# Commented below because I removed the BUFG from clk_wiz_0 output 1 (in effort to save BUFG)
#set_property CLOCK_REGION X3Y3      [get_cells *_i/clk_wiz_0/inst/clkout1_buf]
# BUFG on RX Clock input
#set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
#set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

#set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
#set_property CLOCK_REGION X3Y2 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

#set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk]
#set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk_iddr]

#set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
#set_property CLOCK_REGION X3Y3 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]

# Clock definitions

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]

# BITSLICE0 not available during BISC: The port rgmii_port_2_tx_ctl is assigned to a PACKAGE_PIN that uses BITSLICE_0 of a 
# Byte that will be using calibration. The signal connected to rgmii_port_2_tx_ctl will not be available during calibration 
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout, 
# rgmii_port_2_tx_ctl will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your 
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint:
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_2_tx_ctl]

# BITSLICE0 not available during BISC: The port rgmii_port_2_txc is assigned to a PACKAGE_PIN that uses BITSLICE_1 of a 
# Byte that will be using calibration. The signal connected to rgmii_port_2_txc will not be available during calibration 
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout, 
# rgmii_port_2_txc will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your 
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint: 
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_2_txc]

# BITSLICE0 not available during BISC: The port rgmii_port_1_rxc is assigned to a PACKAGE_PIN that uses BITSLICE_1 of a 
# Byte that will be using calibration. The signal connected to rgmii_port_1_rxc will not be available during calibration 
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout, 
# rgmii_port_1_rxc will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your 
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint: 
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_1_rxc]

# BITSLICE0 not available during BISC: The port rgmii_port_3_rxc is assigned to a PACKAGE_PIN that uses BITSLICE_1 of a 
# Byte that will be using calibration. The signal connected to rgmii_port_3_rxc will not be available during calibration 
# and will only be available after RDY asserts. If this condition is not acceptable for your design and board layout, 
# rgmii_port_3_rxc will have to be moved to another PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition is acceptable for your 
# design and board layout, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint: 
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports rgmii_port_3_rxc]

# Specify the BUFGCE to use for RGMII RX clocks (Vivado itself doesn't choose the best ones and timing fails)
set_property LOC BUFGCE_X1Y112 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X1Y111 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
set_property LOC BUFGCE_X1Y136 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
set_property LOC BUFGCE_X1Y135 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]
#set_property LOC BUFGCE_X1Y136 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk_iddr]
#set_property LOC BUFGCE_X1Y135 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/bufg_rgmii_rx_clk]
#set_property LOC BUFGCE_X0Y87 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
#set_property LOC BUFGCE_X0Y86 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk]

# Adjustment to the IDELAYs to make the timing pass
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]
set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_0/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_1/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_2/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

set_property DELAY_VALUE 1000 [get_cells *_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
set_property DELAY_VALUE 1000 [get_cells {*_i/axi_ethernet_3/inst/mac/inst/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]

