# ==============================================================================
# make_cores.tcl
#
# Simple script for creating all the IPs in the cores/ folder of the red-pitaya-notes-master/ folder.
# Make sure the script is run from the red-pitaya-notes-master/ folder.
#
# based on Anton Potocnik's make_cores script
# ==============================================================================

set part_name xc7z010clg400-1

if {! [file exists cores]} {
	puts "Failed !";
	puts "Please change directory to red-pitaya-notes-master/";
	return
} 

# generate a list of ip cores by looking into the folder
cd cores
set core_names [glob -type d *]
#set core_names {axis_daq_v1_0 axis_red_pitaya_dac_v1_0}
cd ..

# generate cores
foreach core $core_names {
	set argv "$core $part_name"
	puts "Generating $core";
	puts "===========================";
	
	source scripts/core.tcl
}
