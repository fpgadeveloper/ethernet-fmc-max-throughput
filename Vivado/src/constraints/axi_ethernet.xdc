# Opsero Electronic Design Inc.

# The following constraints are here to override some of the automatically
# generated constraints for the AXI Ethernet IPs. Specifically the
# grouping of the IDELAY_CTRLs and the rgmii_tx_clk.

# Constraints for rgmii_tx_clk
# The automatically generated constraints contained in *_eth_mac_?_clocks.xdc
# creates a generated clock named "rgmii_tx_clk" for the RGMII transmit clks
# for ALL the AXI Ethernet IPs. This causes inter-clock related timing errors
# when you want to supply the IPs with different asynchronous clocks.
# The following constraints override the automatically generated constraints
# and give a different clock name to each RGMII transmit clock, so that the
# tools know that the clocks are not related.

current_instance design_1_i/axi_ethernet_0/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells {tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx* tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]

set ip_gtx_clk     [get_clocks -of [get_pins tri_mode_ethernet_mac_support_clocking_i/mmcm_adv_inst/CLKOUT0]]

create_generated_clock -name mac_0_rgmii_tx_clk -divide_by 1 -source [get_pins {tri_mode_ethernet_mac_i/rgmii_interface/rgmii_txc_ddr/C}] [get_ports rgmii_port_0_txc]

set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks mac_0_rgmii_tx_clk] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks mac_0_rgmii_tx_clk] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks mac_0_rgmii_tx_clk] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks mac_0_rgmii_tx_clk] -hold

set_output_delay 0.75 -max -clock [get_clocks mac_0_rgmii_tx_clk] [get_ports {rgmii_port_0_td[*] rgmii_port_0_tx_ctl}]
set_output_delay -0.7 -min -clock [get_clocks mac_0_rgmii_tx_clk] [get_ports {rgmii_port_0_td[*] rgmii_port_0_tx_ctl}]
set_output_delay 0.75 -max -clock [get_clocks mac_0_rgmii_tx_clk] [get_ports {rgmii_port_0_td[*] rgmii_port_0_tx_ctl}] -clock_fall -add_delay 
set_output_delay -0.7 -min -clock [get_clocks mac_0_rgmii_tx_clk] [get_ports {rgmii_port_0_td[*] rgmii_port_0_tx_ctl}] -clock_fall -add_delay 
current_instance -quiet

current_instance design_1_i/axi_ethernet_1/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells {rgmii_interface/delay_rgmii_rx* rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]

set ip_gtx_clk     [get_clocks -of_objects [get_pins ../gtx_clk]]

create_generated_clock -name mac_1_rgmii_tx_clk -divide_by 1 -source [get_pins {rgmii_interface/rgmii_txc_ddr/C}] [get_ports rgmii_port_1_txc]

set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks mac_1_rgmii_tx_clk] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks mac_1_rgmii_tx_clk] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks mac_1_rgmii_tx_clk] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks mac_1_rgmii_tx_clk] -hold

set_output_delay 0.75 -max -clock [get_clocks mac_1_rgmii_tx_clk] [get_ports {rgmii_port_1_td[*] rgmii_port_1_tx_ctl}]
set_output_delay -0.7 -min -clock [get_clocks mac_1_rgmii_tx_clk] [get_ports {rgmii_port_1_td[*] rgmii_port_1_tx_ctl}]
set_output_delay 0.75 -max -clock [get_clocks mac_1_rgmii_tx_clk] [get_ports {rgmii_port_1_td[*] rgmii_port_1_tx_ctl}] -clock_fall -add_delay 
set_output_delay -0.7 -min -clock [get_clocks mac_1_rgmii_tx_clk] [get_ports {rgmii_port_1_td[*] rgmii_port_1_tx_ctl}] -clock_fall -add_delay 
current_instance -quiet

current_instance design_1_i/axi_ethernet_2/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells {tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx* tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]

set ip_gtx_clk     [get_clocks -of [get_pins tri_mode_ethernet_mac_support_clocking_i/mmcm_adv_inst/CLKOUT0]]

create_generated_clock -name mac_2_rgmii_tx_clk -divide_by 1 -source [get_pins {tri_mode_ethernet_mac_i/rgmii_interface/rgmii_txc_ddr/C}] [get_ports rgmii_port_2_txc]

set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks mac_2_rgmii_tx_clk] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks mac_2_rgmii_tx_clk] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks mac_2_rgmii_tx_clk] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks mac_2_rgmii_tx_clk] -hold

set_output_delay 0.75 -max -clock [get_clocks mac_2_rgmii_tx_clk] [get_ports {rgmii_port_2_td[*] rgmii_port_2_tx_ctl}]
set_output_delay -0.7 -min -clock [get_clocks mac_2_rgmii_tx_clk] [get_ports {rgmii_port_2_td[*] rgmii_port_2_tx_ctl}]
set_output_delay 0.75 -max -clock [get_clocks mac_2_rgmii_tx_clk] [get_ports {rgmii_port_2_td[*] rgmii_port_2_tx_ctl}] -clock_fall -add_delay 
set_output_delay -0.7 -min -clock [get_clocks mac_2_rgmii_tx_clk] [get_ports {rgmii_port_2_td[*] rgmii_port_2_tx_ctl}] -clock_fall -add_delay 
current_instance -quiet

current_instance design_1_i/axi_ethernet_3/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells {rgmii_interface/delay_rgmii_rx* rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]

set ip_gtx_clk     [get_clocks -of_objects [get_pins ../gtx_clk]]

# We use the -quiet option to hide the critical warning which says that
# this command will override the "rgmii_tx_clk" clock and all constraints
# that refer to that clock. That is precisely what we want!
create_generated_clock -quiet -name mac_3_rgmii_tx_clk -divide_by 1 -source [get_pins {rgmii_interface/rgmii_txc_ddr/C}] [get_ports rgmii_port_3_txc]

set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks mac_3_rgmii_tx_clk] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks mac_3_rgmii_tx_clk] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks mac_3_rgmii_tx_clk] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks mac_3_rgmii_tx_clk] -hold

set_output_delay 0.75 -max -clock [get_clocks mac_3_rgmii_tx_clk] [get_ports {rgmii_port_3_td[*] rgmii_port_3_tx_ctl}]
set_output_delay -0.7 -min -clock [get_clocks mac_3_rgmii_tx_clk] [get_ports {rgmii_port_3_td[*] rgmii_port_3_tx_ctl}]
set_output_delay 0.75 -max -clock [get_clocks mac_3_rgmii_tx_clk] [get_ports {rgmii_port_3_td[*] rgmii_port_3_tx_ctl}] -clock_fall -add_delay 
set_output_delay -0.7 -min -clock [get_clocks mac_3_rgmii_tx_clk] [get_ports {rgmii_port_3_td[*] rgmii_port_3_tx_ctl}] -clock_fall -add_delay 
current_instance -quiet

# Constraints for IDELAY_CTRL grouping
# The automatically generated constraints group the IDELAY_CTRLs into the
# same group, however in a design with 4 AXI Ethernet IPs, this is not
# possible to achieve because they will be spread across 2 banks.
# The following constraints group the IDELAY_CTRLs into two separate
# groups, one for each bank.

set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells design_1_i/axi_ethernet_0/eth_mac/U0/tri_mode_ethernet_mac_idelayctrl_common_i]
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells design_1_i/axi_ethernet_2/eth_mac/U0/tri_mode_ethernet_mac_idelayctrl_common_i]
