# Opsero Electronic Design Inc.

# The following constraints are here to override some of the automatically
# generated constraints for the AXI Ethernet IPs. Specifically the
# grouping of the IDELAY_CTRLs and the IDELAYs.

current_instance *_i/axi_ethernet_0/U0/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells {tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx* tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
current_instance -quiet

current_instance *_i/axi_ethernet_1/U0/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells {rgmii_interface/delay_rgmii_rx* rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
current_instance -quiet

current_instance *_i/axi_ethernet_2/U0/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells {tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx* tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
current_instance -quiet

current_instance *_i/axi_ethernet_3/U0/eth_mac/U0
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells {rgmii_interface/delay_rgmii_rx* rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
current_instance -quiet

# Constraints for IDELAY_CTRL grouping
# The automatically generated constraints group the IDELAY_CTRLs into the
# same group, however in a design with 4 AXI Ethernet IPs, this is not
# possible to achieve because they will be spread across 2 banks.
# The following constraints group the IDELAY_CTRLs into two separate
# groups, one for each bank.

set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp0 [get_cells *_i/axi_ethernet_0/U0/eth_mac/U0/tri_mode_ethernet_mac_idelayctrl_common_i]
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp1 [get_cells *_i/axi_ethernet_2/U0/eth_mac/U0/tri_mode_ethernet_mac_idelayctrl_common_i]
