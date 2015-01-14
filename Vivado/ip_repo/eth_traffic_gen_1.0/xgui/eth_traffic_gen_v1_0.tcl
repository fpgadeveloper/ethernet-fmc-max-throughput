# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0} -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  set C_S_AXIS_RXD_TDATA_WIDTH  [  ipgui::add_param $IPINST -name "C_S_AXIS_RXD_TDATA_WIDTH" -parent ${Page_0} -display_name {C S AXIS RXD TDATA WIDTH}]
  set_property tooltip {AXI4Stream sink: Data Width} ${C_S_AXIS_RXD_TDATA_WIDTH}
  set C_M_AXIS_TXD_TDATA_WIDTH  [  ipgui::add_param $IPINST -name "C_M_AXIS_TXD_TDATA_WIDTH" -parent ${Page_0} -display_name {C M AXIS TXD TDATA WIDTH}]
  set_property tooltip {Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.} ${C_M_AXIS_TXD_TDATA_WIDTH}
  set C_M_AXIS_TXD_START_COUNT  [  ipgui::add_param $IPINST -name "C_M_AXIS_TXD_START_COUNT" -parent ${Page_0} -display_name {C M AXIS TXD START COUNT}]
  set_property tooltip {Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.} ${C_M_AXIS_TXD_START_COUNT}
  set C_S_AXIS_RXS_TDATA_WIDTH  [  ipgui::add_param $IPINST -name "C_S_AXIS_RXS_TDATA_WIDTH" -parent ${Page_0} -display_name {C S AXIS RXS TDATA WIDTH}]
  set_property tooltip {AXI4Stream sink: Data Width} ${C_S_AXIS_RXS_TDATA_WIDTH}
  set C_M_AXIS_TXC_TDATA_WIDTH  [  ipgui::add_param $IPINST -name "C_M_AXIS_TXC_TDATA_WIDTH" -parent ${Page_0} -display_name {C M AXIS TXC TDATA WIDTH}]
  set_property tooltip {Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.} ${C_M_AXIS_TXC_TDATA_WIDTH}
  set C_M_AXIS_TXC_START_COUNT  [  ipgui::add_param $IPINST -name "C_M_AXIS_TXC_START_COUNT" -parent ${Page_0} -display_name {C M AXIS TXC START COUNT}]
  set_property tooltip {Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.} ${C_M_AXIS_TXC_START_COUNT}
  set C_S_AXI_DATA_WIDTH  [  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0} -display_name {C S AXI DATA WIDTH}]
  set_property tooltip {Width of S_AXI data bus} ${C_S_AXI_DATA_WIDTH}
  set C_S_AXI_ADDR_WIDTH  [  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0} -display_name {C S AXI ADDR WIDTH}]
  set_property tooltip {Width of S_AXI address bus} ${C_S_AXI_ADDR_WIDTH}
  set C_S_AXI_BASEADDR  [  ipgui::add_param $IPINST -name "C_S_AXI_BASEADDR" -parent ${Page_0} -display_name {C S AXI BASEADDR}]
  set_property tooltip {C S AXI BASEADDR} ${C_S_AXI_BASEADDR}
  set C_S_AXI_HIGHADDR  [  ipgui::add_param $IPINST -name "C_S_AXI_HIGHADDR" -parent ${Page_0} -display_name {C S AXI HIGHADDR}]
  set_property tooltip {C S AXI HIGHADDR} ${C_S_AXI_HIGHADDR}


}

proc update_PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH } {
	# Procedure called to update C_S_AXIS_RXD_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH } {
	# Procedure called to validate C_S_AXIS_RXD_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TXD_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TXD_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TXD_START_COUNT { PARAM_VALUE.C_M_AXIS_TXD_START_COUNT } {
	# Procedure called to update C_M_AXIS_TXD_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TXD_START_COUNT { PARAM_VALUE.C_M_AXIS_TXD_START_COUNT } {
	# Procedure called to validate C_M_AXIS_TXD_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH } {
	# Procedure called to update C_S_AXIS_RXS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH } {
	# Procedure called to validate C_S_AXIS_RXS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TXC_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TXC_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TXC_START_COUNT { PARAM_VALUE.C_M_AXIS_TXC_START_COUNT } {
	# Procedure called to update C_M_AXIS_TXC_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TXC_START_COUNT { PARAM_VALUE.C_M_AXIS_TXC_START_COUNT } {
	# Procedure called to validate C_M_AXIS_TXC_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH { MODELPARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXIS_RXD_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TXD_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TXD_START_COUNT { MODELPARAM_VALUE.C_M_AXIS_TXD_START_COUNT PARAM_VALUE.C_M_AXIS_TXD_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TXD_START_COUNT}] ${MODELPARAM_VALUE.C_M_AXIS_TXD_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH { MODELPARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXIS_RXS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TXC_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TXC_START_COUNT { MODELPARAM_VALUE.C_M_AXIS_TXC_START_COUNT PARAM_VALUE.C_M_AXIS_TXC_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TXC_START_COUNT}] ${MODELPARAM_VALUE.C_M_AXIS_TXC_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

