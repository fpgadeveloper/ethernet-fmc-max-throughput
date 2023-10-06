# Opsero Electronic Design Inc. Copyright 2023
#
# Project build script
#
# This script requires the target name to be specified upon launch. This can be done
# in two ways:
#
#   1. Using a single argument passed to the script via tclargs.
#      eg. vivado -mode batch -source build.tcl -notrace -tclargs <target-name>
#
#   2. By setting the target variable before sourcing the script.
#      eg. set target <target-name>
#          source build.tcl -notrace
#
# For a list of possible targets, see below.
#
#*****************************************************************************************

# Check the version of Vivado used
set version_required "2022.1"
set ver [lindex [split $::env(XILINX_VIVADO) /] end]
if {![string equal $ver $version_required]} {
  puts "###############################"
  puts "### Failed to build project ###"
  puts "###############################"
  puts "This project was designed for use with Vivado $version_required."
  puts "You are using Vivado $ver. Please install Vivado $version_required,"
  puts "or download the project sources from a commit of the Git repository"
  puts "that was intended for your version of Vivado ($ver)."
  return
}

# Add Xilinx board store to the repo paths
set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]

# Possible targets
dict set target_dict zedboard { avnet.com zedboard zynq maxtp_sim rgmii-0123 solution1 solution1 }

if { $argc == 1 } {
  set target [lindex $argv 0]
  puts "Target for the build: $target"
} elseif { [info exists target] && [dict exists $target_dict $target] } {
  puts "Target for the build: $target"
} else {
  puts ""
  if { [info exists target] } {
    puts "ERROR: Invalid target $target"
    puts ""
  }
  puts "The build script requires one argument to specify the design to build."
  puts "Possible values are:"
  # Get all the keys
  set all_targets [dict keys $target_dict]
  # Print the target names
  set counter 0
  foreach key $all_targets {
    if { $counter == 3 } {
      puts ""
      set counter 0
    }
    if { $counter != 0 } {
      puts -nonewline ", "
    }
    puts -nonewline $key
    incr counter
  }
  puts ""
  puts "Example 1 (from the Windows command line):"
  puts "   vivado -mode batch -source build.tcl -notrace -tclargs [lindex $all_targets 0]"
  puts ""
  puts "Example 2 (from Vivado Tcl console):"
  puts "   set target [lindex $all_targets 0]"
  puts "   source build.tcl -notrace"
  return
}

set design_name ${target}
set block_name maxtp
set board_url [lindex [dict get $target_dict $target] 0]
set board_name [lindex [dict get $target_dict $target] 1]
set proj_board [get_board_parts "$board_url:$board_name:*" -latest_file_version]
# Check if the board files are installed, if not, install them
if { $proj_board == "" } {
    puts "Failed to find board files for $board_name. Installing board files..."
    xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
    if { $board_name == "ultrazed_eg_pciecc_production" } {
        # UltraZed EG board is the only one that needs to be installed with a different name
        xhub::install [xhub::get_xitems *ultrazed_3eg_pciecc*]
    } else {
        xhub::install [xhub::get_xitems $board_url:xilinx_board_store:$board_name*]
    }
    set proj_board [get_board_parts "$board_url:$board_name:*" -latest_file_version]
} else {
    puts "Board files found for $board_name"
}

set fpga_part [get_property PART_NAME [get_board_parts $proj_board]]
set bd_script [lindex [dict get $target_dict $target] 2]
set bd_tb_script [lindex [dict get $target_dict $target] 3]
set rgmii_xdc [lindex [dict get $target_dict $target] 4]
set axi_init_soln [lindex [dict get $target_dict $target] 5]
set traff_gen_soln [lindex [dict get $target_dict $target] 6]

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/$design_name"]"

# Create project
create_project $design_name $origin_dir/$design_name -part ${fpga_part}

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set_property board_part $proj_board [current_project]

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/../HLS/axi_init/proj_axi_init/$axi_init_soln"] [file normalize "$origin_dir/../HLS/eth_traffic_gen/proj_eth_traffic_gen/$traff_gen_soln"]" $obj

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "${block_name}_wrapper" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/constraints/${target}.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/src/constraints/${target}.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/constraints/${rgmii_xdc}.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/src/constraints/${rgmii_xdc}.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj
set_property "processing_order" "LATE" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" "[file normalize "$origin_dir/src/constraints/${target}.xdc"]" $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set files [list \
 "[file normalize "$origin_dir/src/tb/maxtp_tb.sv"]"\
]
add_files -norecurse -fileset $obj $files

# Set 'sim_1' fileset file properties for remote files
set file "$origin_dir/src/tb/maxtp_tb.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "SystemVerilog" $file_obj
set_property "used_in_synthesis" "false" $file_obj

# Set 'sim_1' fileset file properties for local files
# None

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "tb_loopback" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part ${fpga_part} -flow {Vivado Synthesis 2022} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2022" [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part ${fpga_part} -flow {Vivado Implementation 2022} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2022" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:${design_name}"

# Create block design
source $origin_dir/src/bd/bd_${bd_script}.tcl

# Generate the wrapper
make_wrapper -files [get_files *${block_name}.bd] -top
add_files -norecurse ${design_name}/${design_name}.gen/sources_1/bd/${block_name}/hdl/${block_name}_wrapper.v

# Create block design for simulation
source $origin_dir/src/bd/bd_${bd_tb_script}.tcl

# Generate the wrapper
make_wrapper -files [get_files ${bd_tb_script}.bd] -top -import
set_property used_in_synthesis false [get_files ${bd_tb_script}_wrapper.v]
set_property used_in_synthesis false [get_files ${bd_tb_script}.bd]
set_property used_in_implementation false [get_files ${bd_tb_script}.bd]

# Update the compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Ensure parameter propagation has been performed
close_bd_design [current_bd_design]
open_bd_design [get_files ${block_name}.bd]
validate_bd_design -force
save_bd_design

