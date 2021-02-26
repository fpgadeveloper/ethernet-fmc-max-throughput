# Opsero Electronic Design Inc. Copyright 2021
#
# This script will search for all of the Makefiles in all of the HLS IP in this
# directory, and remove the comments that cause build errors in the 2020.2 tool release.
# 
# For more information, see these forum posts:
# https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Vitis-for-Windows-can-t-build-platform-for-Vitis-HLS-project/m-p/1203180
# https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Bug-HLS-2020-2-generated-makefile-compilation-error-in-vitis/td-p/1206772
# 

proc glob-r {{dir .} args} {
    set res {}
    foreach i [lsort [glob -nocomplain -dir $dir *]] {
        if {[file isdirectory $i]} {
            eval [list lappend res] [eval [linsert $args 0 glob-r $i]]
        } else {
            if {[llength $args]} {
                foreach arg $args {
                    if {[string match $arg $i]} {
                        lappend res $i
                        break
                    }
                }
            } else {
                lappend res $i
            }
        }
    }
    return $res
} ;# JH

proc patch_make_file {make_file} {
  set fd [open "${make_file}" "r"]
  set file_data [read $fd]
  close $fd

  set data [split $file_data "\n"]
  
  # Write to new Makefile and remove bad comments
  set new_filename "${make_file}.txt"
  set fd [open "$new_filename" "w"]
  foreach line $data {
    if {[string match "#echo*" [string trim $line]] == 0} {
      puts $fd $line
    }
  }
  close $fd

  # Delete the original Makefile
  file delete $make_file
  
  # Rename new makefile
  file rename $new_filename $make_file
  
  return 0  
}

set make_files [glob-r . */Makefile]

foreach make_file $make_files {
  puts "PATCHING MAKEFILE: $make_file"
  patch_make_file $make_file
}

exit

