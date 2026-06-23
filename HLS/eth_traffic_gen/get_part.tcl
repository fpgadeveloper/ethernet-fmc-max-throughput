# Opsero Electronic Design Inc.
# ----------------------------------
# Resolve the *target's* real device part and write <target>/settings.tcl
# (set XPART ...), which eth_traffic_gen.tcl then sources to build the IP for
# the target's actual device.
# Run in Vivado batch mode with: -tclargs <board_url> <board_name> <target>

# Add the Xilinx board store to the repo paths so get_board_parts can resolve.
set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]

set board_url  [lindex $argv 0]
set board_name [lindex $argv 1]
set target     [lindex $argv 2]

set proj_board [get_board_parts "$board_url:$board_name:*" -latest_file_version]
# Install the board files on demand if they are not present.
if { $proj_board == "" } {
    puts "Board files for $board_name not found. Installing..."
    xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
    xhub::install [xhub::get_xitems $board_url:xilinx_board_store:$board_name*]
    set proj_board [get_board_parts "$board_url:$board_name:*" -latest_file_version]
} else {
    puts "Board files found for $board_name"
}
set XPART [get_property PART_NAME [get_board_parts $proj_board]]

# Write the per-target settings the HLS build sources.
file mkdir $target
set f [open "$target/settings.tcl" w]
puts $f "set XPART $XPART"
close $f
puts "get_part: $target -> $XPART"
