# ==============================================================================
# make_project.tcl
#
# Simple script for creating a Vivado project from the project/ folder 
# Make sure the script is executed from redpitaya_guide/ folder
#
# based on Anton Potocnik's make_project script
# ==============================================================================

set project_name "FDI_module"
source projects/$project_name/block_design.tcl
